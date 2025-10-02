# Structure du projet PostBootSetup v5.0

## 📁 Arborescence complète

```
PostBoot/
│
├── 📋 Documentation
│   ├── README_v5.md                    # Vue d'ensemble du projet
│   ├── ARCHITECTURE.md                 # Architecture technique détaillée
│   ├── DEPLOIEMENT.md                  # Guide de déploiement complet
│   ├── FONCTIONNALITES.md              # Liste complète des fonctionnalités
│   ├── QUICKSTART.md                   # Démarrage rapide multi-plateforme
│   ├── WINDOWS_QUICKSTART.md           # Guide spécifique Windows
│   ├── STRUCTURE.md                    # Ce fichier
│   └── FILES_CREATED.md                # Historique des fichiers créés (v4→v5)
│
├── ⚙️ Configuration
│   ├── config/
│   │   ├── apps.json                   # Catalogue applications (master/profils/optionnelles)
│   │   └── settings.json               # Configuration modules (debloat/performance/ui)
│   │
│   ├── .dockerignore                   # Fichiers exclus de l'image Docker
│   ├── .gitignore                      # Fichiers exclus du versioning
│   ├── Dockerfile                      # Image Docker de l'API Python
│   ├── docker-compose.yml              # Orchestration conteneurs (API + Nginx)
│   └── nginx.conf                      # Configuration serveur web Nginx
│
├── 🔧 Modules PowerShell
│   └── modules/
│       ├── Debloat-Windows.psm1        # Suppression bloatware + télémétrie
│       ├── Optimize-Performance.psm1   # Optimisations système
│       └── Customize-UI.psm1           # Personnalisation interface Windows
│
├── 🌐 API Flask (Backend)
│   └── generator/
│       ├── app.py                      # API REST principale (Flask)
│       │                               # - 7 endpoints
│       │                               # - Génération scripts
│       │                               # - Logging structuré
│       │                               # - Validation JSON
│       │
│       └── requirements.txt            # Dépendances Python
│                                       # - Flask 3.0
│                                       # - flask-cors
│                                       # - gunicorn (production WSGI)
│
├── 🎨 Interface Web (Frontend)
│   └── web/
│       ├── index.html                  # Page d'accueil (sélection profil)
│       ├── advanced.html               # Personnalisation avancée
│       ├── app.js                      # Logique JavaScript (appels API)
│       └── styles.css                  # Styles CSS
│
├── 📜 Templates
│   └── templates/
│       └── main_template.ps1           # Template base pour scripts générés
│
├── 🗂️ Dossiers générés (runtime)
│   ├── generated/                      # Scripts .ps1 générés (auto-nettoyé)
│   └── logs/                           # Logs API (rotation automatique)
│
├── 🧪 Tests et Scripts utilitaires
│   ├── test_api.ps1                    # Tests complets des 7 endpoints
│   ├── test_config_example.json        # Exemple de configuration POST
│   ├── diagnose_docker.ps1             # Diagnostic Docker Desktop
│   ├── start.bat                       # Démarrage rapide Windows (CMD)
│   ├── start.sh                        # Démarrage rapide Linux/macOS (Bash)
│   └── PostBootSetup_v5.ps1            # Orchestrateur local (usage direct)
│
└── 📦 Fichiers système
    ├── .env                            # Variables d'environnement (optionnel)
    ├── .gitattributes                  # Configuration Git
    └── LICENSE                         # Licence du projet
```

---

## 📊 Répartition des fichiers

### Par catégorie

| Catégorie | Nombre | Exemples |
|-----------|--------|----------|
| **Documentation** | 8 | README_v5.md, ARCHITECTURE.md, DEPLOIEMENT.md |
| **Configuration** | 6 | apps.json, settings.json, Dockerfile |
| **Code PowerShell** | 4 | 3 modules + 1 orchestrateur |
| **Code Python** | 2 | app.py, requirements.txt |
| **Interface Web** | 3 | index.html, advanced.html, app.js |
| **Tests** | 3 | test_api.ps1, diagnose_docker.ps1, test_config_example.json |
| **Scripts utilitaires** | 2 | start.bat, start.sh |
| **Total** | **28 fichiers** | |

### Par langage

| Langage | Fichiers | Lignes approx. |
|---------|----------|----------------|
| **PowerShell** | 4 modules + 2 tests | ~2500 lignes |
| **Python** | 1 API | ~800 lignes |
| **Markdown** | 8 docs | ~3500 lignes |
| **JSON** | 2 configs | ~600 lignes |
| **HTML/CSS/JS** | 3 web | ~800 lignes |
| **Docker/Nginx** | 3 configs | ~200 lignes |

---

## 🔑 Fichiers critiques

### Configuration obligatoire

| Fichier | Rôle | Modification requise |
|---------|------|----------------------|
| `config/apps.json` | Applications disponibles | ✅ Personnaliser catalogue |
| `config/settings.json` | Modules et options | ✅ Ajuster optimisations |
| `docker-compose.yml` | Orchestration | ⚠️ Ports/volumes uniquement |
| `Dockerfile` | Image API | ❌ Ne pas modifier |
| `nginx.conf` | Serveur web | ⚠️ SSL/HTTPS uniquement |

### Modules fonctionnels

| Module | Taille | Fonctions exportées | Dépendances |
|--------|--------|---------------------|-------------|
| `Debloat-Windows.psm1` | ~400 lignes | `Invoke-WindowsDebloat` | Aucune |
| `Optimize-Performance.psm1` | ~500 lignes | `Invoke-PerformanceOptimizations` | Aucune |
| `Customize-UI.psm1` | ~300 lignes | `Invoke-UICustomizations` | Aucune |

