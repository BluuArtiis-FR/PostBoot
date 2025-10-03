#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PostBootSetup Generator API v5.0
API Flask pour la génération dynamique de scripts PowerShell personnalisés

Architecture:
- Endpoints REST pour la configuration et la génération
- Moteur de génération de scripts autonomes
- Compilation optionnelle en .exe via PS2EXE
- Système de cache et de nettoyage automatique
"""

import os
import json
import uuid
import hashlib
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
import logging
from typing import Dict, List, Optional, Tuple

# Configuration de l'application
app = Flask(__name__)
CORS(app)  # Permettre les requêtes cross-origin depuis le frontend

# Configuration des chemins
BASE_DIR = Path(__file__).parent.parent
CONFIG_DIR = BASE_DIR / "config"
MODULES_DIR = BASE_DIR / "modules"
TEMPLATES_DIR = BASE_DIR / "templates"
GENERATED_DIR = BASE_DIR / "generated"

# Créer le dossier generated s'il n'existe pas
GENERATED_DIR.mkdir(exist_ok=True)

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(BASE_DIR / 'generator.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Configuration
MAX_APPS_PER_SCRIPT = 50
MAX_SCRIPT_SIZE_MB = 10
GENERATION_TIMEOUT_SECONDS = 60
CACHE_RETENTION_HOURS = 24
RATE_LIMIT_PER_IP = 20  # Générations par heure


class ScriptGenerator:
    """Moteur de génération de scripts PowerShell autonomes."""

    def __init__(self):
        self.apps_config = self._load_json(CONFIG_DIR / "apps.json")
        self.settings_config = self._load_json(CONFIG_DIR / "settings.json")
        self.template_main = self._load_template("main_template.ps1")

    @staticmethod
    def _load_json(filepath: Path) -> dict:
        """Charge un fichier JSON."""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.error(f"Erreur chargement JSON {filepath}: {e}")
            return {}

    @staticmethod
    def _load_template(filename: str) -> str:
        """Charge un template PowerShell."""
        try:
            filepath = TEMPLATES_DIR / filename
            with open(filepath, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            logger.error(f"Erreur chargement template {filename}: {e}")
            return ""

    @staticmethod
    def _load_module(module_name: str) -> str:
        """Charge le contenu d'un module PowerShell."""
        try:
            filepath = MODULES_DIR / f"{module_name}.psm1"
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

                # Retirer le bloc Export-ModuleMember complet car le code sera inline
                # Pattern: depuis "# Export des fonctions" jusqu'à la parenthèse fermante
                import re
                # Supprime depuis le commentaire Export jusqu'à la ligne avec juste ")"
                content = re.sub(
                    r'#\s*Export des fonctions.*?\n.*?Export-ModuleMember.*?\n(?:.*?\n)*?\)',
                    '',
                    content,
                    flags=re.DOTALL
                )

                return content
        except Exception as e:
            logger.error(f"Erreur chargement module {module_name}: {e}")
            return ""

    def validate_config(self, user_config: dict) -> Tuple[bool, Optional[str]]:
        """
        Valide la configuration utilisateur.

        Returns:
            Tuple (is_valid, error_message)
        """
        # Vérifier la présence des clés obligatoires
        if 'apps' not in user_config:
            return False, "Configuration 'apps' manquante"

        # Limiter le nombre d'applications
        total_apps = len(user_config.get('apps', {}).get('master', [])) + \
                     len(user_config.get('apps', {}).get('profile', []))

        if total_apps > MAX_APPS_PER_SCRIPT:
            return False, f"Nombre maximum d'applications dépassé ({MAX_APPS_PER_SCRIPT})"

        # Valider les modules activés
        if 'modules' in user_config:
            valid_modules = ['debloat', 'performance', 'ui']
            for module in user_config['modules']:
                if module not in valid_modules:
                    return False, f"Module invalide: {module}"

        return True, None

    def generate_script(self, user_config: dict, profile_name: str = "Custom") -> str:
        """
        Génère un script PowerShell autonome basé sur la configuration utilisateur.

        Args:
            user_config: Configuration personnalisée de l'utilisateur
            profile_name: Nom du profil (pour documentation)

        Returns:
            Contenu du script PowerShell généré
        """
        logger.info(f"Génération script pour profil: {profile_name}")

        # Validation
        is_valid, error = self.validate_config(user_config)
        if not is_valid:
            raise ValueError(f"Configuration invalide: {error}")

        # Construction du script
        script_parts = []

        # 1. En-tête avec métadonnées
        header = self._generate_header(profile_name, user_config)
        script_parts.append(header)

        # 2. Configuration embarquée (JSON inline)
        embedded_config = self._generate_embedded_config(user_config)
        script_parts.append(embedded_config)

        # 3. Fonctions utilitaires communes
        utilities = self._generate_utilities()
        script_parts.append(utilities)

        # 4. Modules PowerShell nécessaires (code inline)
        modules_code = self._generate_modules_code(user_config)
        script_parts.append(modules_code)

        # 5. Orchestrateur principal
        orchestrator = self._generate_orchestrator(user_config)
        script_parts.append(orchestrator)

        # Assembler le script complet
        full_script = '\n\n'.join(script_parts)

        logger.info(f"Script généré: {len(full_script)} caractères")
        return full_script

    def _generate_header(self, profile_name: str, config: dict) -> str:
        """Génère l'en-tête du script avec métadonnées."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Compter les applications
        master_count = len(config.get('apps', {}).get('master', []))
        profile_count = len(config.get('apps', {}).get('profile', []))

        # Modules activés
        modules_enabled = config.get('modules', [])

        header = f"""<#
