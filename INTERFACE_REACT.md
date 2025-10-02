# Interface React PostBootSetup v5.0

## 🎨 Présentation

L'interface web React de PostBootSetup v5.0 est une application moderne, intuitive et responsive qui permet aux utilisateurs de générer des scripts d'installation Windows personnalisés en quelques clics.

---

## ✨ Fonctionnalités principales

### 🏠 Page d'accueil
- **Sélection de profils** : 3 profils prédéfinis (DEV, SUPPORT, SI)
- **Configuration personnalisée** : Partir de zéro avec vos propres choix
- **Design moderne** : Cartes interactives avec icônes et descriptions
- **Responsive** : Adapté mobile, tablette et desktop

### ⚙️ Page de personnalisation
- **Onglets thématiques** :
  - 📦 **Applications** : Sélection granulaire par catégorie
  - ⚡ **Performance** : Optimisations système recommandées
  - 🎨 **Interface** : Personnalisation UI Windows

- **Gestion avancée** :
  - Compteur d'applications sélectionnées en temps réel
  - Indicateurs visuels (obligatoire, recommandé, optionnel)
  - Nom personnalisé de configuration
  - Sauvegarde d'état locale (Context API)

### ✅ Page de succès
- **Instructions détaillées** : Guide pas-à-pas pour exécuter le script
- **Commandes PowerShell** : Exemples de commandes prêtes à l'emploi
- **Avertissements** : Prérequis et points d'attention
- **Actions rapides** : Retour accueil ou nouvelle génération

---

## 🛠️ Technologies implémentées

| Technologie | Version | Usage |
|-------------|---------|-------|
| **React** | 18.3.1 | Framework UI avec hooks modernes |
| **Vite** | 5.2.0 | Build tool ultra-rapide (<4s) |
| **Tailwind CSS** | 3.4.1 | Styling utility-first |
| **React Router** | 6.22.0 | Navigation SPA |
| **Axios** | 1.6.7 | Client HTTP pour API |
| **Lucide React** | 0.363.0 | Icônes SVG légères |

---

## 📁 Architecture de fichiers

```
web/
├── src/
│   ├── components/
│   │   ├── Header.jsx              # En-tête avec logo + version
│   │   ├── Footer.jsx              # Pied de page + liens
│   │   └── ProfileCard.jsx         # Carte profil réutilisable
│   │
│   ├── pages/
│   │   ├── Home.jsx                # Page d'accueil (sélection profil)
│   │   ├── Customize.jsx           # Formulaire de personnalisation
│   │   └── Success.jsx             # Page de confirmation + instructions
│   │
│   ├── context/
│   │   └── ConfigContext.jsx       # État global (profils, apps, config)
│   │
│   ├── services/
│   │   └── api.js                  # Client Axios + endpoints
│   │
│   ├── App.jsx                     # Composant racine + routes
│   ├── main.jsx                    # Point d'entrée React
│   └── index.css                   # Styles Tailwind + custom
│
├── public/                         # Assets statiques
├── index.html                      # Template HTML
├── vite.config.js                  # Config Vite + proxy API
├── tailwind.config.js              # Thème Tailwind (couleurs Tenor)
├── Dockerfile                      # Build multi-stage
├── nginx.conf                      # Config Nginx pour SPA
└── package.json                    # Dépendances npm
```

---

## 🎨 Design System

### Palette de couleurs

```css
/* Primaire (bleu Tenor) */
primary-600: #2563eb
primary-700: #1d4ed8

/* Secondaire */
gray-50: #f9fafb      /* Background */
gray-900: #111827     /* Texte principal */
gray-600: #4b5563     /* Texte secondaire */

/* Statuts */
green-600: #16a34a    /* Succès */
red-600: #dc2626      /* Erreur */
amber-600: #d97706    /* Avertissement */
```

### Composants stylés

```jsx
// Boutons
<button className="btn-primary">Primaire</button>
<button className="btn-secondary">Secondaire</button>

// Carte
<div className="card">Contenu</div>

// Input
<input className="input-field" />

// Checkbox
<input type="checkbox" className="checkbox" />
```

---

## 🔌 Intégration API

### Endpoints consommés

```javascript
// Health check
GET /api/health
→ { status: 'healthy', ps2exe_available: false }

// Profils
GET /api/profiles
→ { profiles: [{ id: 'DEV', name: '...', apps_count: 5 }] }

// Applications
GET /api/apps
→ { apps: { master: [...], profiles: {...}, optional: [...] } }

// Modules
GET /api/modules
→ { modules: { debloat: {...}, performance: {...}, ui: {...} } }

// Génération
POST /api/generate/script
Body: { profile, custom_name, master_apps, ... }
→ { success: true, script_id, filename, download_url }

// Téléchargement
GET /api/download/<script_id>
→ Fichier .ps1 (Content-Type: text/plain)
```

### Gestion d'erreurs