### API Endpoints (app.py)

| Endpoint | Lignes | Complexité | Temps réponse |
|----------|--------|------------|---------------|
| `/api/health` | ~20 | Faible | < 50ms |
| `/api/profiles` | ~40 | Faible | < 100ms |
| `/api/apps` | ~30 | Faible | < 100ms |
| `/api/modules` | ~30 | Faible | < 100ms |
| `/api/generate/script` | ~150 | Élevée | 500ms-2s |
| `/api/generate/executable` | ~80 | Moyenne | N/A (désactivé Linux) |
| `/api/download/<id>` | ~40 | Faible | < 200ms |

---

## 🛠️ Fichiers modifiables sans risque

### ✅ Personnalisation recommandée

**1. Applications (`config/apps.json`)** :
```json
{
  "master": [/* Ajouter/retirer apps obligatoires */],
  "profiles": {
    "NOUVEAU_PROFIL": {/* Créer nouveau profil métier */}
  },
  "optional": [/* Apps optionnelles */]
}
```

**2. Modules (`config/settings.json`)** :
```json
{
  "modules": {
    "performance": {
      "options": {
        "NouvellOption": {/* Ajouter option */}
      }
    }
  }
}
```

**3. Interface web (`web/*.html`)** :
- Modifier textes, styles, logos
- Ajouter sections
- Changer couleurs/thème

**4. Variables d'environnement (`.env`)** :
```bash
API_PORT=5000
LOG_LEVEL=INFO
CLEANUP_INTERVAL_HOURS=24
```

### ⚠️ Modification avec précaution

**Dockerfile** : Uniquement si besoin de dépendances système
**nginx.conf** : Pour SSL/HTTPS ou reverse proxy
**docker-compose.yml** : Ports, volumes, scaling

### ❌ Ne pas modifier

**generator/app.py** : Logique métier critique
**modules/*.psm1** : Fonctions PowerShell testées
**test_api.ps1** : Tests automatisés

---

## 📦 Dépendances externes

### Python (requirements.txt)
```
Flask==3.0.0           # Framework web
flask-cors==4.0.0      # Cross-Origin Resource Sharing
gunicorn==21.2.0       # Serveur WSGI production
python-dotenv==1.0.0   # Variables d'environnement
```

### Docker
```
python:3.11-bullseye   # Image base API
nginx:alpine           # Image serveur web
```

### Windows (scripts générés)
```
PowerShell 5.1+        # Exécution scripts
Winget                 # Installation applications
Windows 10/11          # Système cible
```

---

## 🔄 Cycle de vie des fichiers générés

### Génération
1. Requête POST → `/api/generate/script`
2. Création `PostBootSetup_Profil_UUID.ps1` dans `generated/`
3. UUID stocké en mémoire (24h)

### Téléchargement
4. GET `/api/download/<uuid>`
5. Fichier servi avec headers `Content-Disposition: attachment`

### Nettoyage automatique
6. Tâche planifiée : suppression après 24h
7. Nettoyage au redémarrage conteneur

---

## 📈 Taille du projet

### Occupation disque

| Composant | Taille | Description |
|-----------|--------|-------------|
| **Code source** | ~2 MB | Tous fichiers .py, .ps1, .md |
| **Image Docker API** | ~200 MB | Python 3.11 + Flask |
| **Image Docker Nginx** | ~40 MB | Nginx Alpine |
| **Scripts générés** | ~50 KB/script | Variable selon nb apps |
| **Logs** | Variable | Rotation tous les 7 jours |
| **Total minimum** | ~250 MB | Sans scripts générés |

### Performance

| Métrique | Valeur |
|----------|--------|
| RAM API (repos) | ~150 MB |
| RAM API (génération) | ~300 MB |
| RAM Nginx | ~10 MB |
| CPU (repos) | < 5% |
| CPU (génération) | 20-40% (burst 2s) |

---

## 🔐 Fichiers sensibles

### À exclure du versioning (.gitignore)
```
generated/             # Scripts générés
logs/                  # Logs application
.env                   # Variables environnement
__pycache__/           # Cache Python
*.log                  # Tous logs
```

### À sauvegarder (backup)
```
config/apps.json       # Catalogue apps personnalisé
config/settings.json   # Configuration modules
modules/*.psm1         # Modules modifiés
web/                   # Interface personnalisée
```

---

## 🚀 Évolution future

### Fichiers à ajouter (roadmap)

| Fichier | Objectif | Priorité |
|---------|----------|----------|
| `generator/database.py` | Persistance scripts | Moyenne |
| `generator/auth.py` | Authentification JWT | Haute |
| `web-react/` | Interface moderne | Haute |
| `tests/unit/` | Tests unitaires Python | Moyenne |
| `monitoring/prometheus.yml` | Métriques | Faible |
| `config/templates.json` | Templates personnalisables | Moyenne |

---

## 📞 Navigation rapide

- **Démarrer** : [QUICKSTART.md](QUICKSTART.md) ou [WINDOWS_QUICKSTART.md](WINDOWS_QUICKSTART.md)
- **Déployer** : [DEPLOIEMENT.md](DEPLOIEMENT.md)
- **Comprendre** : [ARCHITECTURE.md](ARCHITECTURE.md)
- **Fonctionnalités** : [FONCTIONNALITES.md](FONCTIONNALITES.md)
- **Historique** : [FILES_CREATED.md](FILES_CREATED.md)

---

© 2025 Tenor Data Solutions
