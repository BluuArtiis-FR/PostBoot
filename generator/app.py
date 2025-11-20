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

# JSON Schema validation (optional dependency)
try:
    import jsonschema
    HAS_JSONSCHEMA = True
except ImportError:
    HAS_JSONSCHEMA = False

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
        # Template main_template.ps1 removed - scripts generated dynamically

    def get_resolved_apps_config(self) -> dict:
        """Retourne une copie du apps_config avec les références résolues."""
        import copy
        resolved = copy.deepcopy(self.apps_config)
        return self._resolve_app_references(resolved)

    @staticmethod
    def _resolve_app_references(data: dict) -> dict:
        """
        Résout les références aux common_apps dans les profils.
        Transforme {"ref": "git", "preselected": true} en objet app complet.
        """
        if 'common_apps' not in data or 'profiles' not in data:
            return data

        common_apps = data.get('common_apps', {})

        # Parcourir tous les profils
        for profile_key, profile_data in data['profiles'].items():
            if 'apps' not in profile_data:
                continue

            resolved_apps = []
            for app in profile_data['apps']:
                # Si c'est une référence (contient "ref")
                if isinstance(app, dict) and 'ref' in app:
                    ref_id = app['ref']

                    # Chercher l'app dans common_apps
                    if ref_id in common_apps:
                        # Copier l'objet complet depuis common_apps
                        resolved_app = common_apps[ref_id].copy()

                        # Appliquer les surcharges du profil (preselected, category, description, etc.)
                        for key, value in app.items():
                            if key != 'ref':
                                resolved_app[key] = value

                        resolved_apps.append(resolved_app)
                    else:
                        logger.warning(f"Référence non trouvée dans common_apps: {ref_id}")
                        resolved_apps.append(app)  # Garder tel quel
                else:
                    # App complète, garder telle quelle
                    resolved_apps.append(app)

            # Remplacer la liste d'apps par la version résolue
            profile_data['apps'] = resolved_apps

        return data

    @staticmethod
    def _load_json(filepath: Path) -> dict:
        """Charge un fichier JSON avec validation optionnelle."""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # NOTE: Ne pas résoudre les références ici pour éviter de modifier la structure
            # La résolution se fait lors de la génération du script avec get_resolved_apps_config()

            # Validation apps.json si jsonschema disponible
            if HAS_JSONSCHEMA and filepath.name == "apps.json":
                # Schéma basique pour apps.json
                schema = {{
                    "type": "object",
                    "required": ["version", "master"],
                    "properties": {{
                        "version": {{"type": "string"}},
                        "master": {{
                            "type": "array",
                            "items": {{
                                "type": "object",
                                "required": ["name"],
                                "properties": {{
                                    "name": {{"type": "string"}},
                                    "winget": {{"type": "string"}},
                                    "url": {{"type": "string"}},
                                    "plugins": {{
                                        "type": "array",
                                        "items": {{"type": "string"}},
                                        "description": "Liste des plugins (Notepad++ uniquement: XML Tools, Compare)"
                                    }}
                                }}
                            }}
                        }}
                    }}
                }}

                try:
                    jsonschema.validate(data, schema)
                    logger.info(f"[OK] Validation JSON Schema réussie: {{filepath.name}}")
                except jsonschema.ValidationError as e:
                    logger.warning(f"[ATTENTION] Validation JSON Schema échouée pour {{filepath.name}}: {{e.message}}")

            return data
        except json.JSONDecodeError as e:
            logger.error(f"Erreur parsing JSON {{filepath}}: {{e}}")
            return {{}}
        except Exception as e:
            logger.error(f"Erreur chargement JSON {{filepath}}: {{e}}")
            return {{}}

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

        # 6. Assembler le script complet
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
        """Génère les fonctions utilitaires communes avec fonctionnalités avancées."""
        utilities = """#region Fonctions Utilitaires

# Initialiser le log JSON structuré
$Global:LogEntries = @()
$Global:JSONLogPath = $LogPath -replace '\\.log$', '.json'

function Write-ScriptLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO',
        [hashtable]$Metadata = @{}
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$Level] $Message"

    # Log vers fichier texte
    try {
        Add-Content -Path $Global:LogPath -Value $logMessage -ErrorAction SilentlyContinue
    } catch { }

    # Ajouter à la collection JSON
    $Global:LogEntries += @{
        Timestamp = $timestamp
        Level = $Level
        Message = $Message
        Metadata = $Metadata
    }

    # Affichage console
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

function Save-JSONLog {
    <#
    .SYNOPSIS
    Sauvegarde le log structuré au format JSON.
    #>
    try {
        $logData = @{
            GeneratedDate = $Global:ScriptMetadata.GeneratedDate
            ProfileName = $Global:ScriptMetadata.ProfileName
            ExecutionStart = $Global:StartTime.ToString('yyyy-MM-dd HH:mm:ss')
            ExecutionEnd = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
            Duration = ((Get-Date) - $Global:StartTime).ToString('hh\\:mm\\:ss')
            Entries = $Global:LogEntries
        }

        $logData | ConvertTo-Json -Depth 5 | Out-File -FilePath $Global:JSONLogPath -Encoding UTF8
        Write-ScriptLog "Log JSON sauvegardé: $Global:JSONLogPath" -Level INFO
    } catch {
        Write-ScriptLog "Impossible de sauvegarder le log JSON: $_" -Level WARNING
    }
}

function Test-IsAdministrator {
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-AppInstalled {
    <#
    .SYNOPSIS
    Vérifie si une application est déjà installée.

    .PARAMETER WingetId
    L'identifiant Winget de l'application.

    .PARAMETER AppName
    Le nom de l'application (utilisé pour recherche dans les programmes installés).

    .OUTPUTS
    Boolean - True si l'application est installée, False sinon
    #>
    param(
        [string]$WingetId,
        [string]$AppName
    )

    # Vérifier via Winget si l'ID est fourni
    if ($WingetId) {
        try {
            $wingetList = winget list --id $WingetId 2>&1 | Out-String
            if ($wingetList -match [regex]::Escape($WingetId)) {
                return $true
            }
        } catch { }
    }

    # Vérifier via le registre Windows
    if ($AppName) {
        $registryPaths = @(
            'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*',
            'HKLM:\\SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*',
            'HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*'
        )

        foreach ($path in $registryPaths) {
            $installed = Get-ItemProperty -Path $path -ErrorAction SilentlyContinue |
                         Where-Object { $_.DisplayName -like "*$AppName*" }

            if ($installed) {
                return $true
            }
        }
    }

    return $false
}

function Get-FileHash-Safe {
    <#
    .SYNOPSIS
    Calcule le hash SHA256 d'un fichier de manière sécurisée.
    #>
    param([string]$FilePath)

    try {
        $hash = Get-FileHash -Path $FilePath -Algorithm SHA256 -ErrorAction Stop
        return $hash.Hash
    } catch {
        Write-ScriptLog "Impossible de calculer le hash de $FilePath" -Level WARNING
        return $null
    }
}

function Install-NotepadPlusPlusPlugins {
    <#
    .SYNOPSIS
    Installe les plugins Notepad++ spécifiés.

    .PARAMETER Plugins
    Liste des noms de plugins à installer.

    .NOTES
    Plugins supportés: XML Tools, Compare
    #>
    param([array]$Plugins)

    if (-not $Plugins -or $Plugins.Count -eq 0) {
        return $true
    }

    # Déterminer le chemin d'installation de Notepad++
    $nppPath = $null
    $possiblePaths = @(
        "$env:ProgramFiles\\Notepad++",
        "${env:ProgramFiles(x86)}\\Notepad++",
        "$env:LOCALAPPDATA\\Programs\\Notepad++"
    )

    foreach ($path in $possiblePaths) {
        if (Test-Path "$path\\notepad++.exe") {
            $nppPath = $path
            break
        }
    }

    if (-not $nppPath) {
        Write-ScriptLog "  [ERREUR] Notepad++ non trouvé, impossible d'installer les plugins" -Level WARNING
        return $false
    }

    $pluginsDir = Join-Path $nppPath "plugins"
    if (-not (Test-Path $pluginsDir)) {
        New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
    }

    Write-ScriptLog "  -> Installation des plugins Notepad++..." -Level INFO

    # Mapping des plugins avec leurs URLs de téléchargement (liste exhaustive des plugins supportés)
    $pluginUrls = @{
        "XML Tools" = @{
            Url = "https://github.com/morbac/xmltools/releases/latest/download/xmltools.zip"
            Folder = "XMLTools"
        }
        "Compare" = @{
            Url = "https://github.com/pnedev/compare-plugin/releases/latest/download/ComparePlus.zip"
            Folder = "ComparePlus"
        }
    }

    # Valider que tous les plugins demandés sont supportés
    $unsupportedPlugins = $Plugins | Where-Object { -not $pluginUrls.ContainsKey($_) }
    if ($unsupportedPlugins) {
        Write-ScriptLog "  [ERREUR] Plugins non supportés détectés: $($unsupportedPlugins -join ', ')" -Level ERROR
        Write-ScriptLog "  [INFO] Plugins supportés: $($pluginUrls.Keys -join ', ')" -Level INFO
        return $false
    }

    $installed = 0
    foreach ($plugin in $Plugins) {
        if ($pluginUrls.ContainsKey($plugin)) {
            try {
                $pluginInfo = $pluginUrls[$plugin]
                $tempZip = Join-Path $env:TEMP "$($pluginInfo.Folder).zip"
                $pluginTargetDir = Join-Path $pluginsDir $pluginInfo.Folder

                Write-ScriptLog "    * Téléchargement de $plugin..." -Level INFO
                Invoke-WebRequest -Uri $pluginInfo.Url -OutFile $tempZip -UseBasicParsing -ErrorAction Stop

                # Extraire le plugin
                if (Test-Path $pluginTargetDir) {
                    Remove-Item $pluginTargetDir -Recurse -Force
                }
                Expand-Archive -Path $tempZip -DestinationPath $pluginTargetDir -Force

                # Nettoyer
                Remove-Item $tempZip -Force

                Write-ScriptLog "    [OK] Plugin $plugin installé" -Level SUCCESS
                $installed++
            } catch {
                Write-ScriptLog "    [ERREUR] Échec installation $plugin : $($_.Exception.Message)" -Level WARNING
            }
        } else {
            Write-ScriptLog "    [ATTENTION] Plugin $plugin non supporté (installation manuelle requise)" -Level WARNING
        }
    }

    if ($installed -gt 0) {
        Write-ScriptLog "  [OK] $installed plugin(s) Notepad++ installé(s)" -Level SUCCESS
    }

    return $true
}

function Install-WingetApp {
    <#
    .SYNOPSIS
    Installe une application via Winget avec vérification préalable.
    #>
    param($App)

    # Vérifier si déjà installé
    if (Test-AppInstalled -WingetId $App.winget -AppName $App.name) {
        Write-ScriptLog "-> $($App.name) déjà installé (ignoré)" -Level INFO

        # Installer les plugins si c'est Notepad++ et qu'ils sont spécifiés
        if ($App.name -eq "Notepad++" -and $App.plugins) {
            Install-NotepadPlusPlusPlugins -Plugins $App.plugins
        }

        return $true
    }

    Write-ScriptLog "Installation: $($App.name)..." -Level INFO

    $maxRetries = 3
    $retryCount = 0

    while ($retryCount -lt $maxRetries) {
        try {
            $output = winget install --id $App.winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-String

            if ($LASTEXITCODE -eq 0 -or $output -match 'successfully installed') {
                Write-ScriptLog "[OK] $($App.name) installé" -Level SUCCESS -Metadata @{ Winget = $App.winget; Retries = $retryCount }

                # Installer les plugins si c'est Notepad++ et qu'ils sont spécifiés
                if ($App.name -eq "Notepad++" -and $App.plugins) {
                    Install-NotepadPlusPlusPlugins -Plugins $App.plugins
                }

                return $true
            } else {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-ScriptLog "Tentative $retryCount/$maxRetries échouée, nouvelle tentative..." -Level WARNING
                    Start-Sleep -Seconds 5
                }
            }
        } catch {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-ScriptLog "Erreur: $_, nouvelle tentative..." -Level WARNING
                Start-Sleep -Seconds 5
            }
        }
    }

    Write-ScriptLog "[ERREUR] Échec $($App.name) après $maxRetries tentatives" -Level ERROR
    return $false
}

function Get-InstallArguments {
    <#
    .SYNOPSIS
    Détermine les arguments d'installation silencieux selon le type de fichier.
    #>
    param(
        [string]$FilePath,
        [string]$CustomArgs
    )

    # Si des arguments personnalisés sont fournis, les utiliser
    if ($CustomArgs) {
        return $CustomArgs
    }

    # Détection automatique selon l'extension
    $extension = [System.IO.Path]::GetExtension($FilePath).ToLower()

    switch ($extension) {
        '.msi' {
            return '/qn /norestart REBOOT=ReallySuppress'
        }
        '.exe' {
            # Tenter de détecter l'installeur
            $fileContent = Get-Content -Path $FilePath -Encoding Byte -TotalCount 1MB -ErrorAction SilentlyContinue
            $contentStr = [System.Text.Encoding]::ASCII.GetString($fileContent)

            if ($contentStr -match 'Inno Setup') {
                return '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
            }
            elseif ($contentStr -match 'Nullsoft') {
                return '/S /NCRC'
            }
            elseif ($contentStr -match 'InstallShield') {
                return '/s /v"/qn"'
            }
            else {
                # Arguments génériques
                return '/S /silent /quiet /q /qn'
            }
        }
        '.zip' {
            Write-ScriptLog "Fichier ZIP détecté, extraction requise" -Level WARNING
            return $null
        }
        default {
            return '/S'
        }
    }
}

function Install-CustomApp {
    <#
    .SYNOPSIS
    Installe une application personnalisée via URL avec retry, validation hash, et détection automatique des arguments.
    #>
    param($App)

    # Vérifier si déjà installé
    if (Test-AppInstalled -AppName $App.name) {
        Write-ScriptLog "-> $($App.name) déjà installé (ignoré)" -Level INFO
        return $true
    }

    Write-ScriptLog "Téléchargement: $($App.name)..." -Level INFO

    try {
        # Remplacer HTTP par HTTPS si possible
        $downloadUrl = $App.url
        if ($downloadUrl -match '^http://') {
            $httpsUrl = $downloadUrl -replace '^http://', 'https://'
            Write-ScriptLog "Tentative HTTPS: $httpsUrl" -Level INFO

            try {
                $testRequest = Invoke-WebRequest -Uri $httpsUrl -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
                $downloadUrl = $httpsUrl
                Write-ScriptLog "[OK] HTTPS disponible, utilisation de la connexion sécurisée" -Level SUCCESS
            } catch {
                Write-ScriptLog "[ATTENTION] HTTPS non disponible, utilisation de HTTP (non sécurisé)" -Level WARNING
            }
        }

        $uri = [System.Uri]$downloadUrl
        $fileName = Split-Path $uri.LocalPath -Leaf
        if (-not $fileName -or $fileName -notmatch '\\.[a-zA-Z0-9]+$') {
            $fileName = "$($App.name -replace '[^a-zA-Z0-9]', '_').exe"
        }

        $tempPath = Join-Path $env:TEMP $fileName

        # Téléchargement avec retry
        $maxRetries = 3
        $retryCount = 0
        $downloaded = $false

        while ($retryCount -lt $maxRetries -and -not $downloaded) {
            try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

                Invoke-WebRequest -Uri $downloadUrl -OutFile $tempPath -UseBasicParsing -TimeoutSec 300 -ErrorAction Stop

                if (Test-Path $tempPath) {
                    $fileSize = (Get-Item $tempPath).Length
                    Write-ScriptLog "[OK] Téléchargement réussi ($([math]::Round($fileSize / 1MB, 2)) MB)" -Level SUCCESS
                    $downloaded = $true
                } else {
                    throw "Fichier non créé"
                }
            } catch {
                $retryCount++
                if ($retryCount -lt $maxRetries) {
                    Write-ScriptLog "Tentative $retryCount/$maxRetries échouée, nouvelle tentative dans 5s..." -Level WARNING
                    Start-Sleep -Seconds 5
                } else {
                    throw "Échec du téléchargement après $maxRetries tentatives: $_"
                }
            }
        }

        # Calculer le hash pour validation
        $fileHash = Get-FileHash-Safe -FilePath $tempPath
        if ($fileHash) {
            Write-ScriptLog "Hash SHA256: $fileHash" -Level INFO -Metadata @{ Hash = $fileHash }
        }

        # Déterminer les arguments d'installation
        $installArgs = Get-InstallArguments -FilePath $tempPath -CustomArgs $App.installArgs

        if ($null -eq $installArgs) {
            Write-ScriptLog "[ATTENTION] Type de fichier non supporté pour installation automatique" -Level WARNING
            Remove-Item $tempPath -ErrorAction SilentlyContinue
            return $false
        }

        Write-ScriptLog "Installation de $($App.name) avec args: $installArgs" -Level INFO

        $process = Start-Process -FilePath $tempPath -ArgumentList $installArgs -Wait -NoNewWindow -PassThru -ErrorAction Stop

        # Nettoyer le fichier temporaire
        Remove-Item $tempPath -ErrorAction SilentlyContinue

        # Codes de sortie acceptables (0 = succès, 3010 = redémarrage requis)
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-ScriptLog "[OK] $($App.name) installé (code: $($process.ExitCode))" -Level SUCCESS -Metadata @{ ExitCode = $process.ExitCode; URL = $App.url }
            return $true
        } else {
            Write-ScriptLog "[ERREUR] $($App.name) - Code erreur: $($process.ExitCode)" -Level ERROR -Metadata @{ ExitCode = $process.ExitCode }
            return $false
        }
    } catch {
        Write-ScriptLog "[ERREUR] Erreur $($App.name): $_" -Level ERROR
        Write-ScriptLog "-> Installation manuelle requise: $($App.url)" -Level WARNING
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
        if (-not $Silent) {{
            Read-Host "Appuyez sur Entrée pour quitter"
        }}
        exit 1
    }}

    Write-ScriptLog "[OK] Droits administrateur validés" -Level SUCCESS

    # Vérification Winget
    try {{
        $null = winget --version
        Write-ScriptLog "[OK] Winget disponible" -Level SUCCESS
    }} catch {{
        Write-ScriptLog "[ERREUR] Winget non disponible" -Level ERROR
        exit 1
    }}

    # Afficher le résumé de configuration
    $totalMasterApps = $Global:EmbeddedConfig.apps.master.Count
    $totalProfileApps = $Global:EmbeddedConfig.apps.profile.Count
    $totalApps = $totalMasterApps + $totalProfileApps

    Write-Host "`n[PACKAGE] Configuration:" -ForegroundColor Cyan
    Write-Host "   - Applications Master: $totalMasterApps" -ForegroundColor White
    Write-Host "   - Applications Profil: $totalProfileApps" -ForegroundColor White
    Write-Host "   - Total: $totalApps applications`n" -ForegroundColor White

    # Confirmation utilisateur (sauf en mode silencieux)
    if (-not $Silent) {{
        Write-Host "[ATTENTION] Cette opération va installer $totalApps applications." -ForegroundColor Yellow
        $confirmation = Read-Host "Voulez-vous continuer? (O/N)"

        if ($confirmation -notmatch '^[OoYy]') {{
            Write-ScriptLog "Installation annulée par l'utilisateur" -Level WARNING
            Write-Host "`nInstallation annulée." -ForegroundColor Yellow
            exit 0
        }}

        Write-Host ""
    }}

{modules_execution}

    # Installation des applications
    Write-ScriptLog "======== INSTALLATION APPLICATIONS ========" -Level INFO

    $stats = @{{ Success = 0; Failed = 0; Skipped = 0 }}
    $currentApp = 0

    # Applications master
    foreach ($app in $Global:EmbeddedConfig.apps.master) {{
        $currentApp++
        $percentComplete = [math]::Round(($currentApp / $totalApps) * 100)
        Write-Progress -Activity "Installation des applications" -Status "Installation: $($app.name) ($currentApp/$totalApps)" -PercentComplete $percentComplete

        if ($app.winget) {{
            $success = Install-WingetApp -App $app
        }} else {{
            $success = Install-CustomApp -App $app
        }}

        if ($success) {{ $stats.Success++ }} else {{ $stats.Failed++ }}
    }}

    # Applications profil
    foreach ($app in $Global:EmbeddedConfig.apps.profile) {{
        $currentApp++
        $percentComplete = [math]::Round(($currentApp / $totalApps) * 100)
        Write-Progress -Activity "Installation des applications" -Status "Installation: $($app.name) ($currentApp/$totalApps)" -PercentComplete $percentComplete

        if ($app.winget) {{
            $success = Install-WingetApp -App $app
        }} else {{
            $success = Install-CustomApp -App $app
        }}

        if ($success) {{ $stats.Success++ }} else {{ $stats.Failed++ }}
    }}

    Write-ScriptLog "Applications: $($stats.Success) installées, $($stats.Failed) échouées" -Level INFO

    # Résumé final
    $duration = (Get-Date) - $Global:StartTime
    $durationFormatted = $duration.ToString("hh\\:mm\\:ss")

    Write-Host @"

================================================================
                      RÉSUMÉ FINAL
================================================================
  Applications installées: $($stats.Success)
  Applications échouées: $($stats.Failed)
  Durée totale: $durationFormatted

  Log complet: $Global:LogPath
  Log JSON: $Global:JSONLogPath
  Support: it@tenorsolutions.com
================================================================

"@ -ForegroundColor Green

    Write-ScriptLog "Exécution terminée avec succès" -Level SUCCESS

    # Sauvegarder le log JSON
    Save-JSONLog

    # Complétion réussie
    $completionSummary = @{{
        'Applications installées' = $stats.Success
        'Applications échouées' = $stats.Failed
        'Durée' = $durationFormatted
    }}

    if (-not $Silent) {{
        Read-Host "`nAppuyez sur Entrée pour terminer"
    }}

    exit 0

}} catch {{
    Write-ScriptLog "ERREUR CRITIQUE: $($_.Exception.Message)" -Level ERROR
    Write-Host "`nUne erreur critique est survenue. Consultez le log: $Global:LogPath" -ForegroundColor Red

    # Sauvegarder le log JSON même en cas d'erreur
    Save-JSONLog

    # Échec
    $failureSummary = @{{
        'Erreur' = $_.Exception.Message
    }}

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
                logger.info(f"[OK] Compilation réussie: {exe_path}")
                return True, None
            else:
                error = result.stderr or "Erreur inconnue lors de la compilation"
                logger.error(f"[ERREUR] Compilation échouée: {error}")
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
    """Retourne la liste de toutes les applications disponibles avec références résolues."""
    try:
        # Utiliser la version résolue pour que le frontend reçoive les objets complets
        resolved_config = generator.get_resolved_apps_config()
        return jsonify({
            'success': True,
            'apps': {
                'master': resolved_config.get('master', []),
                'profiles': resolved_config.get('profiles', {}),
                'optional': resolved_config.get('optional', [])
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
    # Charger les apps depuis la config avec références résolues
    apps_data = generator.get_resolved_apps_config()

    # Construire la liste des apps master (avec déduplication)
    master_apps_dict = {}
    if 'installation' in script_types:
        for app in apps_data.get('master', []):
            app_id = app.get('winget') or app.get('url')
            if app_id in user_config.get('master_apps', []) or user_config.get('profile'):
                # Dédupliquer (au cas où il y aurait des doublons dans la config)
                if app_id not in master_apps_dict:
                    master_apps_dict[app_id] = {
                        'name': app.get('name'),
                        'winget': app.get('winget'),
                        'url': app.get('url'),
                        'size': app.get('size'),
                        'category': app.get('category'),
                        'installArgs': app.get('installArgs')
                    }

    master_apps = list(master_apps_dict.values())

    # Construire la liste des apps de profil + optionnelles
    # IMPORTANT: Utiliser un dictionnaire pour dédupliquer par app_id
    profile_apps_dict = {}
    if 'installation' in script_types:
        # Apps de profil
        for profile_id, profile_data in apps_data.get('profiles', {}).items():
            for app in profile_data.get('apps', []):
                app_id = app.get('winget') or app.get('url')
                if app_id in user_config.get('profile_apps', []):
                    # Ne garder que la première occurrence de chaque app
                    if app_id not in profile_apps_dict:
                        profile_apps_dict[app_id] = {
                            'name': app.get('name'),
                            'winget': app.get('winget'),
                            'url': app.get('url'),
                            'size': app.get('size'),
                            'category': app.get('category'),
                            'installArgs': app.get('installArgs')
                        }

        # Apps optionnelles
        for app in apps_data.get('optional', []):
            app_id = app.get('winget')
            if app_id in user_config.get('optional_apps', []):
                # Ne garder que la première occurrence
                if app_id not in profile_apps_dict:
                    profile_apps_dict[app_id] = {
                        'name': app.get('name'),
                        'winget': app.get('winget'),
                        'size': app.get('size'),
                        'category': app.get('category'),
                        'installArgs': app.get('installArgs')
                    }

    # Convertir le dictionnaire en liste
    profile_apps = list(profile_apps_dict.values())

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
        'TenorWallpaper': True,  # Toujours activé (obligatoire)
        'RestartExplorer': ui_module.get('RestartExplorer', False),
        'TaskbarPosition': ui_module.get('TaskbarPosition', 'Bottom'),
        'ThemeColor': ui_module.get('ThemeColor', '0078D7'),
        # Windows 11 tweaks
        'TaskbarAlignLeft': ui_module.get('TaskbarAlignLeft', False),
        'Windows10ContextMenu': ui_module.get('Windows10ContextMenu', False),
        'HideWidgets': ui_module.get('HideWidgets', False),
        'HideTaskView': ui_module.get('HideTaskView', False),
        'EnableEndTask': ui_module.get('EnableEndTask', False)
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

        # Récupérer le nom du profil (priorité : profile > custom_name > 'Custom')
        profile_name = user_config.get('profile', user_config.get('custom_name', 'Custom'))

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

        # Nom de fichier basé sur le profil (ex: PostBootSetup-TENOR.ps1)
        # Nettoyer le nom du profil (retirer espaces, caractères spéciaux)
        safe_profile_name = profile_name.replace(' ', '-').replace('_', '-')
        script_filename = f"PostBootSetup-{safe_profile_name}.ps1"
        script_path = GENERATED_DIR / script_filename

        # Sauvegarder le script
        with open(script_path, 'w', encoding='utf-8-sig') as f:
            f.write(script_content)

        logger.info(f"[OK] Script généré: {script_filename} ({len(script_content)} chars)")

        # Retourner directement le contenu du script pour téléchargement
        return send_file(
            script_path,
            as_attachment=True,
            download_name=script_filename,
            mimetype='text/plain; charset=utf-8'
        )

    except ValueError as e:
        logger.warning(f"Configuration invalide: {e}")
        return jsonify({'success': False, 'error': f"Configuration invalide: {str(e)}"}), 400
    except KeyError as e:
        logger.warning(f"Champ manquant dans la configuration: {e}")
        return jsonify({'success': False, 'error': f"Champ manquant: {str(e)}"}), 400
    except IOError as e:
        logger.error(f"Erreur fichier lors de la génération: {e}")
        return jsonify({'success': False, 'error': 'Erreur lors de l\'écriture du fichier'}), 500
    except PermissionError as e:
        logger.error(f"Permission refusée: {e}")
        return jsonify({'success': False, 'error': 'Permission refusée lors de l\'écriture du fichier'}), 500
    except Exception as e:
        logger.critical(f"Erreur inattendue lors de la génération: {e}", exc_info=True)
        return jsonify({'success': False, 'error': 'Erreur interne du serveur'}), 500


# Legacy endpoint /api/generate/script removed - use /api/generate instead


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
            logger.info(f"[OK] EXE généré: {exe_filename}")

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