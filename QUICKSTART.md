# Guide de démarrage rapide - PostBootSetup v5.0

## Installation en 5 minutes

### Prérequis
- Docker et Docker Compose installés
- 2 GB RAM disponible
- Ports 80 et 5000 disponibles

### Étapes

#### 1. Cloner et accéder au projet
```bash
git clone <repository_url>
cd PostBoot
```

#### 2. Rendre les scripts exécutables (Linux/Mac)
```bash
chmod +x start.sh test_api.sh
```

#### 3. Démarrer l'application
```bash
./start.sh
```

Ou manuellement :
```bash
docker-compose up -d --build
```

#### 4. Vérifier que tout fonctionne
```bash
# Vérifier la santé de l'API
curl http://localhost:5000/api/health

# Résultat attendu :
# {
#   "status": "healthy",
#   "version": "5.0",
#   "ps2exe_available": true
# }
```

#### 5. Accéder à l'interface
Ouvrir dans le navigateur : **http://localhost**

## Test rapide de l'API

### Tester avec le fichier d'exemple

```bash
# Générer un script de test
curl -X POST http://localhost:5000/api/generate/script \
  -H "Content-Type: application/json" \
  -d @test_config_example.json \
  -o response.json

# Voir le résultat
cat response.json | jq .

# Extraire l'URL de téléchargement
DOWNLOAD_URL=$(cat response.json | jq -r '.download_url')

# Télécharger le script généré
curl http://localhost:5000$DOWNLOAD_URL -o MonScript.ps1

# Vérifier le contenu
head -n 50 MonScript.ps1
```

### Ou utiliser le script de test automatique

```bash
./test_api.sh
```

## Workflow utilisateur complet

### Scénario : Installer un poste développeur

1. **Accéder à l'interface web** : http://localhost

2. **Sélectionner le profil DEV** ou créer un profil custom

3. **Cocher les applications** :
   - ✅ Master (Office, Teams, Notepad++, etc.)
   - ✅ Profil DEV (VS Code, Git, Postman, etc.)
   - ✅ Optionnelles (7-Zip, VLC, etc.)

4. **Activer les modules** :
   - ✅ Debloat Windows (obligatoire)
   - ✅ Optimisations Performance
   - ⬜ Personnalisation UI (optionnel)

5. **Configurer les options** :
   - Performance : PageFile ✅, PowerPlan ✅
   - UI : DarkMode ✅, ShowFileExtensions ✅

6. **Générer** le fichier :
   - Cliquer sur "Générer Script .ps1" ou "Générer Exécutable .exe"

7. **Télécharger** le fichier généré

8. **Sur le poste Windows cible** :
   ```powershell
   # Clic droit > Exécuter en tant qu'administrateur
   # Ou en ligne de commande :
   powershell -ExecutionPolicy Bypass -File .\MonScript.ps1
   ```

## Exemples de configurations JSON

### Configuration minimale (Debloat uniquement)

```json
{
  "profile_name": "Minimal",
  "apps": {
    "master": [],
    "profile": []
  },
  "modules": ["debloat"],
  "debloat_required": true
}
```

### Configuration complète (Tout activé)

```json
{
  "profile_name": "Complete",
  "apps": {
    "master": [
      {"name": "Microsoft Office 365", "winget": "Microsoft.Office"},
      {"name": "Microsoft Teams", "winget": "Microsoft.Teams"}
    ],
    "profile": [
      {"name": "Visual Studio Code", "winget": "Microsoft.VisualStudioCode"},
      {"name": "Git", "winget": "Git.Git"}
    ]
  },
  "modules": ["debloat", "performance", "ui"],
  "performance_options": {
    "PageFile": true,
    "PowerPlan": true,
    "StartupPrograms": true
  },
  "ui_options": {
    "DarkMode": true,
    "ShowFileExtensions": true,
    "ShowThisPC": true
  }
}
```

### Tester ces configurations

```bash
# Sauvegarder dans un fichier
cat > ma_config.json << 'EOF'
{
  "profile_name": "MonProfil",
  ...
}
EOF

# Générer le script
curl -X POST http://localhost:5000/api/generate/script \
  -H "Content-Type: application/json" \
  -d @ma_config.json \
  -o response.json

# Télécharger
curl http://localhost:5000$(cat response.json | jq -r '.download_url') \
  -o MonScript.ps1
```

## Commandes Docker utiles

### Voir les logs en temps réel
```bash
docker-compose logs -f api
docker-compose logs -f web
```

### Redémarrer un service
```bash
docker-compose restart api
docker-compose restart web
```

### Arrêter tout
```bash
docker-compose down
```

### Nettoyer complètement
```bash
docker-compose down -v
rm -rf generated/* logs/*
```

### Reconstruire l'image
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Accéder au shell du container
```bash
docker-compose exec api bash
docker-compose exec api pwsh
```

## Dépannage rapide

### L'API ne répond pas
```bash
# Vérifier les logs
docker-compose logs api

# Vérifier que le container tourne
docker-compose ps

# Redémarrer
docker-compose restart api
```

### Port déjà utilisé
```bash
# Vérifier quel processus utilise le port 5000
lsof -i :5000  # Linux/Mac
netstat -ano | findstr :5000  # Windows

# Modifier le port dans docker-compose.yml
ports:
  - "5001:5000"  # Utiliser 5001 au lieu de 5000
```

### PS2EXE ne fonctionne pas
```bash
# Vérifier l'installation dans le container
docker-compose exec api pwsh -Command "Get-Module -ListAvailable -Name ps2exe"

# Réinstaller si nécessaire
docker-compose exec api pwsh -Command "Install-Module -Name ps2exe -Force"
```

### Les fichiers générés ne sont pas visibles
```bash
# Vérifier les permissions
ls -la generated/

# Donner les permissions si nécessaire
chmod 755 generated/

# Vérifier le volume Docker
docker-compose exec api ls -la /app/generated/
```

## Personnalisation rapide

### Ajouter une application à un profil

Éditer `config/apps.json` :

```json
{
  "profiles": {
    "DEV": {
      "apps": [
        {
          "name": "Ma Nouvelle App",
          "winget": "Publisher.AppName",
          "size": "100 MB"
        }
      ]
    }
  }
}
```

Redémarrer l'API :
```bash
docker-compose restart api
```

### Modifier les modules d'optimisation

Éditer `config/settings.json` puis redémarrer :
```bash
docker-compose restart api
```

## Passer en production

### Checklist

- [ ] Configurer HTTPS (décommenter dans nginx.conf)
- [ ] Ajouter une authentification à l'API
- [ ] Configurer un domaine personnalisé
- [ ] Mettre en place un système de backup des configs
- [ ] Activer le rate limiting
- [ ] Configurer les logs persistants
- [ ] Monitorer les ressources (CPU, RAM, disque)

### Configuration HTTPS rapide avec Let's Encrypt

```bash
# Installer certbot
apt-get install certbot python3-certbot-nginx

# Obtenir un certificat
certbot --nginx -d votredomaine.com

# Le renouvellement automatique est configuré
```

## Support

- **Documentation** : [README_v5.md](README_v5.md)
- **Architecture** : [ARCHITECTURE.md](ARCHITECTURE.md)
- **Email** : si@tenorsolutions.com

---

Maintenant vous pouvez commencer à utiliser PostBootSetup v5.0 ! 🚀