.SYNOPSIS
PostBootSetup - Script généré automatiquement

.DESCRIPTION
Script d'installation et configuration Windows personnalisé
Généré par PostBootSetup Generator v5.0 - Tenor Data Solutions

Profil: {profile_name}
Date génération: {now}
Applications master: {master_count}
Applications profil: {profile_count}
Modules activés: {', '.join(modules_enabled)}

.NOTES
Ce script est autonome et ne nécessite aucun fichier externe.
Exécution requise en tant qu'administrateur.
Compatible: Windows 10 (1809+), Windows 11

.LINK
https://tenorsolutions.com
#>

[CmdletBinding()]
param(
    [switch]$Silent,
    [switch]$NoDebloat,
    [string]$LogPath = "$env:TEMP\\PostBootSetup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
)

# Métadonnées du script
$Global:ScriptMetadata = @{{
    Version = "5.0"
    GeneratedDate = "{now}"
    ProfileName = "{profile_name}"
    Generator = "PostBootSetup API"
}}

$Global:StartTime = Get-Date
$Global:LogPath = $LogPath
"""
        return header

    def _generate_embedded_config(self, config: dict) -> str:
        """Génère la section de configuration embarquée."""
        config_json = json.dumps(config, indent=2, ensure_ascii=False)

        embedded = f"""#region Configuration Embarquée
# Cette configuration a été personnalisée via l'interface web
# et est embarquée directement dans le script pour une autonomie totale

$Global:EmbeddedConfig = @'
{config_json}
'@ | ConvertFrom-Json

#endregion Configuration Embarquée
"""
        return embedded

    def _generate_utilities(self) -> str:
        """Génère les fonctions utilitaires communes."""
        utilities = """#region Fonctions Utilitaires

function Write-ScriptLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"

    try {
        Add-Content -Path $Global:LogPath -Value $logMessage -ErrorAction SilentlyContinue
    } catch { }

    if (-not $Silent) {
        $color = switch ($Level) {
            'SUCCESS' { 'Green' }
            'ERROR' { 'Red' }
            'WARNING' { 'Yellow' }
            default { 'Cyan' }
        }
        Write-Host $Message -ForegroundColor $color
    }
}

