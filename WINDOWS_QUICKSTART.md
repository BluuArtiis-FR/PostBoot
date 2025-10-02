# Guide de démarrage rapide Windows - PostBootSetup v5.0

## 🪟 Spécial Windows avec Docker Desktop

Ce guide est spécifiquement conçu pour tester PostBootSetup v5.0 sur Windows avec Docker Desktop.

---

## ✅ Prérequis

### 1. Docker Desktop pour Windows
**Télécharger et installer** : https://www.docker.com/products/docker-desktop/

**Configuration minimale** :
- Windows 10 64-bit (version 1909+) ou Windows 11
- WSL 2 activé (Docker Desktop le configure automatiquement)
- 4 GB RAM minimum (8 GB recommandé)
- 20 GB espace disque disponible

**Vérification** :
```powershell
# Ouvrir PowerShell et vérifier
docker --version
docker-compose --version
```

Si les commandes fonctionnent, Docker Desktop est correctement installé ! ✅

### 2. PowerShell
Déjà inclus dans Windows. Aucune installation nécessaire.

---

## 🚀 Démarrage en 3 étapes

### Étape 1 : Ouvrir le dossier du projet

```powershell
# Dans PowerShell, naviguer vers le dossier
cd "C:\Users\fdavid\OneDrive - TENOR DATA SOLUTION\Documents\00 -TENOR\P02 - Outils SI\Scripts\EN DVP\PostBoot"
```

### Étape 2 : Lancer l'application

**Méthode simple** :
```cmd
# Double-cliquer sur start.bat
# OU exécuter dans CMD :
start.bat
```

Le script va automatiquement :
1. ✅ Vérifier que Docker Desktop est démarré
2. ✅ Arrêter les anciens conteneurs
3. ✅ Construire les images Docker
4. ✅ Démarrer l'API et Nginx
5. ✅ Tester la connexion API

**Option B : Démarrage manuel PowerShell**
```powershell
# Créer les dossiers
New-Item -ItemType Directory -Force -Path generated, logs

# Nettoyer les anciens containers
docker-compose down -v

# Construire et démarrer
docker-compose up -d --build

# Attendre 30 secondes
Start-Sleep -Seconds 30

# Vérifier le statut
docker-compose ps
```

### Étape 3 : Vérifier que tout fonctionne

```powershell
# Test rapide de l'API
Invoke-RestMethod -Uri http://localhost:5000/api/health

# Si ça retourne du JSON, c'est bon ! ✅
```

**Résultat attendu** :
```json
{
  "status": "healthy",
  "version": "5.0",
  "timestamp": "2025-10-01T14:30:00",
  "ps2exe_available": true
}
```

---

## 🧪 Tester l'API complètement

### Méthode 1 : Script automatique PowerShell

```powershell
# Exécuter le script de test
.\test_api.ps1
```

Ce script va tester automatiquement :
- ✅ Health check
- ✅ Liste des profils
- ✅ Liste des applications
- ✅ Liste des modules
- ✅ Génération d'un script
- ✅ Téléchargement du script

### Méthode 2 : Tests manuels dans PowerShell

```powershell
# 1. Health check
Invoke-RestMethod http://localhost:5000/api/health

# 2. Liste des profils
Invoke-RestMethod http://localhost:5000/api/profiles

# 3. Liste des applications
Invoke-RestMethod http://localhost:5000/api/apps

# 4. Générer un script
$config = Get-Content test_config_example.json -Raw
$response = Invoke-RestMethod -Uri http://localhost:5000/api/generate/script `
                              -Method Post `
                              -Body $config `
                              -ContentType "application/json"

# Afficher la réponse
$response | ConvertTo-Json

# 5. Télécharger le script généré
$downloadUrl = $response.download_url
Invoke-WebRequest -Uri "http://localhost:5000$downloadUrl" `
                  -OutFile "MonScript.ps1"

# 6. Vérifier le script
Get-Content MonScript.ps1 -TotalCount 50
```

### Méthode 3 : Navigateur web

Ouvrir dans le navigateur :
- **Health check** : http://localhost:5000/api/health
- **Profils** : http://localhost:5000/api/profiles
- **Apps** : http://localhost:5000/api/apps
- **Modules** : http://localhost:5000/api/modules

---

## 📊 Voir les logs Docker

### Tous les logs
```powershell
docker-compose logs -f
```

### Logs de l'API uniquement
```powershell
docker-compose logs -f api
```

### Logs du serveur web
```powershell
docker-compose logs -f web
```

**Sortir des logs** : `Ctrl + C`

---

## 🛑 Arrêter les containers

### Arrêt simple
```powershell
docker-compose down
```

### Arrêt + suppression volumes
```powershell
docker-compose down -v
```

### Arrêt + nettoyage complet
```powershell
docker-compose down -v
Remove-Item -Recurse -Force generated/*
Remove-Item -Recurse -Force logs/*
```

---

## 🔄 Redémarrer les containers

```powershell
# Redémarrer un service spécifique
docker-compose restart api
docker-compose restart web

# Redémarrer tous les services
docker-compose restart

# Reconstruire et redémarrer
docker-compose down
docker-compose up -d --build
```

---

## 🐛 Dépannage Windows

### Problème : "Docker Desktop is not running"

**Solution** :
1. Ouvrir Docker Desktop depuis le menu Démarrer
2. Attendre que le statut passe à "Running" (icône verte)
3. Réessayer la commande

### Problème : "Port 5000 already in use"

**Solution** :
```powershell
# Trouver le processus utilisant le port
netstat -ano | findstr :5000

# Tuer le processus (remplacer PID par le numéro affiché)
Stop-Process -Id PID -Force
```

