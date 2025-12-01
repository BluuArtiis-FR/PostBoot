# Procédure de nettoyage des WAL PostgreSQL

## Contexte

**Problème identifié :** Partition `/var` saturée à 100% (147G utilisés sur 147G)

**Cause root :** Accumulation de 7416 fichiers WAL (Write-Ahead Logs) dans `/var/backups/xlog/` occupant 113 Go, sans mécanisme de nettoyage automatique.

**Impact :**
- Base de données PostgreSQL en panne
- Erreurs : "No space left on device"
- Impossibilité d'insérer des données
- Échec de l'archivage des WAL
- Connexions applicatives en échec

---

## Diagnostic du problème

### 1. Vérifier l'utilisation du disque

```bash
sudo df -h /var
```

**Résultat attendu :** Occupation à 100%

### 2. Identifier les répertoires volumineux

```bash
sudo du -sh /var/* 2>/dev/null | sort -hr | head -15
```

**Résultat :** `/var/backups/xlog` = 113 Go

### 3. Analyser le contenu de xlog

```bash
# Compter les fichiers WAL
sudo ls /var/backups/xlog/ | wc -l

# Voir les dates de création
sudo ls -lth /var/backups/xlog/ | head -10
sudo ls -lth /var/backups/xlog/ | tail -10

# Distribution par date
sudo ls -lh /var/backups/xlog/ | grep "^-" | awk '{print $6, $7}' | sort | uniq -c
```

### 4. Vérifier la configuration PostgreSQL

```bash
sudo cat /etc/postgresql/15/main/postgresql.conf | grep -E "archive_|restore_command"
```

**Configuration problématique identifiée :**
```conf
archive_mode = on
archive_command = 'cp %p /var/backups/xlog/%f'
#archive_cleanup_command = ''    # ← NON CONFIGURÉ !
```

---

## Solution immédiate : Nettoyage manuel

### Étape 1 : Évaluer l'espace à libérer

```bash
# Fichiers de plus de 30 jours
sudo find /var/backups/xlog/ -name "0*" -type f -mtime +30 | wc -l
sudo find /var/backups/xlog/ -name "0*" -type f -mtime +30 -exec du -ch {} + | tail -1

# Fichiers de plus de 60 jours
sudo find /var/backups/xlog/ -name "0*" -type f -mtime +60 | wc -l
sudo find /var/backups/xlog/ -name "0*" -type f -mtime +60 -exec du -ch {} + | tail -1
```

### Étape 2 : Nettoyage progressif (recommandé)

```bash
# ÉTAPE 1 : Supprimer les WAL de plus de 60 jours
sudo find /var/backups/xlog/ -name "0*" -type f -mtime +60 -delete
df -h /var

# ÉTAPE 2 : Si nécessaire, supprimer ceux de plus de 30 jours
sudo find /var/backups/xlog/ -name "0*" -type f -mtime +30 -delete
df -h /var
```

**Résultat obtenu :**
- Avant : 140G utilisés, 0G disponible (100%)
- Après : 51G utilisés, 89G disponibles (37%)
- **Espace libéré : 89 Go**

---

## Solution permanente : Configuration du nettoyage automatique

### Méthode 1 : archive_cleanup_command (RECOMMANDÉ)

Cette méthode nettoie automatiquement les WAL après chaque checkpoint.

#### 1. Éditer la configuration PostgreSQL

```bash
sudo nano /etc/postgresql/15/main/postgresql.conf
```

#### 2. Trouver et modifier la ligne

Chercher avec `Ctrl+W` puis taper `archive_cleanup`

**Remplacer :**
```conf
#archive_cleanup_command = ''
```

**Par :**
```conf
archive_cleanup_command = 'pg_archivecleanup /var/backups/xlog %r'
```

#### 3. Sauvegarder et quitter
- `Ctrl+O` : Sauvegarder
- `Entrée` : Confirmer
- `Ctrl+X` : Quitter

#### 4. Recharger la configuration (sans interruption de service)

```bash
sudo systemctl reload postgresql
```

#### 5. Vérifier la prise en compte

```bash
sudo -u postgres psql -c "SHOW archive_cleanup_command;"
```

**Résultat attendu :**
```
 archive_cleanup_command
--------------------------------
 pg_archivecleanup /var/backups/xlog %r
```

---

### Méthode 2 : Cron job (alternative)

Si vous préférez un nettoyage basé sur l'âge des fichiers (ex: garder 14 jours).

#### 1. Créer le script de nettoyage

```bash
sudo nano /usr/local/bin/cleanup_pg_wal_archives.sh
```

**Contenu du script :**
```bash
#!/bin/bash
# Nettoyage automatique des WAL archivés de plus de 14 jours
# Exécuté quotidiennement via cron

LOG_FILE="/var/log/postgresql/wal_cleanup.log"
WAL_DIR="/var/backups/xlog"
RETENTION_DAYS=14

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Début du nettoyage des WAL" >> "$LOG_FILE"

# Compter les fichiers avant nettoyage
FILES_BEFORE=$(find "$WAL_DIR" -name "0*" -type f | wc -l)
SPACE_BEFORE=$(du -sh "$WAL_DIR" | awk '{print $1}')

# Supprimer les fichiers de plus de X jours
find "$WAL_DIR" -name "0*" -type f -mtime +$RETENTION_DAYS -delete

# Compter les fichiers après nettoyage
FILES_AFTER=$(find "$WAL_DIR" -name "0*" -type f | wc -l)
SPACE_AFTER=$(du -sh "$WAL_DIR" | awk '{print $1}')
FILES_DELETED=$((FILES_BEFORE - FILES_AFTER))

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Fichiers supprimés: $FILES_DELETED" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Espace avant: $SPACE_BEFORE | après: $SPACE_AFTER" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Fin du nettoyage" >> "$LOG_FILE"
```