function Test-IsAdministrator {
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WingetApp {
    param($App)

    Write-ScriptLog "Installation: $($App.name)..." -Level INFO

    try {
        winget install --id $App.winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null

        if ($LASTEXITCODE -eq 0) {
            Write-ScriptLog "✓ $($App.name) installé" -Level SUCCESS
            return $true
        } else {
            Write-ScriptLog "✗ Échec $($App.name)" -Level ERROR
            return $false
        }
    } catch {
        Write-ScriptLog "✗ Erreur $($App.name): $_" -Level ERROR
        return $false
    }
}

function Install-CustomApp {
    param($App)

    Write-ScriptLog "Téléchargement: $($App.name)..." -Level INFO

    try {
        $uri = [System.Uri]$App.url
        $fileName = Split-Path $uri.LocalPath -Leaf
        if (-not $fileName -or $fileName -notmatch '\.[a-zA-Z0-9]+$') {
            $fileName = "$($App.name -replace '[^a-zA-Z0-9]', '_').exe"
        }

        $tempPath = Join-Path $env:TEMP $fileName

        # Télécharger avec gestion des erreurs SSL
        try {
            # Désactiver temporairement la vérification SSL si nécessaire
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($App.url, $tempPath)
        } catch {
            # Fallback avec Invoke-WebRequest (PowerShell 5.1 compatible)
            Invoke-WebRequest -Uri $App.url -OutFile $tempPath -UseBasicParsing -ErrorAction Stop
        }

        if (-not (Test-Path $tempPath)) {
            throw "Fichier non téléchargé"
        }

        $installArgs = if ($App.installArgs) { $App.installArgs }
                       elseif ($tempPath -match '\\.msi$') { '/qn /norestart' }
                       else { '/S' }

        Write-ScriptLog "Installation de $($App.name)..." -Level INFO
        $process = Start-Process -FilePath $tempPath -ArgumentList $installArgs -Wait -NoNewWindow -PassThru

        Remove-Item $tempPath -ErrorAction SilentlyContinue

        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-ScriptLog "✓ $($App.name) installé" -Level SUCCESS
            return $true
        } else {
            Write-ScriptLog "✗ $($App.name) - Code erreur: $($process.ExitCode)" -Level ERROR
            return $false
        }
    } catch {
        Write-ScriptLog "✗ Erreur $($App.name): $_" -Level ERROR
        Write-ScriptLog "→ Installation manuelle requise: $($App.url)" -Level WARNING
        return $false
    }
}

