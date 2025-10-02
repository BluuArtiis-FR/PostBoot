# PostBootSetup v5.0

**Générateur de scripts d'installation et configuration Windows - Tenor Data Solutions**

Interface web moderne pour créer des scripts PowerShell personnalisés d'installation d'applications et d'optimisation Windows.

---

## 🚀 Démarrage Rapide

### Prérequis
- Docker & Docker Compose
- Debian 12 (pour production) ou Windows 10+ (pour développement)

### Développement (Local)

```bash
# Cloner le projet
git clone <repo-url>
cd PostBootSetup

# Lancer l'application
docker-compose up -d

# Accès
# Frontend: http://localhost:8080
# API: http://localhost:5000
```

### Production (Debian 12)

```bash
# Utiliser le fichier docker-compose de production
docker-compose -f docker-compose.prod.yml up -d

# L'application sera accessible via votre reverse proxy
# URL: https://postboot.tenorsolutions.com
```

---

## 📋 Architecture 3 Espaces

PostBootSetup v5.0 propose une architecture modulaire en 3 espaces :

### 1️⃣ **Installation**
- Sélection de profil (DEV .NET, DEV WinDev, TENOR, SI, Personnalisé)
- Sélection d'applications parmi 40+ apps disponibles
- 11 applications Master (obligatoires)
- Applications par profil
- Applications optionnelles

### 2️⃣ **Optimisations**
- **Debloat Windows** (obligatoire) : Suppression bloatware et apps inutiles
- **Performance** (optionnel) : PageFile, PowerPlan, StartupPrograms, Network, VisualEffects
- **UI** (optionnel) : DarkMode, Extensions de fichiers, Fichiers cachés, etc.

### 3️⃣ **Diagnostic**
- Rapport HTML détaillé de l'état système
- Liste des applications installées
- État des optimisations appliquées
- Détection de problèmes

---

## 🎯 Profils Disponibles

| Profil | Description | Applications clés |
|--------|-------------|-------------------|
| **DEV .NET** | Développeur .NET | Visual Studio, SQL Server, Git, Postman, Python, Node.js |
| **DEV WinDev** | Développeur WinDev | WinDev, SQL Server, Git, eCarAdmin, EDI, Gestion Temps |
| **TENOR** | Projet & Support | eCarAdmin, EDI Translator, Gestion Temps |
| **SI** | Admin Système | Git, SSMS, DBeaver, Wireshark, Nmap, Burp Suite |
| **Personnalisé** | Sur mesure | Sélection manuelle de toutes les apps |

---

## 🛠️ Stack Technique

- **Frontend**: React 18 + Vite + Tailwind CSS
- **Backend**: Flask (Python 3.11)
- **Conteneurisation**: Docker + Docker Compose
- **Reverse Proxy**: Nginx (compatible Traefik)
- **Scripts**: PowerShell 5.1+

---

## 📁 Structure du Projet

```
PostBootSetup/
├── web/                    # Frontend React
│   ├── src/
│   │   ├── pages/         # Pages (Home, Installation, Optimizations, etc.)
│   │   ├── components/    # Composants réutilisables
│   │   ├── context/       # State management (Context API)
│   │   └── services/      # API calls
│   ├── Dockerfile
│   └── package.json
│
├── generator/              # Backend Flask
│   └── app.py             # API principale
│
├── config/                 # Configuration
│   ├── apps.json          # Catalogue d'applications
│   └── settings.json      # Paramètres d'optimisation
│
├── modules/                # Modules PowerShell
│   ├── Debloat-Windows.ps1
│   ├── Optimize-Performance.ps1
│   └── Customize-UI.ps1
│
├── templates/              # Templates PowerShell
│   └── main_template.ps1
│
├── docker-compose.yml      # Développement
├── docker-compose.prod.yml # Production
└── README.md
```

---

## 🔧 Configuration

### Variables d'environnement (Production)

Copier `.env.example` vers `.env` dans `web/` :

```bash
VITE_API_URL=https://postboot.tenorsolutions.com/api
```

### Reverse Proxy (Nginx)

Exemple de configuration Nginx :

```nginx
server {
    listen 80;
    server_name postboot.tenorsolutions.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 📚 Documentation

- [DEPLOIEMENT.md](DEPLOIEMENT.md) - Guide de déploiement Debian 12
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture technique détaillée
- [PROFILS_ET_OPTIMISATIONS.md](PROFILS_ET_OPTIMISATIONS.md) - Catalogue des profils et optimisations
- [CHANGELOG.md](CHANGELOG.md) - Historique des versions

---

## 🧪 Tests

```bash
# Tester l'API
curl http://localhost:5000/api/health

# Tester le frontend
curl http://localhost:8080

# Logs
docker-compose logs -f api
docker-compose logs -f web
```

---

## 🤝 Contribution

Ce projet est maintenu par l'équipe SI de Tenor Data Solutions.

### Workflow Git

```bash
# Créer une branche feature
git checkout -b feature/nouvelle-fonctionnalite

# Commit
git add .
git commit -m "feat: description de la fonctionnalité"

# Push
git push origin feature/nouvelle-fonctionnalite

# Créer une Pull Request
```

---

## 📞 Support

**Email** : si@tenorsolutions.com
**Documentation** : `\\tenor.local\data\Déploiement\SI\PostBootSetup\`

---

## 📝 License

© 2025 Tenor Data Solutions - Usage interne uniquement

---

*PostBootSetup v5.0 - Interface web de génération de scripts Windows*
