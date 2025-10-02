# Architecture PostBootSetup v5.0

## Vue d'ensemble

Le projet PostBootSetup v5.0 adopte une architecture modulaire conçue pour fonctionner dans un environnement containerisé Docker. L'objectif est de permettre à un utilisateur de personnaliser entièrement son installation Windows via une interface web, puis de générer dynamiquement un script PowerShell (.ps1) ou un exécutable (.exe) prêt à être téléchargé et exécuté sur le poste client cible.

## Architecture en trois couches

### 1. Couche Web (Interface utilisateur)
**Emplacement:** `web/`
**Technologie:** HTML5, JavaScript, CSS
**Rôle:** Interface graphique permettant à l'utilisateur de personnaliser son profil d'installation.

**Fonctionnalités:**
- Sélection d'un profil prédéfini (DEV, SUPPORT, SI) ou création d'un profil personnalisé
- Sélection granulaire des applications à installer (master + profil + optionnelles)
- Activation/désactivation des modules d'optimisation (debloat obligatoire, performance, UI)
- Configuration détaillée des options pour chaque module activé
- Prévisualisation de la configuration avant génération
- Génération et téléchargement du script ou de l'exécutable

**Workflow utilisateur:**
```
1. Accès à l'interface web (localhost ou serveur)
2. Choix du profil de base ou création custom
3. Personnalisation des applications et optimisations
4. Génération du fichier
5. Téléchargement du .ps1 ou .exe
6. Exécution sur le poste Windows cible
```

### 2. Couche API (Générateur de scripts)
**Emplacement:** `generator/` (à créer)
**Technologie:** Python Flask ou Node.js Express
**Rôle:** API REST qui génère dynamiquement le script PowerShell selon la configuration utilisateur.

**Endpoints principaux:**
```
GET  /api/profiles              - Liste des profils disponibles
GET  /api/apps                  - Liste de toutes les applications
GET  /api/modules               - Liste des modules d'optimisation
POST /api/generate/script       - Génère un script .ps1 personnalisé
POST /api/generate/executable   - Génère un exécutable .exe avec PS2EXE
GET  /api/download/:id          - Télécharge le fichier généré
```

**Processus de génération:**
```
1. Réception de la configuration JSON depuis le frontend
2. Validation de la configuration
3. Chargement du template de script
4. Injection dynamique des modules et de la configuration
5. Génération du fichier .ps1 autonome
6. (Optionnel) Compilation en .exe via PS2EXE
7. Retour du fichier téléchargeable
```

### 3. Couche Exécution (Client Windows)
**Emplacement:** Script généré exécuté sur la machine cible
**Technologie:** PowerShell 5.1+
**Rôle:** Orchestrateur autonome qui exécute les modules selon la configuration embarquée.

**Composants embarqués:**
- Configuration JSON inline (apps + settings personnalisés)
- Modules PowerShell nécessaires (code source intégré)
- Orchestrateur d'exécution
- Système de logging
- Gestion des erreurs et rollback

## Structure des modules PowerShell

### Module obligatoire
**Debloat-Windows.psm1** - Toujours exécuté en premier
- Suppression des applications Windows préinstallées (bloatware)
- Désactivation des services de télémétrie
- Configuration du registre pour la confidentialité
- Optimisation des fonctionnalités Windows

### Modules optionnels
**Optimize-Performance.psm1** - Activable selon besoin
- Désactivation des effets visuels
- Optimisation du fichier d'échange
- Désactivation des programmes au démarrage
- Optimisation réseau TCP/IP
- Configuration du plan d'alimentation

**Customize-UI.psm1** - Totalement optionnel
- Configuration de la barre des tâches
- Mode sombre/clair
- Options de l'explorateur de fichiers
- Icônes du bureau
- Thème de couleur Windows

## Configuration JSON modulaire

### Structure settings.json v5.0

```json
{
  "version": "5.0",
  "modules": {
    "module_name": {
      "name": "Nom affiché",
      "module": "Nom-Module",
      "function": "Invoke-FunctionName",
      "description": "Description",
      "required": true/false,
      "recommended": true/false,
      "enabled": true/false,
      "category": "system|performance|customization",
      "options": {
        "option_name": {
          "name": "Nom option",
          "description": "Description",
          "enabled": true/false,
          "recommended": true/false,
          "value": "valeur par défaut"
        }
      }
    }
  }
}
```