#endregion Fonctions Utilitaires
"""
        return utilities

    def _generate_modules_code(self, config: dict) -> str:
        """Génère le code inline des modules PowerShell activés."""
        modules_code_parts = []

        # Liste des modules à inclure
        modules_to_include = config.get('modules', [])

        # Debloat est toujours inclus (obligatoire)
        if 'debloat' not in modules_to_include:
            modules_to_include.insert(0, 'debloat')

        # Mapping nom module -> fichier
        module_files = {
            'debloat': 'Debloat-Windows',
            'performance': 'Optimize-Performance',
            'ui': 'Customize-UI'
        }

        for module_name in modules_to_include:
            if module_name in module_files:
                module_file = module_files[module_name]
                module_code = self._load_module(module_file)

                if module_code:
                    modules_code_parts.append(f"#region Module {module_file}")
                    modules_code_parts.append(module_code)
                    modules_code_parts.append(f"#endregion Module {module_file}")

        return '\n\n'.join(modules_code_parts)

    def _generate_orchestrator(self, config: dict) -> str:
        """Génère l'orchestrateur principal qui exécute tout."""

        # Construire les appels de fonctions selon les modules activés
        modules_calls = []

        if 'debloat' in config.get('modules', []) or config.get('debloat_required', True):
            modules_calls.append("""
    # Debloat Windows (obligatoire)
    if (-not $NoDebloat) {
        Write-ScriptLog "======== DEBLOAT WINDOWS ========" -Level INFO
        Invoke-WindowsDebloat
    }
""")

        if 'performance' in config.get('modules', []):
            perf_options = config.get('performance_options', {})
            perf_json = json.dumps(perf_options)
            modules_calls.append(f"""
    # Optimisations de performance
    Write-ScriptLog "======== OPTIMISATIONS PERFORMANCE ========" -Level INFO
    $perfOptionsJson = '{perf_json}' | ConvertFrom-Json
    $perfOptions = @{{}}
    $perfOptionsJson.PSObject.Properties | ForEach-Object {{ $perfOptions[$_.Name] = $_.Value }}
    Invoke-PerformanceOptimizations -Options $perfOptions
""")

        if 'ui' in config.get('modules', []):
            ui_options = config.get('ui_options', {})
            ui_json = json.dumps(ui_options)
            modules_calls.append(f"""
    # Personnalisation interface
    Write-ScriptLog "======== PERSONNALISATION UI ========" -Level INFO
    $uiOptionsJson = '{ui_json}' | ConvertFrom-Json
    $uiOptions = @{{}}
    $uiOptionsJson.PSObject.Properties | ForEach-Object {{ $uiOptions[$_.Name] = $_.Value }}
    Invoke-UICustomizations -Options $uiOptions
""")

        modules_execution = '\n'.join(modules_calls)

        orchestrator = f"""#region Orchestrateur Principal

try {{
    # En-tête
    if (-not $Silent) {{
        Clear-Host
        Write-Host @"

================================================================
             PostBootSetup v$($Global:ScriptMetadata.Version)
                Tenor Data Solutions
         Profil: $($Global:ScriptMetadata.ProfileName)
================================================================

"@ -ForegroundColor Blue
    }}

    Write-ScriptLog "Démarrage PostBootSetup - Profil: $($Global:ScriptMetadata.ProfileName)" -Level INFO

    # Vérification administrateur
    if (-not (Test-IsAdministrator)) {{
        Write-ScriptLog "Droits administrateur requis" -Level ERROR
        Write-Host "`nVeuillez exécuter ce script en tant qu'administrateur" -ForegroundColor Red
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }}

    Write-ScriptLog "✓ Droits administrateur validés" -Level SUCCESS

    # Vérification Winget
    try {{
        $null = winget --version
        Write-ScriptLog "✓ Winget disponible" -Level SUCCESS
    }} catch {{
        Write-ScriptLog "✗ Winget non disponible" -Level ERROR
        exit 1
    }}

    # Installation des applications
    Write-ScriptLog "======== INSTALLATION APPLICATIONS ========" -Level INFO

    $stats = @{{ Success = 0; Failed = 0 }}

    # Applications master
    foreach ($app in $Global:EmbeddedConfig.apps.master) {{
        if ($app.winget) {{
            $success = Install-WingetApp -App $app
        }} else {{
            $success = Install-CustomApp -App $app
        }}

        if ($success) {{ $stats.Success++ }} else {{ $stats.Failed++ }}
    }}

    # Applications profil
    foreach ($app in $Global:EmbeddedConfig.apps.profile) {{
        if ($app.winget) {{
            $success = Install-WingetApp -App $app
        }} else {{
            $success = Install-CustomApp -App $app
        }}

        if ($success) {{ $stats.Success++ }} else {{ $stats.Failed++ }}
    }}

    Write-ScriptLog "Applications: $($stats.Success) installées, $($stats.Failed) échouées" -Level INFO
{modules_execution}

    # Résumé final
    $duration = (Get-Date) - $Global:StartTime

    Write-Host @"

================================================================
                      RÉSUMÉ FINAL
================================================================
  Applications installées: $($stats.Success)
  Applications échouées: $($stats.Failed)
  Durée totale: $($duration.ToString("mm\\:ss"))

  Log complet: $Global:LogPath
  Support: it@tenorsolutions.com
================================================================

"@ -ForegroundColor Green

    Write-ScriptLog "Exécution terminée avec succès" -Level SUCCESS

    if (-not $Silent) {{
        Read-Host "`nAppuyez sur Entrée pour terminer"
    }}

    exit 0

}} catch {{
    Write-ScriptLog "ERREUR CRITIQUE: $($_.Exception.Message)" -Level ERROR
    Write-Host "`nUne erreur critique est survenue. Consultez le log: $Global:LogPath" -ForegroundColor Red

    if (-not $Silent) {{
        Read-Host "`nAppuyez sur Entrée pour quitter"
    }}

    exit 1
}}

#endregion Orchestrateur Principal
"""
        return orchestrator


