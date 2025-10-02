# Déploiement Production Debian 12

URL: https://postboot.tenorsolutions.com

## Installation

1. Cloner le projet
2. Configurer .env avec VITE_API_URL=https://postboot.tenorsolutions.com/api
3. docker compose -f docker-compose.prod.yml up -d
4. Configurer Nginx reverse proxy

Voir README.md pour détails complets.