**Logique des flags:**
- `required: true` → Toujours exécuté, non désactivable (ex: debloat)
- `recommended: true` → Présélectionné dans l'interface mais désactivable
- `enabled: true` → Activation par défaut de l'option

## Workflow Docker complet

### Architecture Docker

```
┌─────────────────────────────────────────────────────────┐
│                   DOCKER CONTAINER                       │
│                                                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │           Web Server (nginx)                     │   │
│  │         Port 80/443 → Interface HTML            │   │
│  └─────────────────────────────────────────────────┘   │
│                           │                             │
│                           ▼                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │        API Generator (Python/Node)              │   │
│  │         Port 5000 → Endpoints REST              │   │
│  └─────────────────────────────────────────────────┘   │
│                           │                             │
│                           ▼                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │         Script Generator Engine                  │   │
│  │  - Chargement templates                         │   │
│  │  - Injection configuration                       │   │
│  │  - Génération .ps1 autonome                     │   │
│  │  - Compilation .exe (PS2EXE)                    │   │
│  └─────────────────────────────────────────────────┘   │
│                           │                             │
│                           ▼                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │      Volume /generated (fichiers générés)        │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼ Téléchargement
                ┌───────────────────────┐
                │   Utilisateur final    │
                │   Machine Windows      │
                └───────────────────────┘
```

### Dockerfile proposé

```dockerfile
FROM python:3.11-slim

# Installer PowerShell Core (pour PS2EXE)
RUN apt-get update && apt-get install -y \
    wget \
    apt-transport-https \
    software-properties-common \
    && wget -q https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && rm -rf /var/lib/apt/lists/*

# Installer PS2EXE dans PowerShell
RUN pwsh -Command "Install-Module -Name ps2exe -Force -Scope AllUsers"

# Copier les fichiers du projet
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Créer le dossier de fichiers générés
RUN mkdir -p /app/generated

# Exposer les ports
EXPOSE 80 5000

# Démarrer l'API et le serveur web
CMD ["python", "generator/app.py"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  postboot-generator:
    build: .
    ports:
      - "8080:80"
      - "5000:5000"
    volumes:
      - ./config:/app/config:ro
      - ./modules:/app/modules:ro
      - ./generated:/app/generated
    environment:
      - FLASK_ENV=production
      - MAX_FILE_SIZE=50MB
      - LOG_LEVEL=INFO
    restart: unless-stopped

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./web:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - postboot-generator
    restart: unless-stopped
```

## Génération de scripts autonomes

### Template de script généré

Le script généré doit être **totalement autonome** et ne nécessiter aucun fichier externe. Voici la structure proposée:

```powershell
# PostBootSetup - Script généré automatiquement
# Date: 2025-10-01 12:34:56
# Configuration: Profil DEV personnalisé

#region Configuration embarquée
$Global:EmbeddedConfig = @'
{
  "apps": [...],
  "settings": {...}
}
'@ | ConvertFrom-Json
#endregion

#region Module Debloat-Windows (code complet)
function Remove-BloatwareApps { ... }
function Disable-TelemetryServices { ... }
function Invoke-WindowsDebloat { ... }
#endregion

#region Module Optimize-Performance (si activé)
function Disable-VisualEffects { ... }
function Invoke-PerformanceOptimizations { ... }
#endregion

#region Orchestrateur principal
try {
    Show-Header
    Test-Prerequisites
    Invoke-WindowsDebloat
    Install-Applications -Config $Global:EmbeddedConfig
    Invoke-PerformanceOptimizations -Options $Global:EmbeddedConfig.perfOptions
    Show-Summary
} catch {
    Write-Error "Erreur: $_"
}
#endregion
```

### Avantages de cette approche