#### 2. Rendre le script exécutable

```bash
sudo chmod +x /usr/local/bin/cleanup_pg_wal_archives.sh
```

#### 3. Configurer le cron job (exécution quotidienne à 3h du matin)

```bash
sudo crontab -e
```

**Ajouter cette ligne :**
```cron
0 3 * * * /usr/local/bin/cleanup_pg_wal_archives.sh
```

#### 4. Tester le script manuellement

```bash
sudo /usr/local/bin/cleanup_pg_wal_archives.sh
cat /var/log/postgresql/wal_cleanup.log
```

---

## Vérification et surveillance

### Vérifier les logs PostgreSQL

```bash
sudo tail -50 /var/log/postgresql/postgresql-15-main.log
```

**Rechercher :**
- ✅ Absence d'erreurs "No space left on device"
- ✅ Succès de l'archive command
- ✅ Exécution de l'archive_cleanup_command (si configuré)

### Surveiller l'espace disque

```bash
# Vérifier l'occupation de /var
df -h /var

# Compter les fichiers WAL actuels
sudo ls /var/backups/xlog/ | wc -l

# Taille du répertoire xlog
sudo du -sh /var/backups/xlog/
```

### Tester l'archivage

```bash
# Forcer un checkpoint pour déclencher l'archivage
sudo -u postgres psql -c "CHECKPOINT;"

# Vérifier les logs
sudo tail -20 /var/log/postgresql/postgresql-15-main.log | grep -E "archive|checkpoint"
```

---

## Maintenance préventive

### Actions recommandées

1. **Surveillance quotidienne** (1 semaine après configuration) :
   ```bash
   df -h /var
   sudo du -sh /var/backups/xlog/
   ```

2. **Vérification hebdomadaire** :
   ```bash
   sudo ls /var/backups/xlog/ | wc -l
   ```
   **Attendu :** Nombre stable de fichiers (pas d'accumulation)

3. **Alertes proactives** :
   - Configurer une alerte si `/var` dépasse 80% d'utilisation
   - Vérifier les logs PostgreSQL pour les erreurs d'archivage

### Politique de rétention recommandée

| Méthode | Rétention | Avantages |
|---------|-----------|-----------|
| **archive_cleanup_command** | Automatique (basé sur checkpoint) | - Nettoyage optimal<br>- Garde uniquement les WAL nécessaires<br>- Pas de gestion manuelle |
| **Cron basé sur l'âge** | 14-30 jours | - Prévisible<br>- Facile à comprendre<br>- Permet PITR sur X jours |

---

## Résumé de l'intervention

| Élément | Avant | Après |
|---------|-------|-------|
| **Espace /var** | 140G/147G (100%) | 51G/147G (37%) |
| **Espace libéré** | - | **89 Go** |
| **Fichiers WAL** | 7416 fichiers | ~1500 fichiers |
| **Période couverte** | Juillet 2024 - Nov 2024 | 30 derniers jours |
| **Configuration** | Pas de nettoyage | `archive_cleanup_command` configuré |

---

## Commandes de dépannage

### Si le disque se remplit à nouveau

```bash
# Vérifier les plus gros répertoires
sudo du -sh /var/* 2>/dev/null | sort -hr | head -10

# Nettoyage d'urgence (garder 7 jours)
sudo find /var/backups/xlog/ -name "0*" -type f -mtime +7 -delete

# Vérifier les logs applicatifs volumineux
sudo du -sh /var/log/*
```

### Vérifier la santé PostgreSQL

```bash
# Statut du service
sudo systemctl status postgresql

# Connexion test
sudo -u postgres psql -c "SELECT version();"

# Vérifier les processus bloqués
sudo -u postgres psql -c "SELECT pid, usename, application_name, state, query FROM pg_stat_activity WHERE state != 'idle';"
```

---

## Contacts et références

- **Documentation PostgreSQL :** https://www.postgresql.org/docs/15/continuous-archiving.html
- **pg_archivecleanup :** https://www.postgresql.org/docs/15/pgarchivecleanup.html
- **Serveur concerné :** BDD-PDP-Rct
- **Date intervention :** 21 novembre 2024
- **Opérateur :** saaspdp

---

## Notes importantes

⚠️ **Ne jamais supprimer manuellement les WAL du répertoire principal PostgreSQL** (`/var/lib/postgresql/15/main/pg_wal/`) !

⚠️ **Toujours tester les commandes de suppression en mode DRY-RUN d'abord** (sans `-delete`) pour vérifier ce qui sera supprimé.

⚠️ **Garder une sauvegarde complète de la base** (pg_basebackup) en dehors du serveur avant tout nettoyage massif.

✅ **archive_cleanup_command est la méthode recommandée par PostgreSQL** pour les systèmes avec archivage WAL.