class PS2EXECompiler:
    """Gestionnaire de compilation PowerShell vers EXE."""

    @staticmethod
    def is_available() -> bool:
        """
        Vérifie si PS2EXE est disponible et fonctionnel.

        Note: PS2EXE nécessite Windows PowerShell (powershell.exe) qui n'existe pas sur Linux.
        La compilation .exe est donc désactivée dans les conteneurs Docker Linux.
        Pour activer cette fonctionnalité, déployez l'API sur un serveur Windows.
        """
        import platform
        if platform.system() != 'Windows':
            logger.warning("Compilation .exe non disponible sur Linux (requiert Windows PowerShell)")
            return False

        try:
            result = subprocess.run(
                ['pwsh', '-Command', 'Get-Module -ListAvailable -Name ps2exe'],
                capture_output=True,
                text=True,
                timeout=10
            )
            return 'ps2exe' in result.stdout.lower()
        except Exception as e:
            logger.error(f"Erreur vérification PS2EXE: {e}")
            return False

    @staticmethod
    def compile_to_exe(ps1_path: Path, exe_path: Path, metadata: dict = None) -> Tuple[bool, Optional[str]]:
        """
        Compile un script PowerShell en exécutable.

        Args:
            ps1_path: Chemin du script .ps1 source
            exe_path: Chemin de l'exécutable .exe destination
            metadata: Métadonnées optionnelles (titre, description, version, etc.)

        Returns:
            Tuple (success, error_message)
        """
        if not PS2EXECompiler.is_available():
            return False, "PS2EXE non disponible sur ce système"

        metadata = metadata or {}

        # Utiliser notre wrapper personnalisé compatible Linux
        wrapper_path = Path(__file__).parent.parent / 'compile_ps_to_exe.ps1'

        cmd_parts = [
            'pwsh', '-NoProfile', '-NonInteractive', '-File', str(wrapper_path),
            '-InputFile', str(ps1_path),
            '-OutputFile', str(exe_path),
            '-Title', metadata.get('title', 'PostBootSetup'),
            '-Description', metadata.get('description', 'Tenor Data Solutions - Installation automatisée'),
            '-Company', metadata.get('company', 'Tenor Data Solutions'),
            '-Version', metadata.get('version', '5.0.0'),
            '-NoConsole',
            '-RequireAdmin',
            '-X64',
            '-Lcid', '1036'
        ]

        try:
            logger.info(f"Compilation {ps1_path.name} vers {exe_path.name}...")

            result = subprocess.run(
                cmd_parts,
                capture_output=True,
                text=True,
                timeout=GENERATION_TIMEOUT_SECONDS
            )

            if result.returncode == 0 and exe_path.exists():
                logger.info(f"✓ Compilation réussie: {exe_path}")
                return True, None
            else:
                error = result.stderr or "Erreur inconnue lors de la compilation"
                logger.error(f"✗ Compilation échouée: {error}")
                return False, error

        except subprocess.TimeoutExpired:
            return False, "Timeout lors de la compilation"
        except Exception as e:
            logger.error(f"Exception lors de la compilation: {e}")
            return False, str(e)


# Instance globale du générateur
generator = ScriptGenerator()


#region API Endpoints

@app.route('/api/health', methods=['GET'])
def health_check():
    """Vérification de l'état de l'API."""
    return jsonify({
        'status': 'healthy',
        'version': '5.0',
        'timestamp': datetime.now().isoformat(),
        'ps2exe_available': PS2EXECompiler.is_available()
    })


