# 🔌 Documentation API - PostBootSetup v5.0

> API REST Flask pour la génération de scripts PowerShell personnalisés

---

## 📋 Table des Matières

- [Introduction](#introduction)
- [Authentification](#authentification)
- [Endpoints](#endpoints)
- [Modèles de données](#modèles-de-données)
- [Exemples d'utilisation](#exemples-dutilisation)
- [Codes d'erreur](#codes-derreur)
- [Rate Limiting](#rate-limiting)

---

## Introduction

L'API PostBootSetup permet de générer des scripts PowerShell personnalisés via des requêtes HTTP.

### Informations générales

| Propriété | Valeur |
|-----------|--------|
| **Base URL** | `http://localhost:5000/api` (dev) |
| **Base URL Prod** | `https://postboot.tenorsolutions.com/api` |
| **Format** | JSON |
| **Charset** | UTF-8 |
| **Version** | 5.0 |

---

## Authentification

**Développement**: Aucune authentification requise

**Production**: À implémenter (JWT recommandé)

---

## Endpoints

### Health Check

Vérifier l'état de l'API.

```http
GET /api/health
```

#### Réponse

```json
{
  "status": "healthy",
  "version": "5.0",
  "timestamp": "2025-10-02T15:30:00Z",
  "ps2exe_available": false
}
```

**Codes de statut:**
- `200 OK` - Service opérationnel
- `503 Service Unavailable` - Service indisponible

---

### Générer un script

Génère un script PowerShell personnalisé.

```http
POST /api/generate
Content-Type: application/json
```

#### Corps de la requête

```json
{
  "computerName": "PC-USER-01",
  "profile_name": "DEV .NET",
  "description": "Poste développeur .NET",
  "apps": {
    "master": [
      "Chrome",
      "7zip",
      "Adobe Acrobat Reader",
      "VLC",
      "Teams",
      "Outlook",
      "Word",
      "Excel",
      "PowerPoint",
      "OneNote",
      "OneDrive"
    ],
    "profile": [
      "Visual Studio 2022",
      "SQL Server 2022 Express",
      "SSMS",
      "Git",
      "Postman"
    ],
    "optional": [
      "Python",
      "Node.js"
    ]
  },
  "modules": ["debloat", "performance", "ui"],
  "debloat": {
    "telemetry": true,
    "bloatware": true,
    "services": true,
    "features": true
  },
  "performance": {
    "visualEffects": true,
    "pageFile": true,
    "startupPrograms": true,
    "network": true,
    "powerPlan": "High performance"
  },
  "ui": {
    "taskbarPosition": "Bottom",
    "darkMode": true,
    "ShowFileExtensions": true,
    "ShowHiddenFiles": false,
    "ShowFullPath": true,
    "ShowThisPC": true,
    "ShowRecycleBin": true,
    "ShowUserFolder": false,
    "ShowNetwork": false
  }
}
```

#### Réponse

**Content-Type**: `text/plain; charset=utf-8`

Le script PowerShell complet (texte brut).

**Headers:**
```
Content-Disposition: attachment; filename="PostBootSetup_[ProfileName]_[ID].ps1"
X-Script-ID: 8d330415
X-Generated-Date: 2025-10-02T15:30:00Z
```

**Codes de statut:**
- `200 OK` - Script généré avec succès
- `400 Bad Request` - Erreur de validation
- `500 Internal Server Error` - Erreur serveur

---

### Lister les profils

Récupère la liste des profils prédéfinis.

```http
GET /api/profiles
```

#### Réponse

```json
{
  "profiles": [
    {
      "id": "dev-dotnet",
      "name": "DEV .NET",
      "description": "Configuration pour développeurs .NET",
      "apps_count": 20
    },
    {
      "id": "dev-windev",
      "name": "DEV WinDev",
      "description": "Configuration pour développeurs WinDev",
      "apps_count": 18
    },
    {
      "id": "tenor",
      "name": "TENOR",
      "description": "Configuration TENOR Projet & Support",
      "apps_count": 14
    },
    {
      "id": "si",
      "name": "SI",
      "description": "Configuration Admin Système",
      "apps_count": 22
    }
  ]
}
```

---

### Obtenir un profil spécifique

```http
GET /api/profiles/{profile_id}
```

#### Paramètres

| Paramètre | Type | Description |
|-----------|------|-------------|
| `profile_id` | string | ID du profil (ex: `dev-dotnet`) |

#### Réponse

```json
{
  "profile_name": "DEV .NET",
  "description": "Configuration pour développeurs .NET",
  "apps": {
    "master": [...],
    "profile": [...],
    "optional": []
  },
  "modules": ["debloat", "performance", "ui"],
  "debloat": {...},
  "performance": {...},
  "ui": {...}
}
```

---

### Lister les applications

Récupère le catalogue complet des applications disponibles.

```http
GET /api/apps
```

#### Paramètres de requête (optionnels)

| Paramètre | Type | Description |
|-----------|------|-------------|
| `category` | string | Filtrer par catégorie (`dev`, `productivity`, etc.) |

#### Réponse

```json
{
  "apps": [
    {
      "name": "Chrome",
      "category": "productivity",
      "command": "winget install --id Google.Chrome -e --accept-package-agreements",
      "description": "Navigateur web Google Chrome",
      "required_for_profiles": ["master"]
    },
    {
      "name": "Visual Studio 2022",
      "category": "dev",
      "command": "winget install --id Microsoft.VisualStudio.2022.Community -e",
      "description": "IDE pour développement .NET",
      "required_for_profiles": ["dev-dotnet"]
    }
  ],
  "total": 45,
  "categories": ["dev", "productivity", "security", "utilities", "media"]
}
```

---

### Valider une configuration

Valide une configuration sans générer de script.

```http
POST /api/validate
Content-Type: application/json
```

#### Corps de la requête

Même format que `/api/generate`

#### Réponse

```json
{
  "valid": true,
  "errors": [],
  "warnings": [
    "Le module 'performance' peut impacter la stabilité sur certains systèmes"
  ],
  "stats": {
    "total_apps": 18,
    "modules_enabled": 3,
    "estimated_duration_minutes": 35
  }
}
```

---

## Modèles de données

### Configuration complète

```typescript
interface ScriptConfig {
  computerName?: string;              // Nom du PC (optionnel)
  profile_name: string;               // Nom du profil
  description?: string;               // Description (optionnel)

  apps: {
    master: string[];                 // Apps master (11 obligatoires)
    profile: string[];                // Apps du profil
    optional?: string[];              // Apps optionnelles
  };

  modules: ("debloat" | "performance" | "ui")[];

  debloat?: {
    telemetry?: boolean;
    bloatware?: boolean;
    services?: boolean;
    features?: boolean;
  };

  performance?: {
    visualEffects?: boolean;
    pageFile?: boolean;
    startupPrograms?: boolean;
    network?: boolean;
    powerPlan?: "Balanced" | "High performance" | "Power saver";
  };

  ui?: {
    taskbarPosition?: "Bottom" | "Top" | "Left" | "Right";
    darkMode?: boolean;
    ShowFileExtensions?: boolean;
    ShowHiddenFiles?: boolean;
    ShowFullPath?: boolean;
    ShowThisPC?: boolean;
    ShowRecycleBin?: boolean;
    ShowUserFolder?: boolean;
    ShowNetwork?: boolean;
  };
}
```

### Application

```typescript
interface Application {
  name: string;                      // Nom affiché
  category: string;                  // Catégorie
  command: string;                   // Commande winget
  description: string;               // Description
  required_for_profiles?: string[];  // Profils requis
}
```

---

## Exemples d'utilisation

### cURL

```bash
# Générer un script
curl -X POST http://localhost:5000/api/generate \
  -H "Content-Type: application/json" \
  -d @config.json \
  --output PostBootSetup.ps1

# Lister les profils
curl http://localhost:5000/api/profiles

# Valider une configuration
curl -X POST http://localhost:5000/api/validate \
  -H "Content-Type: application/json" \
  -d @config.json
```

### PowerShell

```powershell
# Générer un script
$config = Get-Content config.json -Raw
Invoke-RestMethod -Uri "http://localhost:5000/api/generate" `
  -Method Post `
  -ContentType "application/json" `
  -Body $config `
  -OutFile "PostBootSetup.ps1"

# Lister les applications
$apps = Invoke-RestMethod -Uri "http://localhost:5000/api/apps"
$apps.apps | Format-Table name, category, description
```

### Python

```python
import requests
import json

# Charger la configuration
with open('config.json', 'r') as f:
    config = json.load(f)

# Générer le script
response = requests.post(
    'http://localhost:5000/api/generate',
    json=config,
    headers={'Content-Type': 'application/json'}
)

# Sauvegarder le script
if response.status_code == 200:
    with open('PostBootSetup.ps1', 'wb') as f:
        f.write(response.content)
    print("Script généré avec succès")
else:
    print(f"Erreur: {response.status_code}")
    print(response.json())
```

### JavaScript (Node.js)

```javascript
const axios = require('axios');
const fs = require('fs');

async function generateScript(config) {
  try {
    const response = await axios.post(
      'http://localhost:5000/api/generate',
      config,
      {
        headers: { 'Content-Type': 'application/json' },
        responseType: 'text'
      }
    );

    fs.writeFileSync('PostBootSetup.ps1', response.data);
    console.log('Script généré avec succès');
  } catch (error) {
    console.error('Erreur:', error.response?.data || error.message);
  }
}

// Charger et exécuter
const config = require('./config.json');
generateScript(config);
```

---

## Codes d'erreur

### Erreurs de validation (400)

```json
{
  "error": "Validation failed",
  "details": [
    {
      "field": "apps.master",
      "message": "11 applications master sont obligatoires, 9 fournies"
    }
  ]
}
```

### Erreurs serveur (500)

```json
{
  "error": "Script generation failed",
  "message": "Failed to load module Debloat-Windows.psm1",
  "timestamp": "2025-10-02T15:30:00Z"
}
```

### Limite atteinte (429)

```json
{
  "error": "Rate limit exceeded",
  "message": "Maximum 100 requests per hour",
  "retry_after": 3600
}
```

---

## Rate Limiting

| Environnement | Limite | Fenêtre |
|---------------|--------|---------|
| **Développement** | Illimité | - |
| **Production** | 100 requêtes | 1 heure |

**Headers de réponse:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1696252800
```

---

## Webhooks (À venir)

Notifications lors d'événements:
- Script généré avec succès
- Erreur de génération
- Nouvelle version disponible

---

## Liens utiles

- [🏠 Retour README](../README.md)
- [🚀 Guide Utilisateur](USER_GUIDE.md)
- [💻 Guide Développeur](DEVELOPER.md)

---

**© 2025 Tenor Data Solutions** - Documentation API PostBootSetup v5.0
