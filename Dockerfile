# PostBootSetup Generator - Dockerfile
# Image Docker pour l'API de génération de scripts PowerShell

# Utiliser Debian Bullseye (11) au lieu de Trixie pour compatibilité PowerShell
FROM python:3.11-bullseye

LABEL maintainer="Tenor Data Solutions <it@tenorsolutions.com>"
LABEL version="5.0"
LABEL description="PostBootSetup Generator API - Génération dynamique de scripts d'installation Windows"

# Variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive

# Installer les dépendances système minimales
# Note: PS2EXE (compilation .exe) nécessite Windows PowerShell et n'est pas disponible sur Linux
# L'API génère uniquement des scripts .ps1 dans ce conteneur Docker Linux
# Pour activer .exe, déployer sur Windows Server avec PowerShell Core + module ps2exe
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Créer l'utilisateur non-root pour l'application
RUN useradd -m -u 1000 -s /bin/bash appuser

# Définir le répertoire de travail
WORKDIR /app

# Copier les requirements et installer les dépendances Python
COPY generator/requirements.txt /app/
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copier tous les fichiers du projet
COPY --chown=appuser:appuser . /app/

# Créer les répertoires nécessaires
RUN mkdir -p /app/generated /app/logs \
    && chown -R appuser:appuser /app

# Basculer vers l'utilisateur non-root
USER appuser

# Exposer les ports
# 5000: API Flask
EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Commande de démarrage
CMD ["python", "generator/app.py"]