@app.route('/api/profiles', methods=['GET'])
def get_profiles():
    """Retourne la liste des profils disponibles."""
    try:
        profiles_data = []

        for profile_key in generator.apps_config.get('profiles', {}).keys():
            profile = generator.apps_config['profiles'][profile_key]
            profiles_data.append({
                'id': profile_key,
                'name': profile.get('name', profile_key),
                'description': profile.get('description', ''),
                'apps_count': len(profile.get('apps', []))
            })

        return jsonify({
            'success': True,
            'profiles': profiles_data
        })
    except Exception as e:
        logger.error(f"Erreur récupération profils: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/apps', methods=['GET'])
def get_apps():
    """Retourne la liste de toutes les applications disponibles."""
    try:
        return jsonify({
            'success': True,
            'apps': {
                'master': generator.apps_config.get('master', []),
                'profiles': generator.apps_config.get('profiles', {}),
                'optional': generator.apps_config.get('optional', [])
            }
        })
    except Exception as e:
        logger.error(f"Erreur récupération apps: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@app.route('/api/modules', methods=['GET'])
def get_modules():
    """Retourne la liste des modules d'optimisation disponibles."""
    try:
        return jsonify({
            'success': True,
            'modules': generator.settings_config.get('modules', {})
        })
    except Exception as e:
        logger.error(f"Erreur récupération modules: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


def transform_user_config_to_api_config(user_config: dict, script_types: list) -> dict:
    """
    Transforme la config utilisateur (avec IDs) en config API (avec objets complets).

    user_config contient:
    - master_apps: liste d'IDs (winget ou url)
    - profile_apps: liste d'IDs
    - optional_apps: liste d'IDs
    - modules: config des modules

    Retourne une config API avec:
    - apps: {master: [objets], profile: [objets]}
    - modules: ['debloat', 'performance', 'ui']
    - performance_options: {...}
    - ui_options: {...}
    """
    # Charger les apps depuis la config
    apps_data = generator.apps_config

    # Construire la liste des apps master
    master_apps = []
    if 'installation' in script_types:
        for app in apps_data.get('master', []):
            app_id = app.get('winget') or app.get('url')
            if app_id in user_config.get('master_apps', []) or user_config.get('profile'):
                master_apps.append({
                    'name': app.get('name'),
                    'winget': app.get('winget'),
                    'url': app.get('url'),
                    'size': app.get('size'),
                    'category': app.get('category')
                })

    # Construire la liste des apps de profil + optionnelles
    profile_apps = []
    if 'installation' in script_types:
        # Apps de profil
        for profile_id, profile_data in apps_data.get('profiles', {}).items():
            for app in profile_data.get('apps', []):
                app_id = app.get('winget') or app.get('url')
                if app_id in user_config.get('profile_apps', []):
                    profile_apps.append({
                        'name': app.get('name'),
                        'winget': app.get('winget'),
                        'url': app.get('url'),
                        'size': app.get('size')
                    })

        # Apps optionnelles
        for app in apps_data.get('optional', []):
            app_id = app.get('winget')
            if app_id in user_config.get('optional_apps', []):
                profile_apps.append({
                    'name': app.get('name'),
                    'winget': app.get('winget'),
                    'size': app.get('size')
                })

    # Construire la liste des modules actifs
    modules = []
    modules_config = user_config.get('modules', {})

    if 'optimizations' in script_types:
        # Debloat est toujours inclus
        modules.append('debloat')

        # Gérer deux formats de config modules:
        # Format 1 (array): modules: ["debloat", "performance", "ui"]
        # Format 2 (object): modules: { performance: { enabled: true }, ui: { enabled: true } }

        # Si modules est un tableau (format API direct)
        if isinstance(modules_config, list):
            if 'performance' in modules_config:
                modules.append('performance')
            if 'ui' in modules_config:
                modules.append('ui')
        # Si modules est un objet (format interface web)
        elif isinstance(modules_config, dict):
            # Performance si activé
            if modules_config.get('performance', {}).get('enabled', False):
                modules.append('performance')
            # UI si activé
            if modules_config.get('ui', {}).get('enabled', False):
                modules.append('ui')

    # Options de performance
    perf_module = {}
    if isinstance(modules_config, dict):
        perf_module = modules_config.get('performance', {})

    performance_options = {
        'PageFile': perf_module.get('PageFile', False),
        'PowerPlan': perf_module.get('PowerPlan', False),
        'StartupPrograms': perf_module.get('StartupPrograms', False),
        'Network': perf_module.get('Network', False),
        'VisualEffects': perf_module.get('VisualEffects', False)
    } if 'performance' in modules else {}

    # Options UI
    ui_module = {}
    if isinstance(modules_config, dict):
        ui_module = modules_config.get('ui', {})

    ui_options = {
        'DarkMode': ui_module.get('DarkMode', False),
        'ShowFileExtensions': ui_module.get('ShowFileExtensions', False),
        'ShowFullPath': ui_module.get('ShowFullPath', False),
        'ShowHiddenFiles': ui_module.get('ShowHiddenFiles', False),
        'ShowThisPC': ui_module.get('ShowThisPC', False),
        'ShowRecycleBin': ui_module.get('ShowRecycleBin', False),
        'RestartExplorer': ui_module.get('RestartExplorer', False),
        'TaskbarPosition': ui_module.get('TaskbarPosition', 'Bottom'),
        'ThemeColor': ui_module.get('ThemeColor', '0078D7')
    } if 'ui' in modules else {}

    return {
        'profile_name': user_config.get('custom_name', 'Custom'),
        'description': f"Configuration générée le {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
        'apps': {
            'master': master_apps,
            'profile': profile_apps
        },
        'modules': modules,
        'debloat_required': True,
        'performance_options': performance_options,
        'ui_options': ui_options
    }


@app.route('/api/generate', methods=['POST'])
def generate():
    """
    Génère un script PowerShell personnalisé avec modules sélectionnés.
    Supporte: installation, optimizations, diagnostic (seul ou combinés).
    """
    try:
        request_data = request.json
        user_config = request_data.get('config', {})
        script_types = request_data.get('scriptTypes', ['installation', 'optimizations'])

        profile_name = user_config.get('custom_name', 'Custom')

        # Déterminer le nom du script basé sur les types sélectionnés
        if len(script_types) == 1:
            script_type_names = {
                'installation': 'Installation',
                'optimizations': 'Optimizations',
                'diagnostic': 'Diagnostic'
            }
            type_suffix = script_type_names.get(script_types[0], 'Custom')
        elif len(script_types) == 3:
            type_suffix = 'Complete'
        else:
            type_suffix = '_'.join([t.capitalize() for t in script_types])

        logger.info(f"Requête génération - Profil: {profile_name} - Types: {script_types} - IP: {request.remote_addr}")

        # Transformer la config utilisateur en config pour le générateur
        api_config = transform_user_config_to_api_config(user_config, script_types)

        # Gérer diagnostic (à implémenter plus tard)
        include_diagnostic = 'diagnostic' in script_types

        # Générer le script
        script_content = generator.generate_script(api_config, profile_name)

        # Si diagnostic demandé, ajouter le module de diagnostic
        if include_diagnostic:
            diagnostic_module = self._load_template("diagnostic_module.ps1") if hasattr(generator, '_load_template') else "# Diagnostic module à implémenter"
            script_content += f"\n\n# === MODULE DIAGNOSTIC ===\n{diagnostic_module}"

        # Créer un ID unique pour ce script
        script_id = str(uuid.uuid4())
        script_filename = f"PostBootSetup_{type_suffix}_{script_id[:8]}.ps1"
        script_path = GENERATED_DIR / script_filename

        # Sauvegarder le script
        with open(script_path, 'w', encoding='utf-8-sig') as f:
            f.write(script_content)

        logger.info(f"✓ Script généré: {script_filename} ({len(script_content)} chars)")

        # Retourner directement le contenu du script pour téléchargement
        return send_file(
            script_path,
            as_attachment=True,
            download_name=script_filename,
            mimetype='text/plain; charset=utf-8'
        )

    except ValueError as e:
        logger.warning(f"Configuration invalide: {e}")
        return jsonify({'success': False, 'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Erreur génération script: {e}")
        return jsonify({'success': False, 'error': 'Erreur interne du serveur'}), 500


@app.route('/api/generate/script', methods=['POST'])
def generate_script():
    """Génère un script PowerShell personnalisé (legacy endpoint)."""
    try:
        user_config = request.json
        profile_name = user_config.get('profile_name', 'Custom')

        logger.info(f"Requête génération script - Profil: {profile_name} - IP: {request.remote_addr}")

        # Générer le script
        script_content = generator.generate_script(user_config, profile_name)

        # Créer un ID unique pour ce script
        script_id = str(uuid.uuid4())
        script_filename = f"PostBootSetup_{profile_name}_{script_id[:8]}.ps1"
        script_path = GENERATED_DIR / script_filename

        # Sauvegarder le script
        with open(script_path, 'w', encoding='utf-8-sig') as f:
            f.write(script_content)

        logger.info(f"✓ Script généré: {script_filename} ({len(script_content)} chars)")

        return jsonify({
            'success': True,
            'script_id': script_id,
            'filename': script_filename,
            'size': len(script_content),
            'download_url': f'/api/download/{script_id}'
        })

    except ValueError as e:
        logger.warning(f"Configuration invalide: {e}")
        return jsonify({'success': False, 'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Erreur génération script: {e}")
        return jsonify({'success': False, 'error': 'Erreur interne du serveur'}), 500


@app.route('/api/generate/executable', methods=['POST'])
def generate_executable():
    """Génère un exécutable Windows (.exe) via PS2EXE."""
    try:
        user_config = request.json
        profile_name = user_config.get('profile_name', 'Custom')

        logger.info(f"Requête génération EXE - Profil: {profile_name} - IP: {request.remote_addr}")

        # Vérifier disponibilité PS2EXE
        if not PS2EXECompiler.is_available():
            return jsonify({
                'success': False,
                'error': 'PS2EXE non disponible sur ce serveur'
            }), 503

        # Générer d'abord le script
        script_content = generator.generate_script(user_config, profile_name)

        # Créer un ID unique
        script_id = str(uuid.uuid4())
        ps1_filename = f"PostBootSetup_{profile_name}_{script_id[:8]}.ps1"
        exe_filename = ps1_filename.replace('.ps1', '.exe')

        ps1_path = GENERATED_DIR / ps1_filename
        exe_path = GENERATED_DIR / exe_filename

        # Sauvegarder le script temporaire
        with open(ps1_path, 'w', encoding='utf-8-sig') as f:
            f.write(script_content)

        # Compiler en EXE
        metadata = {
            'title': f'PostBootSetup - {profile_name}',
            'description': 'Tenor Data Solutions - Installation et configuration automatisée Windows',
            'company': 'Tenor Data Solutions',
            'version': '5.0.0'
        }

        success, error = PS2EXECompiler.compile_to_exe(ps1_path, exe_path, metadata)

        # Supprimer le .ps1 temporaire
        ps1_path.unlink(missing_ok=True)

        if success:
            logger.info(f"✓ EXE généré: {exe_filename}")

            return jsonify({
                'success': True,
                'script_id': script_id,
                'filename': exe_filename,
                'size': exe_path.stat().st_size,
                'download_url': f'/api/download/{script_id}'
            })
        else:
            return jsonify({
                'success': False,
                'error': f'Compilation échouée: {error}'
            }), 500

    except ValueError as e:
        logger.warning(f"Configuration invalide: {e}")
        return jsonify({'success': False, 'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Erreur génération EXE: {e}")
        return jsonify({'success': False, 'error': 'Erreur interne du serveur'}), 500


@app.route('/api/download/<script_id>', methods=['GET'])
def download_file(script_id):
    """Télécharge un fichier généré (.ps1 ou .exe)."""
    try:
        # Chercher le fichier correspondant à l'ID
        matching_files = list(GENERATED_DIR.glob(f"*{script_id[:8]}*"))

        if not matching_files:
            return jsonify({'success': False, 'error': 'Fichier non trouvé'}), 404

        file_path = matching_files[0]

        logger.info(f"Téléchargement: {file_path.name} - IP: {request.remote_addr}")

        return send_file(
            file_path,
            as_attachment=True,
            download_name=file_path.name,
            mimetype='text/plain; charset=utf-8'
        )

    except Exception as e:
        logger.error(f"Erreur téléchargement: {e}")
        return jsonify({'success': False, 'error': 'Erreur lors du téléchargement'}), 500


#endregion API Endpoints


#region Tâches de maintenance

def cleanup_old_files():
    """Nettoie les fichiers générés de plus de CACHE_RETENTION_HOURS heures."""
    try:
        cutoff_time = datetime.now() - timedelta(hours=CACHE_RETENTION_HOURS)
        deleted_count = 0

        for file_path in GENERATED_DIR.glob('*'):
            if file_path.is_file():
                file_mtime = datetime.fromtimestamp(file_path.stat().st_mtime)

                if file_mtime < cutoff_time:
                    file_path.unlink()
                    deleted_count += 1
                    logger.debug(f"Supprimé: {file_path.name} (ancien)")

        if deleted_count > 0:
            logger.info(f"Nettoyage: {deleted_count} fichiers supprimés")

    except Exception as e:
        logger.error(f"Erreur nettoyage: {e}")


#endregion


if __name__ == '__main__':
    logger.info("="*60)
    logger.info("PostBootSetup Generator API v5.0 - Démarrage")
    logger.info("="*60)
    logger.info(f"Dossier config: {CONFIG_DIR}")
    logger.info(f"Dossier modules: {MODULES_DIR}")
    logger.info(f"Dossier templates: {TEMPLATES_DIR}")
    logger.info(f"Dossier generated: {GENERATED_DIR}")
    logger.info(f"PS2EXE disponible: {PS2EXECompiler.is_available()}")
    logger.info("="*60)

    # Nettoyage au démarrage
    cleanup_old_files()

    # Démarrer l'API
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=False
    )