```javascript
try {
  const result = await apiService.generateScript(config);
  // Succès
} catch (error) {
  if (error.response) {
    // Erreur API (4xx, 5xx)
    setError(error.response.data.error);
  } else if (error.request) {
    // Pas de réponse
    setError('Impossible de contacter l\'API');
  } else {
    // Erreur de configuration
    setError('Erreur de configuration');
  }
}
```

---

## 🚀 Déploiement

### Build local

```bash
cd web
npm install
npm run build
# → Fichiers dans dist/
```

### Docker multi-stage

```dockerfile
# Stage 1: Build React
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Nginx
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
```

**Avantages** :
- ✅ Image finale légère (~40 MB)
- ✅ Pas de Node.js en production
- ✅ Nginx optimisé pour SPA

### Docker Compose

```yaml
services:
  web:
    build:
      context: ./web
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - api
```

**Commande** : `docker-compose up -d --build`

---

## 📱 Responsive Design

### Breakpoints Tailwind

```css
/* Mobile-first */
sm: 640px   /* Tablettes */
md: 768px   /* Desktop */
lg: 1024px  /* Large desktop */
xl: 1280px  /* Extra large */
```

### Exemples

```jsx
// Grille responsive
<div className="grid grid-cols-1 md:grid-cols-3 gap-6">
  {/* 1 colonne sur mobile, 3 sur desktop */}
</div>

// Texte responsive
<h1 className="text-2xl md:text-4xl">Titre</h1>

// Affichage conditionnel
<div className="hidden md:block">Visible desktop uniquement</div>
```

---

## 🔒 Sécurité

### Headers Nginx

```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

### Validation côté client

```javascript
// Empêcher génération sans applications
const getTotalAppsCount = () => {
  return (master_apps.length + profile_apps.length + optional_apps.length);
};

<button disabled={getTotalAppsCount() === 0}>
  Générer
</button>
```

### CORS

Géré par Flask-CORS côté API :

```python
from flask_cors import CORS
CORS(app, resources={r"/api/*": {"origins": "*"}})
```

---

## ⚡ Performance

### Optimisations implémentées

1. **Code Splitting** : Routes chargées à la demande
2. **Tree Shaking** : Code inutilisé supprimé par Vite
3. **Minification** : HTML/CSS/JS compressés
4. **Gzip** : Compression Nginx activée
5. **Cache** : Assets statiques cachés 1 an
6. **Lazy Loading** : Images chargées si besoin

### Métriques

| Métrique | Valeur |
|----------|--------|
| **Bundle JS** | 228 KB (74 KB gzip) |
| **Bundle CSS** | 19 KB (4 KB gzip) |
| **First Paint** | < 1s |
| **Interactive** | < 2s |

---

## 🧪 Tests recommandés

### Tests manuels

```bash
# 1. Test local
cd web
npm run dev
# → Naviguer http://localhost:3000

# 2. Test build
npm run build
npm run preview

# 3. Test Docker
docker build -t test-web .
docker run -p 8080:80 test-web
```

### Checklist

- [ ] Navigation entre pages fonctionne
- [ ] Sélection profil charge les bonnes apps
- [ ] Génération + téléchargement script
- [ ] Gestion erreurs API (arrêter l'API)
- [ ] Responsive mobile/desktop
- [ ] Headers sécurité présents
- [ ] Performance (Lighthouse > 90)

---

## 🐛 Troubleshooting

### Problème : Page blanche

```bash
# Vérifier les logs navigateur (F12)
# Souvent : problème de proxy API

# Solution : Vérifier vite.config.js
server: {
  proxy: {
    '/api': 'http://localhost:5000'
  }
}
```

### Problème : API non accessible

```bash
# Vérifier que l'API tourne
docker-compose ps

# Tester API directement
curl http://localhost:5000/api/health

# Vérifier nginx.conf (proxy_pass)
location /api/ {
  proxy_pass http://api:5000;
}
```

### Problème : Build échoue

```bash
# Nettoyer cache
cd web
rm -rf node_modules dist
npm install
npm run build
```

---

## 📈 Évolutions futures

### Court terme
- [ ] Animations page transitions (Framer Motion)
- [ ] Mode sombre (toggle)
- [ ] Sauvegarde config dans localStorage
- [ ] Export/Import configuration JSON

### Moyen terme
- [ ] Tests unitaires (Vitest)
- [ ] Tests E2E (Playwright)
- [ ] Internationalisation (i18n)
- [ ] Progressive Web App (PWA)

### Long terme
- [ ] Authentification utilisateur
- [ ] Historique générations
- [ ] Templates personnalisables
- [ ] Marketplace communautaire

---

## 📞 Support

**Documentation principale** : [README_v5.md](README_v5.md)
**Architecture** : [ARCHITECTURE.md](ARCHITECTURE.md)
**Déploiement** : [DEPLOIEMENT.md](DEPLOIEMENT.md)

**Contact** : IT Department - Tenor Data Solutions

---

© 2025 Tenor Data Solutions - Interface React v5.0
