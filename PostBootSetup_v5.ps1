# PostBootSetup v5.0 - Tenor Data Solutions
# Installation et configuration automatisée des postes de travail
# Architecture modulaire compatible génération Docker

<#
.SYNOPSIS
Script d'installation et configuration automatisée Windows avec architecture modulaire.

.DESCRIPTION
Ce script orchestrateur charge dynamiquement des modules PowerShell spécialisés pour effectuer
l'installation d'applications via Winget, l'optimisation système (debloat obligatoire),
et les personnalisations optionnelles selon la configuration fournie.

L'architecture modulaire permet une génération dynamique depuis une API Docker où l'utilisateur
peut personnaliser chaque aspect du déploiement via une interface web.

.PARAMETER UserProfile
Nom du profil prédéfini à utiliser (DEV, SUPPORT, SI) ou chemin vers un profil personnalisé JSON.

.PARAMETER ConfigFile
Chemin vers un fichier de configuration JSON personnalisé généré par l'API web.

.PARAMETER Silent
Mode silencieux sans interaction utilisateur.

.PARAMETER SkipDebloat
Ignore le debloat Windows obligatoire (non recommandé, uniquement pour tests).

.PARAMETER SkipApps
Ignore l'installation des applications.

.PARAMETER SkipOptimizations
Ignore toutes les optimisations optionnelles.

.PARAMETER LogPath
Chemin vers le fichier de log (par défaut: .\PostBootSetup.log).

.EXAMPLE
.\PostBootSetup_v5.ps1
Exécution interactive avec sélection de profil.

.EXAMPLE
.\PostBootSetup_v5.ps1 -UserProfile "DEV" -Silent
Installation silencieuse du profil développeur.

.EXAMPLE
.\PostBootSetup_v5.ps1 -ConfigFile "C:\Temp\custom_config.json"
Installation avec configuration personnalisée depuis l'API web.

.NOTES
Version: 5.0
Auteur: Tenor Data Solutions - Service IT
Compatible: Windows 10 (1809+), Windows 11
Requis: PowerShell 5.1+, Winget, Droits administrateur
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage="Profil prédéfini (DEV, SUPPORT, SI) ou chemin JSON personnalisé")]
    [string]$UserProfile = "",

    [Parameter(HelpMessage="Fichier de configuration JSON personnalisé")]
    [string]$ConfigFile = "",

    [Parameter(HelpMessage="Mode silencieux sans interaction")]
    [switch]$Silent,

    [Parameter(HelpMessage="Ignorer le debloat Windows (non recommandé)")]
    [switch]$SkipDebloat,

    [Parameter(HelpMessage="Ignorer l'installation des applications")]
    [switch]$SkipApps,

    [Parameter(HelpMessage="Ignorer les optimisations optionnelles")]
    [switch]$SkipOptimizations,

    [Parameter(HelpMessage="Chemin du fichier de log")]
    [string]$LogPath = "",

    [Parameter(HelpMessage="Afficher l'aide")]
    [switch]$Help
)

#region Configuration globale

$Global:ScriptVersion = "5.0"
$Global:ScriptRoot = $PSScriptRoot
$Global:StartTime = Get-Date
$Global:ModulesPath = Join-Path $Global:ScriptRoot "modules"
$Global:ConfigPath = Join-Path $Global:ScriptRoot "config"
$Global:LogEnabled = $true

# Initialiser le chemin de log
if ([string]::IsNullOrEmpty($LogPath)) {
    $Global:LogPath = Join-Path $Global:ScriptRoot "PostBootSetup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
} else {
    $Global:LogPath = $LogPath
}

# Palette de couleurs Tenor
$Global:Colors = @{
    Primary = "Blue"
    Success = "Green"
    Error = "Red"
    Warning = "Yellow"
    Info = "Cyan"
    Gray = "Gray"
}

#endregion

#region Fonctions utilitaires

