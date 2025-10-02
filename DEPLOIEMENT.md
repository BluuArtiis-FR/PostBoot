# Guide de déploiement PostBootSetup v5.0

## Déploiement rapide avec Docker

### Prérequis
- Docker Desktop (Windows) ou Docker Engine (Linux)
- 2 GB RAM minimum
- Port 80 et 5000 disponibles

### Installation en 3 étapes

#### 1. Cloner ou télécharger le projet
```bash
cd /chemin/vers/PostBoot
```

#### 2. Lancer les conteneurs
```bash
# Windows
.\start.bat

# Linux/macOS
./start.sh
```

#### 3. Accéder à l'application
- **Interface web** : http://localhost
- **API Health** : http://localhost:5000/api/health
- **Swagger/Docs** : http://localhost:5000/api/ (à venir)

### Vérification du déploiement

```powershell
# Test des endpoints API
.\test_api.ps1
```

Résultat attendu :
```
✓ Health Check OK - ps2exe_available: false (normal sur Linux)
✓ 7 endpoints fonctionnels
✓ Script généré et téléchargé avec succès
```

---

## Architecture des conteneurs

```
┌─────────────────────┐
│   nginx:alpine      │  Port 80, 443
│   (Serveur Web)     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   Python 3.11       │  Port 5000
│   Flask API         │
│   (Générateur)      │
└─────────────────────┘
```

### Services démarrés
- `postboot-web` : Serveur Nginx pour l'interface web
- `postboot-generator-api` : API Flask de génération de scripts

---

## Endpoints API disponibles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/health` | État de santé de l'API |
| GET | `/api/profiles` | Liste des profils (DEV, SUPPORT, SI) |
| GET | `/api/apps` | Liste complète des applications |
| GET | `/api/modules` | Modules d'optimisation disponibles |
| POST | `/api/generate/script` | Génère un script .ps1 personnalisé |
| POST | `/api/generate/executable` | ⚠️ Non disponible sur Linux Docker |
| GET | `/api/download/<id>` | Télécharge un script généré |

---

## Configuration

### Personnaliser les applications
Éditez `config/apps.json` :
```json
{
  "master": [
    {
      "name": "Votre Application",
      "winget": "Publisher.App",
      "required": true,
      "category": "Catégorie"
    }
  ]
}
```

### Personnaliser les modules
Éditez `config/settings.json` pour modifier les optimisations par défaut.

### Variables d'environnement
Créez `.env` :
```bash
FLASK_ENV=production
API_PORT=5000
LOG_LEVEL=INFO
MAX_SCRIPT_SIZE_MB=50
CLEANUP_INTERVAL_HOURS=24
```

---

## Commandes utiles

### Gestion des conteneurs
```bash
# Voir les logs en temps réel
docker-compose logs -f api

# Redémarrer l'API
docker-compose restart api

# Arrêter tout
docker-compose down

# Rebuild complet
docker-compose up -d --build
```

### Nettoyage
```bash
# Supprimer les scripts générés
docker-compose exec api rm -rf /app/generated/*

# Supprimer volumes et tout reconstruire
docker-compose down -v
docker-compose up -d --build
```

### Debugging
```bash
# Accéder au conteneur API
docker-compose exec api bash

# Vérifier les fichiers de configuration
docker-compose exec api cat /app/config/settings.json

# Voir la structure des dossiers
docker-compose exec api ls -la /app/
```

---

## Déploiement en production

### Recommandations
1. **HTTPS** : Configurer Nginx avec certificats SSL
2. **Reverse Proxy** : Utiliser Traefik ou Nginx Proxy Manager
3. **Firewall** : Restreindre l'accès aux ports 80/443
4. **Monitoring** : Ajouter Prometheus + Grafana
5. **Sauvegarde** : Sauvegarder `config/` et `modules/`

### Exemple avec Traefik
```yaml
# docker-compose.prod.yml
services:
  api:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.postboot.rule=Host(`postboot.votredomaine.com`)"
      - "traefik.http.routers.postboot.tls.certresolver=letsencrypt"
```

### Scalabilité
```bash
# Augmenter le nombre d'instances API
docker-compose up -d --scale api=3
```

---

## Troubleshooting

### L'API ne démarre pas
```bash
# Vérifier les logs
docker-compose logs api

# Vérifier que le port 5000 est libre
netstat -ano | findstr :5000  # Windows
lsof -i :5000                # Linux/macOS
```

### Nginx redémarre en boucle
```bash
# Tester la configuration
docker-compose exec web nginx -t

# Vérifier les logs
docker-compose logs web
```

### Script généré vide ou erreur 500
```bash
# Vérifier la configuration JSON
docker-compose exec api python -c "import json; json.load(open('/app/config/settings.json'))"

# Vérifier les modules
docker-compose exec api ls -la /app/modules/
```

### Performance lente
- Augmenter la RAM allouée à Docker Desktop (min 4 GB recommandé)
- Vérifier l'espace disque disponible
- Désactiver l'antivirus pour les dossiers Docker

---

## Mise à jour

### Version mineure (config/modules)
```bash
git pull
docker-compose restart
```

### Version majeure (code Python/Dockerfile)
```bash
git pull
docker-compose down
docker-compose up -d --build
```

---

## Support

- **Documentation complète** : Voir [ARCHITECTURE.md](ARCHITECTURE.md)
- **Exemples d'utilisation** : Voir [QUICKSTART.md](QUICKSTART.md)
- **Guide Windows** : Voir [WINDOWS_QUICKSTART.md](WINDOWS_QUICKSTART.md)

---

## Licence

© 2025 Tenor Data Solutions - Usage interne
