# PostBootSetup v5.0 - Architecture Modulaire

## Vue d'ensemble

PostBootSetup v5.0 est un système complet de génération dynamique de scripts d'installation et d'optimisation Windows. Le projet combine une interface web moderne, une API REST containerisée avec Docker, et un moteur de génération de scripts PowerShell autonomes.

## Fonctionnalités principales

### Pour l'utilisateur final
- Interface web intuitive pour personnaliser son installation
- Sélection granulaire des applications et optimisations
- Profils prédéfinis (DEV, SUPPORT, SI) ou création 100% personnalisée
- **Génération instantanée de scripts `.ps1` autonomes**
- Scripts totalement autonomes ne nécessitant aucune dépendance externe
- Téléchargement immédiat prêt à l'exécution

### Pour l'administrateur système
- Déploiement containerisé via Docker Compose
- API REST complète pour intégration CI/CD
- Système de logs et de monitoring
- Nettoyage automatique des fichiers générés
- Compatible Linux (Docker) et Windows (développement local)

> **Note sur la compilation .exe** : La génération d'exécutables Windows (.exe) nécessite Windows PowerShell (`powershell.exe`) et n'est pas disponible dans les conteneurs Docker Linux. Les scripts .ps1 générés sont directement exécutables sur Windows avec les mêmes fonctionnalités.

### Optimisations incluses
- **Debloat Windows** (obligatoire) : Suppression bloatware, désactivation télémétrie
- **Performance** (optionnel) : Effets visuels, pagefile, réseau, plan d'alimentation
- **Interface** (optionnel) : Mode sombre, barre des tâches, explorateur, thème

## Architecture du projet

```
PostBoot/
├── config/                  # Fichiers de configuration JSON
│   ├── apps.json           # Définition des applications
│   └── settings.json       # Configuration des modules d'optimisation
│
├── modules/                 # Modules PowerShell réutilisables
│   ├── Debloat-Windows.psm1      # Nettoyage Windows (obligatoire)
│   ├── Optimize-Performance.psm1  # Optimisations performance
│   └── Customize-UI.psm1          # Personnalisation interface
│
├── generator/               # API de génération (Python Flask)
│   ├── app.py              # API REST principale
│   └── requirements.txt    # Dépendances Python
│
├── templates/               # Templates de scripts
│   └── main_template.ps1   # Template de base pour génération
│
├── web/                     # Interface web frontend
│   ├── index.html          # Page principale
│   ├── advanced.html       # Interface personnalisation avancée
│   └── app.js              # Logique JavaScript
│
├── generated/               # Scripts générés (créé automatiquement)
│
├── Dockerfile               # Image Docker de l'API
├── docker-compose.yml       # Orchestration des containers
├── nginx.conf               # Configuration du serveur web
│
├── PostBootSetup_v5.ps1     # Script orchestrateur local
└── ARCHITECTURE.md          # Documentation technique complète
```

## Installation et démarrage

### Prérequis

**Pour le serveur (Docker) :**
- Docker Engine 20.10+
- Docker Compose 2.0+
- 2 GB RAM minimum
- 10 GB espace disque

**Pour l'exécution des scripts générés (Windows) :**
- Windows 10 (1809+) ou Windows 11
- PowerShell 5.1+
- Winget (App Installer)
- Droits administrateur

### Démarrage avec Docker

1. **Cloner le projet**
   ```bash
   git clone <repository_url>
   cd PostBoot
   ```

2. **Construire et démarrer les containers**
   ```bash
   docker-compose up -d --build
   ```

3. **Vérifier le statut**
   ```bash
   docker-compose ps
   docker-compose logs -f api
   ```

4. **Accéder à l'interface**
   - Interface web : http://localhost
   - API : http://localhost:5000
   - Health check : http://localhost:5000/api/health

### Arrêt et nettoyage

```bash
# Arrêter les containers
docker-compose down

# Arrêter et supprimer les volumes
docker-compose down -v

# Nettoyer les fichiers générés
rm -rf generated/*
```

## Utilisation de l'API

### Endpoints disponibles

#### 1. Vérification de santé
```bash
GET /api/health

Réponse :
{
  "status": "healthy",
  "version": "5.0",
  "timestamp": "2025-10-01T12:34:56",
  "ps2exe_available": true
}
```