function Write-Log {
    <#
    .SYNOPSIS
    Écrit un message dans le fichier de log et optionnellement à l'écran.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO",

        [Parameter()]
        [switch]$NoConsole
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"

    # Écrire dans le fichier de log
    if ($Global:LogEnabled) {
        try {
            Add-Content -Path $Global:LogPath -Value $logMessage -ErrorAction Stop
        } catch {
            Write-Warning "Impossible d'écrire dans le log: $_"
        }
    }

    # Afficher à l'écran si non silencieux
    if (-not $NoConsole -and -not $Silent) {
        $color = switch ($Level) {
            "SUCCESS" { $Global:Colors.Success }
            "ERROR" { $Global:Colors.Error }
            "WARNING" { $Global:Colors.Warning }
            "DEBUG" { $Global:Colors.Gray }
            default { $Global:Colors.Info }
        }

        Write-Host $Message -ForegroundColor $color
    }
}

function Show-Header {
    <#
    .SYNOPSIS
    Affiche l'en-tête du script avec informations de version.
    #>
    if (-not $Silent) {
        try { Clear-Host } catch { }

        $header = @"

================================================================
             PostBootSetup v$Global:ScriptVersion
          Tenor Data Solutions - Service IT
          Architecture Modulaire | Génération Docker
================================================================

"@
        Write-Host $header -ForegroundColor $Global:Colors.Primary
    }

    Write-Log "Démarrage PostBootSetup v$Global:ScriptVersion" -Level "INFO"
}

function Show-Help {
    <#
    .SYNOPSIS
    Affiche l'aide détaillée du script.
    #>
    Get-Help $PSCommandPath -Detailed
}