**Ou modifier le port** dans `docker-compose.yml` :
```yaml
services:
  api:
    ports:
      - "5001:5000"  # Utiliser 5001 au lieu de 5000
```

### Problème : "Cannot connect to the Docker daemon"

**Solution** :
1. Vérifier que Docker Desktop est lancé
2. Dans Docker Desktop → Settings → General
3. Cocher "Expose daemon on tcp://localhost:2375 without TLS"
4. Redémarrer Docker Desktop

### Problème : "Error response from daemon: driver failed"

**Solution** :
1. Redémarrer Docker Desktop
2. Si le problème persiste :
   - Docker Desktop → Troubleshoot → Reset to factory defaults
   - Réinstaller Docker Desktop

### Problème : "The system cannot find the file specified" pour docker-compose

**Solution** :
```powershell
# Vérifier que docker-compose est installé
docker compose version

# Si la commande précédente fonctionne, utiliser "docker compose" au lieu de "docker-compose"
docker compose up -d --build
docker compose down
docker compose logs -f
```

Note : Docker Desktop récent utilise `docker compose` (espace) au lieu de `docker-compose` (tiret).

---

## 📝 Générer et tester un script complet

### Exemple complet de A à Z

```powershell
# 1. Créer une configuration personnalisée
$config = @{
    profile_name = "Test Windows"
    apps = @{
        master = @(
            @{name = "Notepad++"; winget = "Notepad++.Notepad++"}
        )
        profile = @(
            @{name = "7-Zip"; winget = "7zip.7zip"}
        )
    }
    modules = @("debloat", "performance")
    performance_options = @{
        PageFile = $true
        PowerPlan = $true
    }
} | ConvertTo-Json -Depth 5

# 2. Sauvegarder la config
$config | Out-File -FilePath "ma_config.json" -Encoding UTF8

# 3. Générer le script
$response = Invoke-RestMethod -Uri http://localhost:5000/api/generate/script `
                              -Method Post `
                              -Body $config `
                              -ContentType "application/json"

Write-Host "Script genere : $($response.filename)" -ForegroundColor Green

# 4. Télécharger le script
$downloadUrl = $response.download_url
Invoke-WebRequest -Uri "http://localhost:5000$downloadUrl" `
                  -OutFile "MonScriptPerso.ps1"

Write-Host "Script telecharge : MonScriptPerso.ps1" -ForegroundColor Green

# 5. Vérifier le contenu
Write-Host "`nApercu du script :" -ForegroundColor Cyan
Get-Content MonScriptPerso.ps1 -TotalCount 30

# 6. (Optionnel) Exécuter le script sur une VM test
# ATTENTION : Exécuter uniquement sur une VM de test !
# .\MonScriptPerso.ps1 -WhatIf
```

---

## 🎨 Interface web (à venir)

Pour le moment, l'interface web basique existe dans `web/index.html`.

**Accès** : http://localhost

Note : L'interface moderne React/Vue est à créer. Pour l'instant, utilise l'API directement via PowerShell ou Postman.

---

## 🔐 Notes de sécurité pour tests locaux

Ces containers sont configurés pour **développement local uniquement** :
- ❌ Pas d'authentification
- ❌ Pas de HTTPS
- ❌ Pas de rate limiting strict

**Pour la production**, il faudra :
- ✅ Configurer HTTPS avec certificats
- ✅ Ajouter authentification (OAuth2/JWT)
- ✅ Activer rate limiting
- ✅ Restreindre CORS

---

## 📦 Commandes Docker Desktop utiles

### Via l'interface graphique
1. Ouvrir Docker Desktop
2. Onglet "Containers" → Voir tous les containers
3. Cliquer sur un container → Voir les logs, stats, terminal

### Via PowerShell
```powershell
# Liste des containers en cours
docker ps

# Liste de toutes les images
docker images

# Espace disque utilisé
docker system df

# Nettoyer l'espace disque
docker system prune -a

# Accéder au shell d'un container
docker-compose exec api bash
docker-compose exec api pwsh

# Vérifier PS2EXE dans le container
docker-compose exec api pwsh -Command "Get-Module -ListAvailable -Name ps2exe"
```

---

## ✅ Checklist de validation

Avant de dire que tout fonctionne, vérifie :

- [ ] Docker Desktop est lancé et en statut "Running"
- [ ] `docker --version` et `docker-compose --version` fonctionnent
- [ ] `docker-compose ps` montre 2 containers "Up"
- [ ] http://localhost:5000/api/health retourne du JSON
- [ ] `.\test_api.ps1` s'exécute sans erreur
- [ ] Un fichier `generated_test_script.ps1` est créé
- [ ] Le fichier généré contient du code PowerShell valide
- [ ] Les logs ne montrent pas d'erreurs : `docker-compose logs api`

Si tous les points sont ✅, **le système fonctionne parfaitement** ! 🎉

---

## 📞 Besoin d'aide ?

1. **Vérifier les logs** : `docker-compose logs -f api`
2. **Redémarrer** : `docker-compose restart`
3. **Nettoyer et reconstruire** :
   ```powershell
   docker-compose down -v
   docker-compose up -d --build
   ```
4. **Consulter la doc** : README_v5.md, ARCHITECTURE.md

---

## 🚀 Prochaine étape

Une fois que l'API fonctionne, tu peux :
1. Générer des scripts pour différents profils
2. Tester les scripts sur des VM Windows
3. Créer l'interface web moderne
4. Ajouter de nouveaux modules d'optimisation

**Bon test ! 🎉**