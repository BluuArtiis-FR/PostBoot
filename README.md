<div align="center">

# 🚀 PostBootSetup v5.0

**Générateur de Scripts d'Installation et Configuration Windows**

[![Version](https://img.shields.io/badge/version-5.0-blue.svg)](https://github.com/BluuArtiis-FR/PostBoot)
[![Docker](https://img.shields.io/badge/docker-ready-brightgreen.svg)](https://www.docker.com/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![License](https://img.shields.io/badge/license-Internal-red.svg)](LICENSE)

*Interface web moderne pour créer des scripts PowerShell personnalisés d'installation d'applications et d'optimisation Windows*

[🎯 Démarrage Rapide](#-démarrage-rapide) •
[📖 Documentation](#-documentation) •
[🏗️ Architecture](#️-architecture) •
[🛠️ Utilisation](#️-utilisation) •
[🤝 Contribution](#-contribution)

![PostBootSetup Banner](assets/screenshot.png)

</div>

---

## 📋 Table des Matières

- [🎯 Démarrage Rapide](#-démarrage-rapide)
- [✨ Fonctionnalités](#-fonctionnalités)
- [🏗️ Architecture](#️-architecture)
- [📖 Documentation](#-documentation)
- [🛠️ Utilisation](#️-utilisation)
- [🎨 Profils Disponibles](#-profils-disponibles)
- [🔧 Configuration](#-configuration)
- [🧪 Tests & Validation](#-tests--validation)
- [🤝 Contribution](#-contribution)
- [📞 Support](#-support)

---

## 🎯 Démarrage Rapide

### Prérequis

- **Docker** 20.10+ & **Docker Compose** 2.0+
- **Windows 10+** ou **Debian 12** (production)
- **Git** (pour clonage du dépôt)

### Installation en 3 étapes

```bash
# 1. Cloner le projet
git clone https://github.com/BluuArtiis-FR/PostBoot.git
cd PostBoot

# 2. Lancer l'application
docker-compose up -d

# 3. Accéder à l'interface
# Frontend: http://localhost:8080
# API: http://localhost:5000
```

### Vérification santé

```bash
# Vérifier que les conteneurs sont démarrés
docker ps

# Tester l'API
curl http://localhost:5000/api/health

# Consulter les logs
docker-compose logs -f
```

---

## ✨ Fonctionnalités

<table>
<tr>
<td width="33%">

### 🎯 **Installation**
- 40+ applications disponibles
- 5 profils prédéfinis
- Sélection personnalisée
- 11 apps Master obligatoires

</td>
<td width="33%">

### ⚡ **Optimisations**
- Debloat Windows (obligatoire)
- Optimisations Performance
- Personnalisation UI
- Compatible PS 5.1+

</td>
<td width="33%">

### 📊 **Diagnostic**
- Rapport HTML détaillé
- État système complet
- Détection de problèmes
- Export JSON

</td>
</tr>
</table>

### Architecture 3 Espaces

```mermaid
graph LR
    A[1️⃣ Installation] --> B[2️⃣ Optimisations]
    B --> C[3️⃣ Diagnostic]
    C --> D[Script PowerShell]
```

1. **Installation** : Sélection profil + applications
2. **Optimisations** : Debloat, Performance, UI
3. **Diagnostic** : Rapport HTML de l'état système

---

## 🏗️ Architecture

### Stack Technique

| Composant | Technologie | Version |
|-----------|-------------|---------|
| **Frontend** | React + Vite | 18.3.1 |
| **UI Framework** | Tailwind CSS | 3.4.17 |
| **Backend** | Flask (Python) | 3.11 |
| **Scripts** | PowerShell | 5.1+ |
| **Conteneurs** | Docker Compose | 2.0+ |
| **Proxy** | Nginx | Latest |

### Structure du Projet

```
PostBootSetup/
├── 📁 web/                  # Frontend React
│   ├── src/
│   │   ├── pages/          # Pages (Home, Installation, Optimizations)
│   │   ├── components/     # Composants réutilisables
│   │   ├── context/        # State management (Context API)
│   │   └── services/       # API calls
│   └── Dockerfile
│
├── 📁 generator/            # Backend Flask
│   └── app.py              # API principale de génération
│
├── 📁 config/               # Configuration
│   ├── apps.json           # Catalogue 40+ applications
│   ├── settings.json       # Paramètres optimisations
│   └── profiles/           # Profils prédéfinis
│
├── 📁 modules/              # Modules PowerShell
│   ├── Debloat-Windows.psm1
│   ├── Optimize-Performance.psm1
│   └── Customize-UI.psm1
│
├── 📁 templates/            # Templates PowerShell
│   └── main_template.ps1   # Template principal
│
├── 📁 docs/                 # Documentation
│   ├── USER_GUIDE.md       # Guide utilisateur
│   ├── DEVELOPER.md        # Guide développeur
│   └── API.md              # Documentation API
│
├── 📁 generated/            # Scripts générés (gitignored)
├── 📁 logs/                 # Logs application
│
├── docker-compose.yml       # Dev local
├── docker-compose.prod.yml  # Production
├── ValidateScript.ps1       # Validation PowerShell
└── README.md               # Ce fichier
```

Voir [STRUCTURE.md](STRUCTURE.md) pour une description détaillée.

---

## 📖 Documentation

### 📚 Guides Utilisateur

| Document | Description |
|----------|-------------|
| [🚀 Guide Utilisateur](docs/USER_GUIDE.md) | Utilisation de l'interface web |
| [💻 Guide Développeur](docs/DEVELOPER.md) | Architecture & développement |
| [🔌 Documentation API](docs/API.md) | Endpoints et intégrations |
| [🎯 Profils & Optimisations](PROFILS_ET_OPTIMISATIONS.md) | Catalogue complet |

### 🏗️ Documentation Technique

| Document | Description |
|----------|-------------|
| [📐 Architecture](ARCHITECTURE.md) | Architecture détaillée du système |
| [🚢 Déploiement](DEPLOIEMENT.md) | Guide de déploiement production |
| [🐧 Déploiement Debian 12](DEPLOIEMENT_DEBIAN12.md) | Spécifique Debian |
| [📝 Changelog](CHANGELOG.md) | Historique des versions |
| [🆘 Aide](AIDE.md) | FAQ et dépannage |

---

## 🛠️ Utilisation

### Interface Web

1. **Accéder** à http://localhost:8080
2. **Sélectionner** un profil ou créer une configuration personnalisée
3. **Choisir** les applications à installer
4. **Configurer** les optimisations (Debloat, Performance, UI)
5. **Générer** le script PowerShell
6. **Télécharger** et exécuter sur la machine cible

### API REST

```bash
# Générer un script via l'API
curl -X POST http://localhost:5000/api/generate \
  -H "Content-Type: application/json" \
  -d @config/profiles/tenor.json \
  --output PostBootSetup_Generated.ps1

# Valider le script généré
powershell -ExecutionPolicy Bypass -File ValidateScript.ps1 -ScriptPath "PostBootSetup_Generated.ps1"
```

### Exécution du Script

```powershell
# Sur la machine cible Windows
# Exécuter en tant qu'Administrateur

.\PostBootSetup_Generated.ps1

# Mode silencieux
.\PostBootSetup_Generated.ps1 -Silent

# Sans optimisations Debloat
.\PostBootSetup_Generated.ps1 -NoDebloat
```

---

## 🎨 Profils Disponibles

| Profil | Description | Applications clés | Use Case |
|--------|-------------|-------------------|----------|
| **💻 DEV .NET** | Développeur .NET | Visual Studio, SQL Server, Git, Postman, Python | Développement .NET/C# |
| **🎯 DEV WinDev** | Développeur WinDev | WinDev, SQL Server, Git, Apps métier | Développement WinDev |
| **🏢 TENOR** | Projet & Support | eCarAdmin, EDI, Gestion Temps | Postes TENOR |
| **🔧 SI** | Admin Système | Git, SSMS, DBeaver, Wireshark, Nmap | Administration système |
| **⚙️ Personnalisé** | Sur mesure | Sélection manuelle | Configuration spécifique |

Voir [PROFILS_ET_OPTIMISATIONS.md](PROFILS_ET_OPTIMISATIONS.md) pour le catalogue complet.

---

## 🔧 Configuration

### Variables d'environnement

#### Développement Local
```bash
# Aucune configuration requise
# L'API est accessible sur http://localhost:5000
```

#### Production
```bash
# web/.env
VITE_API_URL=https://postboot.tenorsolutions.com/api
```

### Personnalisation

#### Ajouter une Application

Éditer `config/apps.json`:

```json
{
  "name": "MonApp",
  "category": "dev",
  "command": "winget install --id MonApp.ID -e --accept-package-agreements --accept-source-agreements",
  "description": "Description de l'application"
}
```

#### Ajouter un Profil

Créer `config/profiles/mon-profil.json`:

```json
{
  "profile_name": "Mon Profil",
  "description": "Description du profil",
  "apps": {
    "master": [...],
    "profile": [...]
  }
}
```

---

## 🧪 Tests & Validation

### Validation des Scripts

```powershell
# Valider la syntaxe PowerShell
.\ValidateScript.ps1 -ScriptPath ".\generated\script.ps1"
```

### Tests Unitaires

```bash
# Backend (Python)
cd generator
pytest tests/

# Frontend (React)
cd web
npm run test
```

### Tests d'Intégration

```bash
# Tester la génération complète
curl -X POST http://localhost:5000/api/generate \
  -H "Content-Type: application/json" \
  -d '{"profile":"tenor","modules":["debloat","performance"]}' \
  --output test.ps1

# Valider
powershell -File ValidateScript.ps1 -ScriptPath "test.ps1"
```

---

## 🤝 Contribution

### Workflow Git

```bash
# 1. Créer une branche feature
git checkout -b feature/ma-fonctionnalite

# 2. Développer et tester

# 3. Commit (conventional commits)
git add .
git commit -m "feat: ajout de ma fonctionnalité"

# 4. Push
git push origin feature/ma-fonctionnalite

# 5. Créer une Pull Request sur GitHub
```

### Conventions de Commit

- `feat:` Nouvelle fonctionnalité
- `fix:` Correction de bug
- `docs:` Documentation
- `refactor:` Refactoring
- `chore:` Tâches maintenance
- `test:` Tests

Voir [CONTRIBUTING.md](docs/CONTRIBUTING.md) pour plus de détails.

---

## 📞 Support

### Contact

- **Email Support** : [si@tenorsolutions.com](mailto:si@tenorsolutions.com)
- **Documentation Interne** : `\\tenor.local\data\Déploiement\SI\PostBootSetup\`
- **GitHub Issues** : [Créer un ticket](https://github.com/BluuArtiis-FR/PostBoot/issues)

### Liens Utiles

- [🆘 FAQ & Dépannage](AIDE.md)
- [🔧 Guide de Dépannage](docs/TROUBLESHOOTING.md)
- [📖 Documentation Complète](docs/)
- [📝 Changelog](CHANGELOG.md)
- [🏗️ Architecture](ARCHITECTURE.md)

---

## 📝 License

**© 2025 Tenor Data Solutions**

Usage interne uniquement. Tous droits réservés.

---

<div align="center">

**PostBootSetup v5.0** - *Simplifiez vos installations Windows*

Made with ❤️ by Tenor Data Solutions SI Team

[⬆ Retour en haut](#-postbootsetup-v50)

</div>
