# PostBootSetup Web - Dockerfile
# Build multi-stage pour optimiser la taille de l'image

# Stage 1: Build
FROM node:20-alpine AS builder

# Argument pour l'URL de l'API (passé depuis docker-compose)
ARG VITE_API_URL=http://localhost:5000

WORKDIR /app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances (toutes, y compris devDependencies pour le build)
RUN npm ci

# Copier le code source
COPY . .

# Créer le fichier .env pour le build
RUN echo "VITE_API_URL=${VITE_API_URL}" > .env

# Build de production
RUN npm run build

# Stage 2: Production
FROM nginx:alpine

# Copier la configuration nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copier les fichiers buildés depuis le stage builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Exposer le port 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Démarrer nginx
CMD ["nginx", "-g", "daemon off;"]
