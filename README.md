<div align="center">

# 🚀 PostBootSetup v5.2

**Générateur de Scripts d'Installation et Configuration Windows**

[![Version](https://img.shields.io/badge/version-5.2-blue.svg)](https://github.com/TenorDataSolutions/PostBoot)
[![Docker](https://img.shields.io/badge/docker-ready-brightgreen.svg)](https://www.docker.com/)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![License](https://img.shields.io/badge/license-Internal-red.svg)](LICENSE)

*Interface web React + Backend Flask pour créer des scripts PowerShell personnalisés d'installation et optimisation Windows*

[🎯 Démarrage Rapide](#-démarrage-rapide) •
[📖 Documentation](#-documentation) •
[✨ Nouveautés v5.2](#-nouveautés-v52) •
[🛠️ Utilisation](#️-utilisation)

</div>

---

## 📋 Table des Matières

- [🎯 Démarrage Rapide](#-démarrage-rapide)
- [✨ Nouveautés v5.2](#-nouveautés-v52)
- [🏗️ Architecture](#️-architecture)
- [📖 Documentation](#-documentation)
- [🛠️ Utilisation](#️-utilisation)
- [🎨 Profils Disponibles](#-profils-disponibles)
- [🔧 Configuration](#-configuration)
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
git clone https://github.com/TenorDataSolutions/PostBoot.git
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

## ✨ Nouveautés v5.2

### 🆕 Fonctionnalités Majeures

| Feature | Description | Status |
|---------|-------------|---------|
| **🌐 PWA Edge** | Installation native Progressive Web Apps (VAULT, DOCS) avec favicons automatiques | ✅ |
| **🔒 VPN Stormshield** | Import automatique AddressBook (2 VPN: Lyon + Paris) via `sslvpn-cli.exe` | ✅ |
| **📦 MSI Auto-Detection** | Détection automatique `.msi` et utilisation de `msiexec.exe` | ✅ |
| **🧹 Nettoyage Win11 25H2** | Nettoyage épinglages menu Démarrer/barre tâches (Build 26xxx) | ✅ |
| **📝 WinSCP** | Remplacement de FileZilla par WinSCP dans tous les profils | ✅ |

### 🔧 Améliorations Techniques

- ✅ **Validation fichiers** - Magic bytes check (détection HTML vs EXE/MSI)
- ✅ **Avast correction** - Arguments MSI corrigés (`/qn` au lieu de `/silent`)
- ✅ **Web Apps nommées** - VAULT et DOCS (anciennement "Tenor Password/Docs")
- ✅ **Stormshield CLI** - Chemin corrigé pour v5.1.2+ (`Modules\ssl-vpn\Services\`)

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
├── 📁 web/                     # Frontend React
│   ├── src/
│   │   ├── pages/             # Pages (Home, Installation, Optimizations)
│   │   ├── components/        # Composants réutilisables
│   │   ├── context/           # State management (ConfigContext)
│   │   └── services/          # API calls
│   └── Dockerfile
│
├── 📁 generator/               # Backend Flask
│   └── app.py                 # API de génération PowerShell
│
├── 📁 config/                  # Configuration
│   ├── apps.json              # Catalogue 40+ applications
│   └── settings.json          # Paramètres optimisations
│
├── 📁 modules/                 # Modules PowerShell
│   ├── Debloat-Windows.psm1   # Nettoyage Windows (obligatoire)
│   ├── Optimize-Performance.psm1
│   └── Customize-UI.psm1      # UI + épinglages
│
├── 📁 templates/               # Templates PowerShell
│   └── main_template.ps1      # Template principal
│
├── 📁 docs/                    # Documentation complète
│   ├── USER_GUIDE.md
│   ├── DEVELOPER.md
│   └── API.md
│
├── 📁 generated/               # Scripts générés (gitignored)
├── 📁 logs/                    # Logs application
│
├── docker-compose.yml          # Dev local
├── docker-compose.prod.yml     # Production
└── README.md                  # Ce fichier
```

Voir [STRUCTURE.md](STRUCTURE.md) pour une description détaillée.

---

## 📖 Documentation

### 📚 Guides Utilisateur

| Document | Description |
|----------|-------------|
| [🚀 Guide Utilisateur](docs/USER_GUIDE.md) | Interface web & utilisation |
| [💻 Guide Développeur](docs/DEVELOPER.md) | Architecture & développement |
| [🔌 Documentation API](docs/API.md) | Endpoints REST |
| [🎯 Profils & Optimisations](PROFILS_ET_OPTIMISATIONS.md) | Catalogue complet |

### 🏗️ Documentation Technique

| Document | Description |
|----------|-------------|
| [📐 Architecture](ARCHITECTURE.md) | Architecture système détaillée |
| [🚢 Déploiement](DEPLOIEMENT.md) | Guide production |
| [🐧 Déploiement Debian 12](DEPLOIEMENT_DEBIAN12.md) | Spécifique Debian |
| [📝 Changelog](CHANGELOG.md) | Historique des versions |
| [🆘 Aide](AIDE.md) | FAQ et dépannage |

---

## 🛠️ Utilisation

### Interface Web

1. **Accéder** à http://localhost:8080
2. **Sélectionner** un profil (DEV .NET, WinDev, TENOR, SI, Custom)
3. **Choisir** les applications à installer
4. **Configurer** les optimisations:
   - ✅ **Debloat Windows** (obligatoire) - Nettoyage bloatware
   - ⚡ **Optimisations Performance** - CPU, RAM, réseau
   - 🎨 **Personnalisation UI** - Thème, menu démarrer, fond d'écran
5. **Générer** le script PowerShell
6. **Télécharger** `PostBootSetup_Generated.ps1`
7. **Exécuter** sur la machine cible

### API REST

```bash
# Générer un script via l'API
curl -X POST http://localhost:5000/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "profile": "SI",
    "apps": {
      "master": true,
      "profile": ["git", "python", "docker"]
    },
    "modules": ["debloat", "performance", "ui_customization"]
  }' \
  --output PostBootSetup_Generated.ps1
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
| **💻 DEV .NET** | Développeur .NET | Visual Studio Code, Git, Python, DBeaver, Postman | Développement .NET/C# |
| **🎯 DEV WinDev** | Développeur WinDev | eCarAdmin, EDI Translator, SQL Server, WinSCP | Développement WinDev |
| **🏢 TENOR** | Projet & Support | eCarAdmin, EDI, Gestion Temps, Cegid PMI | Postes TENOR |
| **🔧 SI** | Admin Système | Wireshark, Nmap, Advanced IP Scanner, Terraform, AWS CLI | Administration système |
| **⚙️ Personnalisé** | Sur mesure | Sélection manuelle 40+ apps | Configuration spécifique |

### 🌟 Applications Master (obligatoires)

- Microsoft Office 365 (inclut OneDrive Entreprise)
- Microsoft Teams
- Notepad++
- Visual Studio Code
- Flameshot (capture d'écran)
- VPN Stormshield (2 VPN: Lyon + Paris)
- Microsoft PowerToys
- PDF Gear
- Winget
- 7-Zip
- **VAULT** (PWA Tenor Password Manager)
- **DOCS** (PWA Tenor Documentation)

Voir [PROFILS_ET_OPTIMISATIONS.md](PROFILS_ET_OPTIMISATIONS.md) pour le catalogue complet.

---

## 🔧 Configuration

### Variables d'environnement

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
  "common_apps": {
    "monapp": {
      "name": "Mon Application",
      "winget": "Publisher.MonApp",
      "size": "50 MB",
      "category": "Développement",
      "description": "Description de mon application"
    }
  }
}
```

#### Ajouter un MSI personnalisé

```json
{
  "name": "Mon App MSI",
  "url": "http://server.com/app.msi",
  "installArgs": "/qn /norestart REBOOT=ReallySuppress",
  "size": "100 MB",
  "category": "Custom"
}
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

---

## 📞 Support

### Contact

- **Email Support** : [si@tenorsolutions.com](mailto:si@tenorsolutions.com)
- **Documentation Interne** : `\\tenor.local\data\Déploiement\SI\PostBootSetup\`
- **GitHub Issues** : [Créer un ticket](https://github.com/TenorDataSolutions/PostBoot/issues)

### Liens Utiles

- [🆘 FAQ & Dépannage](AIDE.md)
- [📖 Documentation Complète](docs/)
- [📝 Changelog](CHANGELOG.md)
- [🏗️ Architecture](ARCHITECTURE.md)

---

## 📝 License

**© 2025 Tenor Data Solutions**

Usage interne uniquement. Tous droits réservés.

---

<div align="center">

**PostBootSetup v5.2** - *Simplifiez vos installations Windows*

Made with ❤️ by Tenor Data Solutions SI Team

[⬆ Retour en haut](#-postbootsetup-v52)

</div>