#### 2. Liste des profils
```bash
GET /api/profiles

Réponse :
{
  "success": true,
  "profiles": [
    {
      "id": "DEV",
      "name": "Développeur",
      "description": "Outils de développement",
      "apps_count": 5
    },
    ...
  ]
}
```

#### 3. Liste des applications
```bash
GET /api/apps

Réponse :
{
  "success": true,
  "apps": {
    "master": [...],
    "profiles": {...},
    "optional": [...]
  }
}
```

#### 4. Liste des modules
```bash
GET /api/modules

Réponse :
{
  "success": true,
  "modules": {
    "debloat": {...},
    "performance": {...},
    "ui": {...}
  }
}
```

#### 5. Générer un script PowerShell
```bash
POST /api/generate/script
Content-Type: application/json

Body :
{
  "profile_name": "DEV",
  "apps": {
    "master": [...],
    "profile": [...]
  },
  "modules": ["debloat", "performance"],
  "performance_options": {
    "PageFile": true,
    "PowerPlan": true
  }
}

Réponse :
{
  "success": true,
  "script_id": "a1b2c3d4-...",
  "filename": "PostBootSetup_DEV_a1b2c3d4.ps1",
  "size": 125430,
  "download_url": "/api/download/a1b2c3d4"
}
```

#### 6. Générer un exécutable
```bash
POST /api/generate/executable
Content-Type: application/json

Body : (identique à /generate/script)

Réponse :
{
  "success": true,
  "script_id": "a1b2c3d4-...",
  "filename": "PostBootSetup_DEV_a1b2c3d4.exe",
  "size": 2456789,
  "download_url": "/api/download/a1b2c3d4"
}
```

#### 7. Télécharger un fichier généré
```bash
GET /api/download/{script_id}

Réponse : Fichier binaire (.ps1 ou .exe)
```

## Configuration personnalisée

### Ajouter des applications

Éditer `config/apps.json` :

```json
{
  "master": [
    {
      "name": "Nouvelle App",
      "winget": "Publisher.AppName",
      "size": "100 MB",
      "category": "Utilitaires",
      "required": true
    }
  ]
}
```

### Ajouter un nouveau module d'optimisation

1. Créer le module PowerShell dans `modules/` :

```powershell
# modules/Mon-Module.psm1

function Invoke-MonOptimisation {
    param([hashtable]$Options)

    Write-Host "Exécution de mon optimisation..."
    # Votre code ici
}

Export-ModuleMember -Function 'Invoke-MonOptimisation'
```

2. Référencer dans `config/settings.json` :

```json
{
  "modules": {
    "mon_module": {
      "name": "Mon Module",
      "module": "Mon-Module",
      "function": "Invoke-MonOptimisation",
      "description": "Description de mon module",
      "required": false,
      "recommended": false,
      "enabled": false,
      "category": "custom",
      "options": {}
    }
  }
}
```

3. Le module sera automatiquement disponible dans l'API et l'interface web.

## Workflow utilisateur complet

### Via l'interface web

1. **Accéder à l'interface** : http://localhost
2. **Sélectionner un profil** ou créer un profil personnalisé
3. **Cocher les applications** désirées (master + profil + optionnelles)
4. **Activer les modules** d'optimisation souhaités
5. **Configurer les options** détaillées de chaque module
6. **Prévisualiser** la configuration
7. **Générer** le fichier (.ps1 ou .exe)
8. **Télécharger** le fichier
9. **Exécuter** sur le poste Windows cible en tant qu'administrateur

### Via l'API directement

```bash
# Exemple avec curl
curl -X POST http://localhost:5000/api/generate/script \
  -H "Content-Type: application/json" \
  -d '{
    "profile_name": "Custom",
    "apps": {
      "master": [...],
      "profile": [...]
    },
    "modules": ["debloat", "performance"],
    "performance_options": {
      "PageFile": true
    }
  }' \
  > response.json

# Extraire l'URL de téléchargement
DOWNLOAD_URL=$(jq -r '.download_url' response.json)

# Télécharger le script
curl http://localhost:5000$DOWNLOAD_URL -o MonScript.ps1
```

## Exécution locale sans Docker

Si tu veux tester le script orchestrateur localement sans passer par Docker :

