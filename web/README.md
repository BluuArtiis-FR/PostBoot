# PostBootSetup Web Interface v5.0

Interface React moderne pour le générateur de scripts PostBootSetup.

## 🚀 Développement local

### Prérequis
- Node.js 18+ et npm
- API PostBootSetup démarrée sur http://localhost:5000

### Installation

```bash
cd web
npm install
```

### Démarrage en mode développement

```bash
npm run dev
```

L'interface sera accessible sur http://localhost:3000

### Build de production

```bash
npm run build
```

Les fichiers buildés seront dans le dossier `dist/`

## 🏗️ Structure

```
web/
├── src/
│   ├── components/      # Composants réutilisables
│   │   ├── Header.jsx
│   │   ├── Footer.jsx
│   │   └── ProfileCard.jsx
│   ├── pages/           # Pages de l'application
│   │   ├── Home.jsx
│   │   ├── Customize.jsx
│   │   └── Success.jsx
│   ├── context/         # Context API (état global)
│   │   └── ConfigContext.jsx
│   ├── services/        # Services API
│   │   └── api.js
│   ├── App.jsx          # Composant principal + routing
│   ├── main.jsx         # Point d'entrée React
│   └── index.css        # Styles Tailwind CSS
├── public/              # Assets statiques
├── index.html           # Template HTML
├── vite.config.js       # Configuration Vite
├── tailwind.config.js   # Configuration Tailwind
└── package.json         # Dépendances npm
```

## 🎨 Technologies utilisées

- **React 18.3** - Framework UI
- **Vite 5** - Build tool ultra-rapide
- **Tailwind CSS 3** - Framework CSS utility-first
- **React Router 6** - Routing SPA
- **Axios** - Client HTTP
- **Lucide React** - Icônes modernes

## 🔌 API Endpoints utilisés

| Endpoint | Usage |
|----------|-------|
| `GET /api/health` | Vérification santé API |
| `GET /api/profiles` | Liste des profils prédéfinis |
| `GET /api/apps` | Catalogue applications |
| `GET /api/modules` | Modules d'optimisation |
| `POST /api/generate/script` | Génération script .ps1 |
| `GET /api/download/<id>` | Téléchargement script |

## 🐳 Docker

L'interface est containerisée avec Nginx en production.

### Build Docker

```bash
cd web
docker build -t postboot-web .
```

### Run

```bash
docker run -p 80:80 postboot-web
```

## 📝 Variables d'environnement

Copier `.env.example` vers `.env` :

```bash
cp .env.example .env
```

Variables disponibles :
- `VITE_API_URL` - URL de l'API backend (défaut: http://localhost:5000)
- `VITE_BUILD_ID` - Identifiant du build
- `VITE_ENABLE_EXE_DOWNLOAD` - Activer téléchargement .exe (false sur Linux)

## 🧪 Tests

```bash
# Linting
npm run lint

# Preview du build production
npm run preview
```

## 📦 Déploiement

Le déploiement se fait automatiquement via `docker-compose up` depuis la racine du projet.

```bash
cd ..
docker-compose up -d --build
```

L'interface sera accessible sur http://localhost

## 🎯 Fonctionnalités

✅ Sélection de profils prédéfinis (DEV, SUPPORT, SI)
✅ Configuration personnalisée complète
✅ Sélection granulaire d'applications
✅ Configuration des modules d'optimisation (Performance, UI)
✅ Génération et téléchargement instantané de scripts .ps1
✅ Interface responsive (mobile-friendly)
✅ Gestion d'état avec Context API
✅ Indicateurs de chargement et messages d'erreur
✅ Instructions d'utilisation détaillées

## 🔧 Personnalisation

### Modifier les couleurs

Éditez `tailwind.config.js` :

```js
theme: {
  extend: {
    colors: {
      primary: { /* vos couleurs */ },
      tenor: { /* couleurs Tenor */ }
    }
  }
}
```

### Ajouter une page

1. Créer `src/pages/MaPage.jsx`
2. Ajouter la route dans `src/App.jsx`

```jsx
<Route path="/ma-page" element={<MaPage />} />
```

## 📞 Support

Voir la documentation principale : [../README_v5.md](../README_v5.md)

---

© 2025 Tenor Data Solutions