function Test-Administrator {
    <#
    .SYNOPSIS
    Vérifie si le script s'exécute avec les droits administrateur.
    #>
    $currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-ElevateScript {
    <#
    .SYNOPSIS
    Relance le script avec les droits administrateur si nécessaire.
    #>
    Write-Log "Droits administrateur requis - Relancement du script..." -Level "WARNING"

    # Reconstruire les arguments
    $argsList = @()
    if ($UserProfile) { $argsList += "-UserProfile `"$UserProfile`"" }
    if ($ConfigFile) { $argsList += "-ConfigFile `"$ConfigFile`"" }
    if ($Silent) { $argsList += "-Silent" }
    if ($SkipDebloat) { $argsList += "-SkipDebloat" }
    if ($SkipApps) { $argsList += "-SkipApps" }
    if ($SkipOptimizations) { $argsList += "-SkipOptimizations" }
    if ($LogPath) { $argsList += "-LogPath `"$LogPath`"" }

    $arguments = "-ExecutionPolicy Bypass -File `"$PSCommandPath`" " + ($argsList -join " ")

    try {
        Start-Process powershell -Verb RunAs -ArgumentList $arguments -Wait
        Write-Log "Script relancé avec succès en mode administrateur" -Level "SUCCESS"
        exit 0
    } catch {
        Write-Log "Impossible de relancer en administrateur: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Test-Prerequisites {
    <#
    .SYNOPSIS
    Vérifie tous les prérequis nécessaires à l'exécution du script.
    #>
    Write-Log "Vérification des prérequis..." -Level "INFO"

    $allValid = $true

    # Vérification administrateur
    if (-not (Test-Administrator)) {
        $allValid = Invoke-ElevateScript
        if (-not $allValid) {
            Write-Log "Droits administrateur requis" -Level "ERROR"
            return $false
        }
    } else {
        Write-Log "✓ Droits administrateur validés" -Level "SUCCESS"
    }

    # Vérification Winget
    try {
        $wingetVersion = (winget --version 2>$null)
        if ($wingetVersion) {
            Write-Log "✓ Winget disponible ($wingetVersion)" -Level "SUCCESS"
        } else {
            throw "Winget non détecté"
        }
    } catch {
        Write-Log "✗ Winget non disponible - Installation requise" -Level "ERROR"
        $allValid = $false
    }

    # Vérification PowerShell version
    $psVersion = $PSVersionTable.PSVersion
    if ($psVersion.Major -ge 5) {
        Write-Log "✓ PowerShell $($psVersion.ToString()) compatible" -Level "SUCCESS"
    } else {
        Write-Log "✗ PowerShell 5.1+ requis (version actuelle: $psVersion)" -Level "ERROR"
        $allValid = $false
    }

    # Vérification modules disponibles
    if (Test-Path $Global:ModulesPath) {
        $moduleFiles = Get-ChildItem -Path $Global:ModulesPath -Filter "*.psm1"
        Write-Log "✓ $($moduleFiles.Count) modules disponibles" -Level "SUCCESS"
    } else {
        Write-Log "✗ Dossier modules introuvable: $Global:ModulesPath" -Level "ERROR"
        $allValid = $false
    }

    return $allValid
}

function Import-CustomModules {
    <#
    .SYNOPSIS
    Importe tous les modules PowerShell personnalisés depuis le dossier modules.
    #>
    Write-Log "Chargement des modules personnalisés..." -Level "INFO"

    $modulesLoaded = 0

    $moduleFiles = Get-ChildItem -Path $Global:ModulesPath -Filter "*.psm1" -ErrorAction SilentlyContinue

    foreach ($moduleFile in $moduleFiles) {
        try {
            Import-Module $moduleFile.FullName -Force -ErrorAction Stop
            Write-Log "✓ Module chargé: $($moduleFile.BaseName)" -Level "SUCCESS"
            $modulesLoaded++
        } catch {
            Write-Log "✗ Erreur chargement module $($moduleFile.Name): $($_.Exception.Message)" -Level "ERROR"
        }
    }

    Write-Log "$modulesLoaded modules chargés avec succès" -Level "INFO"
    return $modulesLoaded -gt 0
}

function Get-ConfigurationData {
    <#
    .SYNOPSIS
    Charge la configuration depuis les fichiers JSON ou depuis un fichier personnalisé.
    #>
    Write-Log "Chargement de la configuration..." -Level "INFO"

    try {
        # Charger configuration des applications
        $appsJsonPath = Join-Path $Global:ConfigPath "apps.json"
        if (-not (Test-Path $appsJsonPath)) {
            throw "Fichier apps.json introuvable: $appsJsonPath"
        }
        $appsConfig = Get-Content $appsJsonPath -Raw | ConvertFrom-Json

        # Charger configuration des paramètres
        $settingsJsonPath = Join-Path $Global:ConfigPath "settings.json"
        if (-not (Test-Path $settingsJsonPath)) {
            throw "Fichier settings.json introuvable: $settingsJsonPath"
        }
        $settingsConfig = Get-Content $settingsJsonPath -Raw | ConvertFrom-Json

        Write-Log "✓ Configuration chargée avec succès" -Level "SUCCESS"

        return @{
            Apps = $appsConfig
            Settings = $settingsConfig
        }
    } catch {
        Write-Log "Erreur lors du chargement de la configuration: $($_.Exception.Message)" -Level "ERROR"
        return $null
    }
}

function Invoke-DebloatModule {
    <#
    .SYNOPSIS
    Exécute le module de debloat Windows (obligatoire).
    #>
    Write-Log "Exécution du debloat Windows (obligatoire)..." -Level "INFO"

    try {
        $result = Invoke-WindowsDebloat
        if ($result.Success) {
            Write-Log "✓ Debloat Windows terminé avec succès" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "✗ Debloat Windows échoué: $($result.Error)" -Level "ERROR"
            return $false
        }
    } catch {
        Write-Log "✗ Erreur critique lors du debloat: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Invoke-PerformanceModule {
    <#
    .SYNOPSIS
    Exécute le module d'optimisation de performance avec les options configurées.
    #>
    param(
        [hashtable]$Options
    )

    Write-Log "Exécution des optimisations de performance..." -Level "INFO"

    try {
        $result = Invoke-PerformanceOptimizations -Options $Options
        Write-Log "✓ Optimisations de performance terminées" -Level "SUCCESS"
        Write-Log "  Exécutées: $($result.Executed.Count) | Échouées: $($result.Failed.Count)" -Level "INFO"
        return $result
    } catch {
        Write-Log "✗ Erreur lors des optimisations: $($_.Exception.Message)" -Level "ERROR"
        return $null
    }
}

function Invoke-UIModule {
    <#
    .SYNOPSIS
    Exécute le module de personnalisation de l'interface avec les options configurées.
    #>
    param(
        [hashtable]$Options,
        [bool]$RestartExplorer = $true
    )

    Write-Log "Application des personnalisations d'interface..." -Level "INFO"

    try {
        $result = Invoke-UICustomizations -Options $Options -RestartExplorer $RestartExplorer
        Write-Log "✓ Personnalisations d'interface terminées" -Level "SUCCESS"
        Write-Log "  Réussies: $($result.Success.Count) | Échouées: $($result.Failed.Count)" -Level "INFO"
        return $result
    } catch {
        Write-Log "✗ Erreur lors des personnalisations: $($_.Exception.Message)" -Level "ERROR"
        return $null
    }
}

function Install-WingetApplication {
    <#
    .SYNOPSIS
    Installe une application via Winget.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$App
    )

    Write-Log "Installation: $($App.name)..." -Level "INFO"

    try {
        $output = winget install --id $App.winget --silent --accept-package-agreements --accept-source-agreements 2>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Log "✓ $($App.name) installé avec succès" -Level "SUCCESS"
            return $true
        } else {
            Write-Log "✗ Échec installation $($App.name) (Exit code: $LASTEXITCODE)" -Level "ERROR"
            return $false
        }
    } catch {
        Write-Log "✗ Erreur installation $($App.name): $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Install-CustomApplication {
    <#
    .SYNOPSIS
    Télécharge et installe une application depuis une URL personnalisée.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$App
    )

    Write-Log "Téléchargement: $($App.name) depuis $($App.url)..." -Level "INFO"

    try {
        # Déterminer le nom de fichier
        $uri = [System.Uri]$App.url
        $fileName = Split-Path $uri.LocalPath -Leaf
        if (-not $fileName -or $fileName -notmatch '\.[a-zA-Z0-9]+$') {
            $fileName = "$($App.name -replace '[^a-zA-Z0-9]', '_').exe"
        }

        $tempPath = Join-Path $env:TEMP $fileName

        # Télécharger
        Invoke-WebRequest -Uri $App.url -OutFile $tempPath -UseBasicParsing -ErrorAction Stop

        Write-Log "Installation: $($App.name)..." -Level "INFO"

        # Arguments d'installation
        $installArgs = if ($App.installArgs) {
            $App.installArgs
        } elseif ($tempPath -match '\.msi$') {
            "/qn /norestart"
        } else {
            "/S"
        }

        # Installer
        Start-Process -FilePath $tempPath -ArgumentList $installArgs -Wait -NoNewWindow -ErrorAction Stop

        # Nettoyer
        Remove-Item $tempPath -Force -ErrorAction SilentlyContinue

        Write-Log "✓ $($App.name) installé avec succès" -Level "SUCCESS"
        return $true
    } catch {
        Write-Log "✗ Erreur installation $($App.name): $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Install-Applications {
    <#
    .SYNOPSIS
    Installe toutes les applications selon le profil sélectionné.
    #>
    param(
        [Parameter(Mandatory=$true)]
        $Config,

        [Parameter()]
        [string]$SelectedProfile
    )

    Write-Log "======== INSTALLATION DES APPLICATIONS ========" -Level "INFO"

    $stats = @{
        Success = 0
        Failed = 0
        Skipped = 0
    }

    # Applications Master (obligatoires)
    Write-Log "Installation des applications obligatoires..." -Level "INFO"
    foreach ($app in $Config.Apps.master) {
        if ($app.winget) {
            $success = Install-WingetApplication -App $app
        } else {
            $success = Install-CustomApplication -App $app
        }

        if ($success) {
            $stats.Success++
        } else {
            $stats.Failed++
        }
    }

    # Applications du profil sélectionné
    if ($SelectedProfile -and $Config.Apps.profiles.$SelectedProfile) {
        Write-Log "Installation des applications du profil: $SelectedProfile" -Level "INFO"

        foreach ($app in $Config.Apps.profiles.$SelectedProfile.apps) {
            if ($app.winget) {
                $success = Install-WingetApplication -App $app
            } else {
                $success = Install-CustomApplication -App $app
            }

            if ($success) {
                $stats.Success++
            } else {
                $stats.Failed++
            }
        }
    }

    Write-Log "Installation terminée: $($stats.Success) succès, $($stats.Failed) échecs" -Level "INFO"
    return $stats
}

function Show-Summary {
    <#
    .SYNOPSIS
    Affiche le résumé final de l'exécution.
    #>
    param(
        [hashtable]$Stats,
        [TimeSpan]$Duration
    )

    $summary = @"

================================================================
                      RESUME FINAL
================================================================
  Applications installées: $($Stats.Success)
  Applications échouées: $($Stats.Failed)

  Durée totale: $($Duration.ToString("mm\:ss"))

  Log complet: $Global:LogPath
  Support: it@tenorsolutions.com
================================================================

"@

    Write-Host $summary -ForegroundColor $Global:Colors.Primary
    Write-Log "Exécution terminée" -Level "INFO"
}

#endregion

#region Programme principal

try {
    # Afficher en-tête
    Show-Header

    # Afficher l'aide si demandé
    if ($Help) {
        Show-Help
        exit 0
    }

    # Vérifier les prérequis
    if (-not (Test-Prerequisites)) {
        Write-Log "Prérequis non satisfaits - Arrêt du script" -Level "ERROR"
        if (-not $Silent) {
            Read-Host "`nAppuyez sur Entrée pour quitter"
        }
        exit 1
    }

    # Charger les modules personnalisés
    if (-not (Import-CustomModules)) {
        Write-Log "Impossible de charger les modules - Arrêt du script" -Level "ERROR"
        exit 1
    }

    # Charger la configuration
    $config = Get-ConfigurationData
    if (-not $config) {
        Write-Log "Configuration invalide - Arrêt du script" -Level "ERROR"
        exit 1
    }

    # Exécuter le debloat obligatoire (sauf si explicitement ignoré)
    if (-not $SkipDebloat) {
        $debloatSuccess = Invoke-DebloatModule
        if (-not $debloatSuccess) {
            Write-Log "Debloat échoué mais poursuite de l'exécution..." -Level "WARNING"
        }
    } else {
        Write-Log "Debloat Windows ignoré (paramètre -SkipDebloat)" -Level "WARNING"
    }

    # Installer les applications
    $appStats = @{ Success = 0; Failed = 0 }
    if (-not $SkipApps) {
        $appStats = Install-Applications -Config $config -SelectedProfile $UserProfile
    } else {
        Write-Log "Installation des applications ignorée (paramètre -SkipApps)" -Level "WARNING"
    }

    # Appliquer les optimisations optionnelles
    if (-not $SkipOptimizations) {
        # Optimisations de performance
        if ($config.Settings.modules.performance.enabled) {
            $perfOptions = @{}
            foreach ($opt in $config.Settings.modules.performance.options.PSObject.Properties) {
                if ($opt.Value.enabled) {
                    $perfOptions[$opt.Name] = $true
                }
            }
            Invoke-PerformanceModule -Options $perfOptions
        }

        # Personnalisation UI
        if ($config.Settings.modules.ui.enabled) {
            $uiOptions = @{}
            foreach ($opt in $config.Settings.modules.ui.options.PSObject.Properties) {
                if ($opt.Value.enabled) {
                    $uiOptions[$opt.Name] = $opt.Value.value
                }
            }
            $restartExplorer = if ($config.Settings.modules.ui.options.RestartExplorer.enabled) {
                $config.Settings.modules.ui.options.RestartExplorer.value
            } else {
                $false
            }
            Invoke-UIModule -Options $uiOptions -RestartExplorer $restartExplorer
        }
    } else {
        Write-Log "Optimisations ignorées (paramètre -SkipOptimizations)" -Level "WARNING"
    }

    # Afficher le résumé
    $duration = (Get-Date) - $Global:StartTime
    Show-Summary -Stats $appStats -Duration $duration

    if (-not $Silent) {
        Read-Host "`nAppuyez sur Entrée pour terminer"
    }

    exit 0

} catch {
    Write-Log "ERREUR CRITIQUE: $($_.Exception.Message)" -Level "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level "DEBUG"

    if (-not $Silent) {
        Write-Host "`nUne erreur critique est survenue. Consultez le log: $Global:LogPath" -ForegroundColor Red
        Read-Host "`nAppuyez sur Entrée pour quitter"
    }

    exit 1
}

#endregion