1. **Autonomie complète:** Un seul fichier contient tout le nécessaire
2. **Portabilité:** Fonctionne sur n'importe quel Windows sans dépendances
3. **Traçabilité:** La configuration est visible dans le script
4. **Simplicité:** L'utilisateur exécute un seul fichier
5. **Versionning:** Chaque script généré est daté et horodaté

## Génération d'exécutables avec PS2EXE

### Processus de compilation

```python
# Dans l'API Python/Node
import subprocess

def generate_executable(ps1_path, exe_path):
    """Compile un script PowerShell en exécutable Windows."""
    cmd = [
        "pwsh",
        "-Command",
        f"Invoke-ps2exe -inputFile '{ps1_path}' -outputFile '{exe_path}' "
        f"-noConsole -requireAdmin -title 'PostBootSetup' "
        f"-description 'Tenor Data Solutions - PostBoot Setup' "
        f"-company 'Tenor Data Solutions' -version '5.0.0'"
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)

    if result.returncode == 0:
        return True, exe_path
    else:
        return False, result.stderr
```

### Avantages de l'exécutable

- **Perception professionnelle:** Un .exe est plus rassurant qu'un .ps1 pour les utilisateurs
- **Protection du code:** Le code PowerShell est compilé (obfuscation basique)
- **Icône personnalisée:** Possibilité d'ajouter le logo Tenor
- **Signature numérique:** Peut être signé avec un certificat d'entreprise
- **Pas de bypass ExecutionPolicy:** L'exécutable ne nécessite pas de modifier la politique PowerShell

## Sécurité et bonnes pratiques

### Validation côté API

```python
def validate_config(config):
    """Valide la configuration avant génération."""
    # Vérifier structure JSON
    # Limiter nombre d'applications
    # Valider les valeurs des paramètres
    # Bloquer les commandes dangereuses
    # Limiter taille du script généré
    pass
```

### Limitations à implémenter

- Limite de 50 applications par script
- Timeout de génération à 30 secondes
- Taille maximale du script: 5 MB
- Rate limiting API: 10 générations par IP/heure
- Validation des URLs d'applications custom
- Sanitization des paramètres utilisateur

### Logging et audit

- Chaque génération est loggée avec timestamp et IP
- Conservation des configurations générées pendant 30 jours
- Métriques: applications les plus demandées, profils populaires

## Évolutivité future

### Fonctionnalités futures envisageables

1. **Sauvegarde de profils utilisateur**
   - Compte utilisateur avec authentification
   - Historique des scripts générés
   - Partage de profils entre utilisateurs

2. **Marketplace d'optimisations**
   - Communauté contribuant des modules
   - Vote et notation des modules
   - Validation par l'équipe Tenor avant publication

3. **Télémétrie post-installation**
   - Script remonte des statistiques anonymes
   - Taux de succès des installations
   - Temps d'exécution moyen
   - Amélioration continue basée sur les données

4. **Support multi-OS**
   - Adaptation pour Windows Server
   - Support de différentes versions de Windows
   - Détection automatique de l'environnement

5. **Intégration CI/CD**
   - Génération automatique lors du déploiement
   - Tests automatisés des modules
   - Versioning sémantique des modules

## Migration depuis v4.0

### Compatibilité ascendante

Le script v5.0 conserve une compatibilité avec l'ancien format de configuration via la section `legacy_optimizations` dans settings.json. Cela permet une migration progressive.

### Plan de migration

1. **Phase 1:** Déploiement de la v5.0 en parallèle de la v4.0
2. **Phase 2:** Test de la génération Docker en environnement de staging
3. **Phase 3:** Migration progressive des profils vers le nouveau format
4. **Phase 4:** Dépréciation de la v4.0 après 6 mois
5. **Phase 5:** Suppression du support legacy

## Conclusion

Cette architecture modulaire offre une base solide pour l'évolution du projet PostBootSetup. La séparation claire entre les couches web, API et exécution permet une maintenance facilitée et une scalabilité future. L'approche par modules PowerShell indépendants garantit la flexibilité nécessaire pour ajouter ou retirer des fonctionnalités sans impacter le reste du système.

La containerisation Docker assure une portabilité complète du système de génération, tandis que les scripts générés restent autonomes et exécutables sur n'importe quel poste Windows sans dépendances externes.