```powershell
# Exécution interactive
.\PostBootSetup_v5.ps1

# Profil spécifique en mode silencieux
.\PostBootSetup_v5.ps1 -UserProfile "DEV" -Silent

# Ignorer certaines étapes
.\PostBootSetup_v5.ps1 -SkipDebloat -SkipOptimizations

# Avec log personnalisé
.\PostBootSetup_v5.ps1 -LogPath "C:\Logs\install.log"
```

## Sécurité et bonnes pratiques

### Validation des entrées
- Nombre d'applications limité à 50 par script
- Taille maximale du script : 10 MB
- Timeout de génération : 60 secondes
- Validation des URLs d'applications custom

### Rate limiting
- 20 générations par IP par heure (configurable)
- Nettoyage automatique des fichiers de plus de 24h

### Logs et audit
- Tous les événements sont loggés dans `logs/generator.log`
- Chaque génération enregistre l'IP source et le timestamp
- Les fichiers générés sont horodatés et traçables

### Recommandations production
- Utiliser HTTPS avec certificats SSL (décommenter dans nginx.conf)
- Configurer un reverse proxy (Traefik, Caddy) pour le SSL automatique
- Implémenter une authentification (OAuth2, JWT) pour l'accès à l'API
- Sauvegarder régulièrement les configurations dans `config/`
- Monitorer les ressources Docker (CPU, RAM, disque)

## Dépannage

### L'API ne démarre pas
```bash
# Vérifier les logs
docker-compose logs api

# Vérifier que les ports ne sont pas déjà utilisés
netstat -an | grep 5000

# Reconstruire l'image
docker-compose build --no-cache api
docker-compose up -d api
```

### PS2EXE ne fonctionne pas
```bash
# Vérifier l'installation dans le container
docker-compose exec api pwsh -Command "Get-Module -ListAvailable -Name ps2exe"

# Réinstaller PS2EXE
docker-compose exec api pwsh -Command "Install-Module -Name ps2exe -Force"
```

### Les fichiers générés ne se téléchargent pas
```bash
# Vérifier les permissions du dossier generated/
ls -la generated/

# Vérifier que le volume est bien monté
docker-compose exec api ls -la /app/generated/
```

### L'interface web ne charge pas
```bash
# Vérifier Nginx
docker-compose logs web

# Tester directement l'API
curl http://localhost:5000/api/health

# Vérifier la configuration Nginx
docker-compose exec web nginx -t
```

## Développement et contribution

### Lancer en mode développement

```bash
# API Flask en mode debug
cd generator
python app.py

# L'API se recharge automatiquement à chaque modification
```

### Tests

```bash
# Tester la génération d'un script
curl -X POST http://localhost:5000/api/generate/script \
  -H "Content-Type: application/json" \
  -d @test_config.json

# Tester la santé de l'API
curl http://localhost:5000/api/health
```

### Structure de tests recommandée

```
tests/
├── test_api.py          # Tests unitaires de l'API
├── test_generator.py    # Tests du moteur de génération
├── test_modules.ps1     # Tests PowerShell des modules
└── configs/
    ├── test_dev.json
    ├── test_support.json
    └── test_custom.json
```

## Roadmap

### Version 5.1 (Q1 2026)
- [ ] Authentification utilisateur (OAuth2)
- [ ] Historique des scripts générés par utilisateur
- [ ] Partage de profils entre utilisateurs

### Version 5.2 (Q2 2026)
- [ ] Marketplace de modules communautaires
- [ ] Vote et notation des modules
- [ ] Télémétrie anonyme post-installation

### Version 6.0 (Q3 2026)
- [ ] Support Windows Server
- [ ] Interface multi-langue (FR, EN, ES)
- [ ] API GraphQL en complément REST
- [ ] Intégration Active Directory

## Support et contact

- **Documentation complète** : Voir [ARCHITECTURE.md](ARCHITECTURE.md)
- **Issues** : Créer une issue sur le dépôt Git
- **Email** : si@tenorsolutions.com
- **Site web** : https://tenorsolutions.com

## Licence

© 2025 Tenor Data Solutions - Tous droits réservés

Usage interne uniquement. Distribution et modification soumises à autorisation.

---

**Généré par PostBootSetup Generator v5.0**
*Tenor Data Solutions - Service IT*