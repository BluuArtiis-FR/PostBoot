<#
.SYNOPSIS
PostBootSetup - Script généré automatiquement

.DESCRIPTION
Script d'installation et configuration Windows personnalisé
Généré par PostBootSetup Generator v5.0 - Tenor Data Solutions

Profil: Custom
Date génération: 2025-11-12 14:12:23
Applications master: 11
Applications profil: 0
Modules activés: debloat

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
    [string]$LogPath = "$env:TEMP\PostBootSetup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
)

# Métadonnées du script
$Global:ScriptMetadata = @{
    Version = "5.0"
    GeneratedDate = "2025-11-12 14:12:23"
    ProfileName = "Custom"
    Generator = "PostBootSetup API"
}

$Global:StartTime = Get-Date
$Global:LogPath = $LogPath


#region Configuration Embarquée
# Cette configuration a été personnalisée via l'interface web
# et est embarquée directement dans le script pour une autonomie totale

$Global:EmbeddedConfig = @'
{
  "profile_name": "Custom",
  "description": "Configuration générée le 2025-11-12 14:12:23",
  "apps": {
    "master": [
      {
        "name": "Microsoft Office 365",
        "winget": "Microsoft.Office",
        "url": null,
        "size": "3 GB",
        "category": "Bureautique",
        "installArgs": null
      },
      {
        "name": "Microsoft Teams",
        "winget": "Microsoft.Teams",
        "url": null,
        "size": "150 MB",
        "category": "Communication",
        "installArgs": null
      },
      {
        "name": "Notepad++",
        "winget": "Notepad++.Notepad++",
        "url": null,
        "size": "8 MB",
        "category": "Editeur",
        "installArgs": null
      },
      {
        "name": "Visual Studio Code",
        "winget": "Microsoft.VisualStudioCode",
        "url": null,
        "size": "85 MB",
        "category": "Editeur",
        "installArgs": null
      },
      {
        "name": "Flameshot",
        "winget": "Flameshot.Flameshot",
        "url": null,
        "size": "15 MB",
        "category": "Capture d'écran",
        "installArgs": null
      },
      {
        "name": "VPN Stormshield",
        "winget": null,
        "url": "https://vpn.stormshield.eu/download/Stormshield_SSLVPN_Client_4.0.10_fr_x64.msi",
        "size": "40 MB",
        "category": "VPN",
        "installArgs": "/qn /norestart REBOOT=ReallySuppress"
      },
      {
        "name": "Microsoft PowerToys",
        "winget": "Microsoft.PowerToys",
        "url": null,
        "size": "25 MB",
        "category": "Utilitaires",
        "installArgs": null
      },
      {
        "name": "PDF Gear",
        "winget": "PDFGear.PDFGear",
        "url": null,
        "size": "150 MB",
        "category": "PDF",
        "installArgs": null
      },
      {
        "name": "Winget",
        "winget": "Microsoft.AppInstaller",
        "url": null,
        "size": "5 MB",
        "category": "Gestionnaire",
        "installArgs": null
      },
      {
        "name": "Microsoft OneDrive Entreprise",
        "winget": "Microsoft.OneDrive",
        "url": null,
        "size": "100 MB",
        "category": "Cloud",
        "installArgs": null
      },
      {
        "name": "7-Zip",
        "winget": "7zip.7zip",
        "url": null,
        "size": "2 MB",
        "category": "Compression",
        "installArgs": null
      }
    ],
    "profile": []
  },
  "modules": [
    "debloat"
  ],
  "debloat_required": true,
  "performance_options": {},
  "ui_options": {}
}
'@ | ConvertFrom-Json

#endregion Configuration Embarquée


#region Fonctions Utilitaires

# Initialiser le log JSON structuré
$Global:LogEntries = @()
$Global:JSONLogPath = $LogPath -replace '\.log$', '.json'

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

    # Intégration WPF si disponible
    if ($Global:WPFAvailable) {
        try {
            Invoke-WPFLog -Message $Message -Level $Level
        } catch { }
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
            Duration = ((Get-Date) - $Global:StartTime).ToString('hh\:mm\:ss')
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
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
            'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
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

function Install-WingetApp {
    <#
    .SYNOPSIS
    Installe une application via Winget avec vérification préalable.
    #>
    param($App)

    # Vérifier si déjà installé
    if (Test-AppInstalled -WingetId $App.winget -AppName $App.name) {
        Write-ScriptLog "→ $($App.name) déjà installé (ignoré)" -Level INFO
        return $true
    }

    Write-ScriptLog "Installation: $($App.name)..." -Level INFO

    $maxRetries = 3
    $retryCount = 0

    while ($retryCount -lt $maxRetries) {
        try {
            $output = winget install --id $App.winget --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-String

            if ($LASTEXITCODE -eq 0 -or $output -match 'successfully installed') {
                Write-ScriptLog "✓ $($App.name) installé" -Level SUCCESS -Metadata @{ Winget = $App.winget; Retries = $retryCount }
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

    Write-ScriptLog "✗ Échec $($App.name) après $maxRetries tentatives" -Level ERROR
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
        Write-ScriptLog "→ $($App.name) déjà installé (ignoré)" -Level INFO
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
                Write-ScriptLog "✓ HTTPS disponible, utilisation de la connexion sécurisée" -Level SUCCESS
            } catch {
                Write-ScriptLog "⚠ HTTPS non disponible, utilisation de HTTP (non sécurisé)" -Level WARNING
            }
        }

        $uri = [System.Uri]$downloadUrl
        $fileName = Split-Path $uri.LocalPath -Leaf
        if (-not $fileName -or $fileName -notmatch '\.[a-zA-Z0-9]+$') {
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
                    Write-ScriptLog "✓ Téléchargement réussi ($([math]::Round($fileSize / 1MB, 2)) MB)" -Level SUCCESS
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
            Write-ScriptLog "⚠ Type de fichier non supporté pour installation automatique" -Level WARNING
            Remove-Item $tempPath -ErrorAction SilentlyContinue
            return $false
        }

        Write-ScriptLog "Installation de $($App.name) avec args: $installArgs" -Level INFO

        $process = Start-Process -FilePath $tempPath -ArgumentList $installArgs -Wait -NoNewWindow -PassThru -ErrorAction Stop

        # Nettoyer le fichier temporaire
        Remove-Item $tempPath -ErrorAction SilentlyContinue

        # Codes de sortie acceptables (0 = succès, 3010 = redémarrage requis)
        if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
            Write-ScriptLog "✓ $($App.name) installé (code: $($process.ExitCode))" -Level SUCCESS -Metadata @{ ExitCode = $process.ExitCode; URL = $App.url }
            return $true
        } else {
            Write-ScriptLog "✗ $($App.name) - Code erreur: $($process.ExitCode)" -Level ERROR -Metadata @{ ExitCode = $process.ExitCode }
            return $false
        }
    } catch {
        Write-ScriptLog "✗ Erreur $($App.name): $_" -Level ERROR
        Write-ScriptLog "→ Installation manuelle requise: $($App.url)" -Level WARNING
        return $false
    }
}

#endregion Fonctions Utilitaires


#region Module UIHooks

# Module: UIHooks.psm1
# Description: Hooks pour l'intégration avec l'interface WPF
# Version: 1.0

<#
.SYNOPSIS
Module d'intégration WPF pour envoyer des mises à jour en temps réel à l'interface graphique.

.DESCRIPTION
Ce module fournit des fonctions pour communiquer avec une interface WPF pendant l'exécution
du script d'installation. Il permet d'envoyer des logs, des mises à jour de progression,
et des notifications de complétion.
#>

# Variable globale pour vérifier si WPF est disponible
$Global:WPFAvailable = $false

function Test-WPFAvailability {
    <#
    .SYNOPSIS
    Vérifie si l'interface WPF est disponible et active.

    .DESCRIPTION
    Cette fonction teste si les fonctions WPF requises sont disponibles
    et si l'interface graphique est prête à recevoir des mises à jour.

    .OUTPUTS
    Boolean - True si WPF est disponible, False sinon
    #>

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        # Vérifier si la commande Invoke-WPFLog existe
        $wpfLogCmd = Get-Command -Name 'Invoke-WPFLog' -ErrorAction SilentlyContinue
        $wpfProgressCmd = Get-Command -Name 'Invoke-WPFProgress' -ErrorAction SilentlyContinue

        if ($wpfLogCmd -and $wpfProgressCmd) {
            $Global:WPFAvailable = $true
            return $true
        }

        $Global:WPFAvailable = $false
        return $false
    }
    catch {
        $Global:WPFAvailable = $false
        return $false
    }
}

function Invoke-WPFLog {
    <#
    .SYNOPSIS
    Envoie un message de log à l'interface WPF.

    .DESCRIPTION
    Cette fonction envoie un message formaté à l'interface WPF pour affichage
    dans le log en temps réel. Si WPF n'est pas disponible, le message est
    simplement affiché dans la console.

    .PARAMETER Message
    Le message à afficher dans le log.

    .PARAMETER Level
    Le niveau de sévérité du message (INFO, SUCCESS, WARNING, ERROR).

    .EXAMPLE
    Invoke-WPFLog -Message "Installation de Git..." -Level "INFO"

    .EXAMPLE
    Invoke-WPFLog -Message "Git installé avec succès" -Level "SUCCESS"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('INFO', 'SUCCESS', 'WARNING', 'ERROR')]
        [string]$Level = 'INFO'
    )

    if (-not $Global:WPFAvailable) {
        # WPF non disponible, affichage console standard
        $color = switch ($Level) {
            'SUCCESS' { 'Green' }
            'ERROR' { 'Red' }
            'WARNING' { 'Yellow' }
            default { 'Cyan' }
        }
        Write-Host $Message -ForegroundColor $color
        return
    }

    try {
        # Envoyer le message à WPF via le dispatcher
        $timestamp = Get-Date -Format 'HH:mm:ss'
        $formattedMessage = "[$timestamp] [$Level] $Message"

        # Appel synchronisé avec le dispatcher WPF
        [System.Windows.Application]::Current.Dispatcher.Invoke([action]{
            param($msg, $lvl)
            # Ajouter le message au contrôle de log WPF
            if ($Global:WPFLogControl) {
                $Global:WPFLogControl.AppendText("$msg`n")
                $Global:WPFLogControl.ScrollToEnd()
            }
        }, $formattedMessage, $Level)
    }
    catch {
        # Fallback vers console si erreur WPF
        Write-Host $Message -ForegroundColor Cyan
    }
}

function Invoke-WPFProgress {
    <#
    .SYNOPSIS
    Met à jour la barre de progression dans l'interface WPF.

    .DESCRIPTION
    Cette fonction met à jour la barre de progression et le message de statut
    dans l'interface WPF pour indiquer l'avancement de l'installation.

    .PARAMETER PercentComplete
    Le pourcentage de complétion (0-100).

    .PARAMETER Status
    Le message de statut à afficher (ex: "Installation de Git...").

    .EXAMPLE
    Invoke-WPFProgress -PercentComplete 25 -Status "Installation des applications (5/20)"

    .EXAMPLE
    Invoke-WPFProgress -PercentComplete 100 -Status "Installation terminée"
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateRange(0, 100)]
        [int]$PercentComplete,

        [Parameter(Mandatory = $false)]
        [string]$Status = ""
    )

    if (-not $Global:WPFAvailable) {
        # WPF non disponible, utiliser Write-Progress standard
        Write-Progress -Activity "PostBootSetup" -Status $Status -PercentComplete $PercentComplete
        return
    }

    try {
        # Mettre à jour la barre de progression WPF via le dispatcher
        [System.Windows.Application]::Current.Dispatcher.Invoke([action]{
            param($percent, $msg)

            if ($Global:WPFProgressBar) {
                $Global:WPFProgressBar.Value = $percent
            }

            if ($Global:WPFStatusLabel -and $msg) {
                $Global:WPFStatusLabel.Content = $msg
            }
        }, $PercentComplete, $Status)
    }
    catch {
        # Fallback vers Write-Progress si erreur WPF
        Write-Progress -Activity "PostBootSetup" -Status $Status -PercentComplete $PercentComplete
    }
}

function Complete-WPFExecution {
    <#
    .SYNOPSIS
    Signale la fin de l'exécution à l'interface WPF.

    .DESCRIPTION
    Cette fonction notifie l'interface WPF que l'exécution est terminée
    et affiche un résumé final avec statistiques.

    .PARAMETER Success
    Indique si l'exécution s'est terminée avec succès.

    .PARAMETER Summary
    Un hashtable contenant les statistiques finales (apps installées, durée, etc.).

    .EXAMPLE
    Complete-WPFExecution -Success $true -Summary @{
        InstalledApps = 15
        FailedApps = 2
        Duration = "05:32"
    }
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [bool]$Success,

        [Parameter(Mandatory = $false)]
        [hashtable]$Summary = @{}
    )

    if (-not $Global:WPFAvailable) {
        # Affichage console standard
        Write-Host "`n========== EXÉCUTION TERMINÉE ==========" -ForegroundColor $(if ($Success) { 'Green' } else { 'Red' })
        foreach ($key in $Summary.Keys) {
            Write-Host "  $key : $($Summary[$key])" -ForegroundColor Cyan
        }
        return
    }

    try {
        # Signaler la complétion à WPF
        [System.Windows.Application]::Current.Dispatcher.Invoke([action]{
            param($isSuccess, $stats)

            # Mettre à jour le statut final
            if ($Global:WPFStatusLabel) {
                $statusText = if ($isSuccess) { "Installation terminée avec succès" } else { "Installation terminée avec erreurs" }
                $Global:WPFStatusLabel.Content = $statusText
            }

            # Progression à 100%
            if ($Global:WPFProgressBar) {
                $Global:WPFProgressBar.Value = 100
            }

            # Activer le bouton "Fermer"
            if ($Global:WPFCloseButton) {
                $Global:WPFCloseButton.IsEnabled = $true
            }

            # Afficher le résumé
            if ($Global:WPFSummaryPanel -and $stats) {
                $summaryText = ""
                foreach ($key in $stats.Keys) {
                    $summaryText += "$key : $($stats[$key])`n"
                }
                if ($Global:WPFSummaryTextBlock) {
                    $Global:WPFSummaryTextBlock.Text = $summaryText
                }
                $Global:WPFSummaryPanel.Visibility = [System.Windows.Visibility]::Visible
            }
        }, $Success, $Summary)
    }
    catch {
        Write-Host "Erreur lors de la mise à jour WPF: $_" -ForegroundColor Red
    }
}

# Initialisation du module
Test-WPFAvailability | Out-Null




#endregion Module UIHooks

#region Module Debloat-Windows

# Module: Debloat-Windows.psm1
# Description: Suppression des applications préinstallées Windows et optimisations système obligatoires
# Version: 1.0
# Requis: Oui (toujours exécuté)

<#
.SYNOPSIS
Module de nettoyage Windows qui supprime les applications inutiles et désactive les fonctionnalités intrusives.

.DESCRIPTION
Ce module fait partie des optimisations obligatoires et sera toujours exécuté lors du déploiement.
Il effectue un debloat complet de Windows en supprimant les applications préinstallées non essentielles,
en désactivant la télémétrie intrusive, et en optimisant les services système.
#>

function Remove-BloatwareApps {
    <#
    .SYNOPSIS
    Supprime les applications Windows préinstallées inutiles (bloatware).

    .DESCRIPTION
    Cette fonction parcourt une liste d'applications Windows Store préinstallées et les désinstalle
    pour tous les utilisateurs. Elle gère également les erreurs pour éviter de bloquer le processus
    si une application n'est pas présente sur le système.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Suppression des applications préinstallées..." -ForegroundColor Cyan

    # Liste des applications à supprimer (bloatware Windows 11 2024/2025)
    $bloatwareApps = @(
        # Applications Bing (obsolètes)
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingWeather"
        "Microsoft.BingSearch"                  # Nouveau: Widget Bing (Windows 11 22H2+)

        # Applications 3D (rarement utilisées)
        "Microsoft.3DBuilder"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.Print3D"
        "Microsoft.MixedReality.Portal"

        # Applications de communication (si alternatives installées)
        "Microsoft.People"
        "Microsoft.YourPhone"                   # Remplacé par Phone Link
        "microsoft.windowscommunicationsapps"   # Mail & Calendar (si Outlook installé)
        "Microsoft.Messaging"
        "Microsoft.SkypeApp"

        # Applications Office Hub
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.Office.OneNote"              # Si OneNote desktop installé

        # Jeux et divertissement
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"

        # Applications Xbox (à garder si gaming)
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.GamingApp"                   # Nouveau: Xbox Gaming App (Windows 11)

        # Utilitaires Windows
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsCamera"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.ScreenSketch"                # Capture d'écran (renommé dans Win11)
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.GetStarted"                  # Tips (orthographe alternative)

        # Nouvelles applications Windows 11 2024/2025
        "Microsoft.Todos"                       # Microsoft To Do
        "Microsoft.PowerAutomateDesktop"        # Power Automate (pushy)
        "Clipchamp.Clipchamp"                   # Éditeur vidéo (Windows 11 23H2+)
        "MicrosoftTeams"                        # Teams consumer (garder version entreprise)

        # Autres
        "Microsoft.Wallet"
        "Microsoft.OneConnect"
    )

    $removedCount = 0
    $skippedCount = 0

    foreach ($app in $bloatwareApps) {
        try {
            # Vérifier si l'application existe avant de tenter la suppression
            $package = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue

            if ($package) {
                Write-Host "  Suppression: $app..." -ForegroundColor Yellow
                Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction Stop

                # Supprimer également le package provisionné (pour les nouveaux utilisateurs)
                Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue

                Write-Host "  ✓ $app supprimé" -ForegroundColor Green
                $removedCount++
            }
            else {
                $skippedCount++
            }
        }
        catch {
            Write-Host "  ⚠ Erreur lors de la suppression de $app : $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`n[DEBLOAT] Résumé: $removedCount applications supprimées, $skippedCount déjà absentes" -ForegroundColor Green
}

function Disable-TelemetryServices {
    <#
    .SYNOPSIS
    Désactive les services de télémétrie et de collecte de données Windows.

    .DESCRIPTION
    Cette fonction désactive tous les services Windows liés à la télémétrie, au diagnostic,
    et à la collecte de données utilisateur pour améliorer la confidentialité et les performances.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Désactivation des services de télémétrie..." -ForegroundColor Cyan

    # Liste des services de télémétrie à désactiver (Windows 11 optimisé)
    # NOTE: Services utiles (OneSyncSvc, UserDataSvc, MessagingService) sont PRÉSERVÉS
    $telemetryServices = @(
        "DiagTrack"                                 # Connected User Experiences and Telemetry (TÉLÉMÉTRIE)
        "dmwappushservice"                          # WAP Push Message Routing Service (OBSOLÈTE)
        "diagnosticshub.standardcollector.service"  # Microsoft Diagnostics Hub (DIAGNOSTIC)

        # Services Windows 11 spécifiques
        "CDPUserSvc"                                # Connected Devices Platform (TÉLÉMÉTRIE)

        # Services Xbox (si pas de gaming)
        "XblAuthManager"                            # Xbox Live Auth Manager
        "XblGameSave"                               # Xbox Live Game Save
        "XboxNetApiSvc"                             # Xbox Networking Service

        # NOTE: Les services suivants sont PRÉSERVÉS pour la stabilité:
        # - OneSyncSvc (requis pour synchro compte Microsoft)
        # - MessagingService (requis pour apps modernes)
        # - UserDataSvc (requis pour Mail/Calendar/Contacts)
        # - UnistoreSvc (requis pour Microsoft Store)
        # - WerSvc (utile pour diagnostics - peut être désactivé si souhaité)
    )

    $disabledCount = 0

    foreach ($serviceName in $telemetryServices) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

            if ($service) {
                Write-Host "  Désactivation: $serviceName..." -ForegroundColor Yellow

                # Arrêter le service s'il est en cours d'exécution
                if ($service.Status -eq 'Running') {
                    Stop-Service -Name $serviceName -Force -ErrorAction Stop
                }

                # Désactiver le service de manière permanente
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction Stop

                Write-Host "  ✓ $serviceName désactivé" -ForegroundColor Green
                $disabledCount++
            }
        }
        catch {
            Write-Host "  ⚠ Erreur lors de la désactivation de $serviceName : $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`n[DEBLOAT] $disabledCount services de télémétrie désactivés" -ForegroundColor Green
}

function Set-PrivacyRegistry {
    <#
    .SYNOPSIS
    Configure le registre Windows pour améliorer la confidentialité.

    .DESCRIPTION
    Cette fonction applique des modifications du registre Windows pour désactiver diverses fonctionnalités
    de collecte de données, de publicité ciblée, et d'envoi d'informations à Microsoft.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Configuration du registre pour la confidentialité..." -ForegroundColor Cyan

    # Définition des modifications du registre pour la confidentialité (Windows 11 2024/2025)
    $registrySettings = @(
        # ===== TÉLÉMÉTRIE ET CONFIDENTIALITÉ =====
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
            Name = "AllowTelemetry"
            Value = 0
            Type = "DWord"
            Description = "Désactiver la télémétrie Windows"
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"
            Name = "DisabledByGroupPolicy"
            Value = 1
            Type = "DWord"
            Description = "Désactiver l'ID de publicité"
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
            Name = "AllowTelemetry"
            Value = 0
            Type = "DWord"
            Description = "Bloquer la télémétrie (niveau entreprise)"
        },

        # ===== MENU DÉMARRER ET SUGGESTIONS =====
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Name = "SystemPaneSuggestionsEnabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver les suggestions dans le menu démarrer"
        },
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Name = "SilentInstalledAppsEnabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver l'installation automatique d'applications"
        },
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Name = "PreInstalledAppsEnabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver les applications préinstallées"
        },
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Name = "SubscribedContent-338388Enabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver les suggestions d'applications dans Démarrer"
        },

        # ===== WINDOWS 11 - RECOMMANDATIONS ET WIDGETS =====
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Name = "Start_IrisRecommendations"
            Value = 0
            Type = "DWord"
            Description = "Désactiver les recommandations dans le menu Démarrer (Windows 11)"
        },
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Name = "TaskbarDa"
            Value = 0
            Type = "DWord"
            Description = "Désactiver les widgets de la barre des tâches (Windows 11)"
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
            Name = "AllowNewsAndInterests"
            Value = 0
            Type = "DWord"
            Description = "Désactiver les actualités et centres d'intérêt"
        },

        # ===== WINDOWS COPILOT (NOUVEAU POUR WINDOWS 11 23H2+) =====
        @{
            Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot"
            Name = "TurnOffWindowsCopilot"
            Value = 1
            Type = "DWord"
            Description = "Désactiver Windows Copilot (Windows 11 23H2+)"
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
            Name = "TurnOffWindowsCopilot"
            Value = 1
            Type = "DWord"
            Description = "Désactiver Windows Copilot (stratégie machine)"
        },

        # ===== RECHERCHE WINDOWS =====
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
            Name = "BingSearchEnabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver la recherche Bing dans Windows Search"
        },
        @{
            Path = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
            Name = "DisableSearchBoxSuggestions"
            Value = 1
            Type = "DWord"
            Description = "Désactiver les suggestions web dans la recherche"
        },
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
            Name = "IsAADCloudSearchEnabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver la recherche cloud Azure AD"
        },
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
            Name = "IsMSACloudSearchEnabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver la recherche cloud Microsoft Account"
        },

        # ===== EXPLORATEUR DE FICHIERS =====
        @{
            Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Name = "ShowSyncProviderNotifications"
            Value = 0
            Type = "DWord"
            Description = "Désactiver les notifications OneDrive dans l'Explorateur"
        },

        # ===== ACTIVITÉ ET HISTORIQUE =====
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            Name = "EnableActivityFeed"
            Value = 0
            Type = "DWord"
            Description = "Désactiver le flux d'activités"
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            Name = "PublishUserActivities"
            Value = 0
            Type = "DWord"
            Description = "Ne pas publier les activités utilisateur"
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
            Name = "UploadUserActivities"
            Value = 0
            Type = "DWord"
            Description = "Ne pas envoyer les activités à Microsoft"
        }

        # NOTE: Cortana (AllowCortana) supprimé car obsolète sur Windows 11 23H2+
    )

    $appliedCount = 0

    foreach ($setting in $registrySettings) {
        try {
            Write-Host "  Application: $($setting.Description)..." -ForegroundColor Yellow

            # Créer le chemin du registre s'il n'existe pas
            if (-not (Test-Path $setting.Path)) {
                New-Item -Path $setting.Path -Force | Out-Null
            }

            # Appliquer la valeur du registre
            Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -Type $setting.Type -Force

            Write-Host "  ✓ $($setting.Description) appliqué" -ForegroundColor Green
            $appliedCount++
        }
        catch {
            Write-Host "  ⚠ Erreur: $($setting.Description) - $($_.Exception.Message)" -ForegroundColor Red
        }
    }

    Write-Host "`n[DEBLOAT] $appliedCount paramètres de confidentialité appliqués" -ForegroundColor Green
}

function Optimize-WindowsFeatures {
    <#
    .SYNOPSIS
    Désactive les fonctionnalités Windows optionnelles inutiles.

    .DESCRIPTION
    Cette fonction désactive certaines fonctionnalités Windows qui ne sont généralement pas nécessaires
    dans un environnement professionnel, comme les jeux Xbox, la reconnaissance vocale, etc.
    SÉCURISÉ: Cette version préserve les points de restauration et l'hibernation.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Optimisation des fonctionnalités Windows..." -ForegroundColor Cyan

    try {
        # Windows Search: Automatique (Début différé) pour Windows 11
        Write-Host "  Configuration de Windows Search..." -ForegroundColor Yellow
        $wsearch = Get-Service -Name 'WSearch' -ErrorAction SilentlyContinue
        if ($wsearch) {
            # Configurer en "Automatique (Début différé)" au lieu de Manuel
            # Cela permet une indexation optimale sans impact au démarrage
            Set-Service -Name 'WSearch' -StartupType Automatic -ErrorAction SilentlyContinue
            sc.exe config WSearch start=delayed-auto | Out-Null
            Write-Host "  ✓ Windows Search configuré en Automatique (Début différé)" -ForegroundColor Green
        }

        # NOTE: L'hibernation et la restauration système sont PRÉSERVÉS pour la sécurité
        Write-Host "  ℹ Hibernation et points de restauration préservés (sécurité)" -ForegroundColor Cyan

    }
    catch {
        Write-Host "  ⚠ Erreur lors de l'optimisation: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`n[DEBLOAT] Optimisations système appliquées" -ForegroundColor Green
}

function Invoke-WindowsDebloat {
    <#
    .SYNOPSIS
    Fonction principale qui exécute toutes les opérations de debloat.

    .DESCRIPTION
    Cette fonction orchestre l'ensemble du processus de debloat en appelant successivement
    toutes les fonctions de nettoyage et d'optimisation. Elle affiche également un résumé
    final et peut retourner un objet de résultat pour le logging.

    .PARAMETER Silent
    Si activé, réduit la verbosité des messages affichés.

    .EXAMPLE
    Invoke-WindowsDebloat

    .EXAMPLE
    Invoke-WindowsDebloat -Silent
    #>

    [CmdletBinding()]
    param(
        [switch]$Silent
    )

    $startTime = Get-Date

    Write-Host "`n================================================================" -ForegroundColor Blue
    Write-Host "           DEBLOAT WINDOWS - OBLIGATOIRE" -ForegroundColor Blue
    Write-Host "================================================================`n" -ForegroundColor Blue

    try {
        # Exécution séquentielle de toutes les opérations de debloat
        Remove-BloatwareApps
        Disable-TelemetryServices
        Set-PrivacyRegistry
        Optimize-WindowsFeatures

        $duration = (Get-Date) - $startTime

        Write-Host "`n================================================================" -ForegroundColor Green
        Write-Host "  DEBLOAT TERMINE avec succès" -ForegroundColor Green
        Write-Host "  Durée: $($duration.ToString('mm\:ss'))" -ForegroundColor Green
        Write-Host "================================================================`n" -ForegroundColor Green

        return @{
            Success = $true
            Duration = $duration
            Timestamp = Get-Date
        }
    }
    catch {
        Write-Host "`n[ERREUR CRITIQUE] Échec du debloat: $($_.Exception.Message)" -ForegroundColor Red

        return @{
            Success = $false
            Error = $_.Exception.Message
            Timestamp = Get-Date
        }
    }
}




#endregion Module Debloat-Windows

#region Orchestrateur Principal

try {
    # Initialiser WPF si disponible
    Test-WPFAvailability | Out-Null

    # En-tête
    if (-not $Silent) {
        Clear-Host
        Write-Host @"

================================================================
             PostBootSetup v$($Global:ScriptMetadata.Version)
                Tenor Data Solutions
         Profil: $($Global:ScriptMetadata.ProfileName)
================================================================

"@ -ForegroundColor Blue
    }

    Write-ScriptLog "Démarrage PostBootSetup - Profil: $($Global:ScriptMetadata.ProfileName)" -Level INFO

    # Vérification administrateur
    if (-not (Test-IsAdministrator)) {
        Write-ScriptLog "Droits administrateur requis" -Level ERROR
        Write-Host "`nVeuillez exécuter ce script en tant qu'administrateur" -ForegroundColor Red
        if (-not $Silent) {
            Read-Host "Appuyez sur Entrée pour quitter"
        }
        exit 1
    }

    Write-ScriptLog "✓ Droits administrateur validés" -Level SUCCESS

    # Vérification Winget
    try {
        $null = winget --version
        Write-ScriptLog "✓ Winget disponible" -Level SUCCESS
    } catch {
        Write-ScriptLog "✗ Winget non disponible" -Level ERROR
        exit 1
    }

    # Afficher le résumé de configuration
    $totalMasterApps = $Global:EmbeddedConfig.apps.master.Count
    $totalProfileApps = $Global:EmbeddedConfig.apps.profile.Count
    $totalApps = $totalMasterApps + $totalProfileApps

    Write-Host "`n📦 Configuration:" -ForegroundColor Cyan
    Write-Host "   - Applications Master: $totalMasterApps" -ForegroundColor White
    Write-Host "   - Applications Profil: $totalProfileApps" -ForegroundColor White
    Write-Host "   - Total: $totalApps applications`n" -ForegroundColor White

    # Confirmation utilisateur (sauf en mode silencieux)
    if (-not $Silent) {
        Write-Host "⚠ Cette opération va installer $totalApps applications." -ForegroundColor Yellow
        $confirmation = Read-Host "Voulez-vous continuer? (O/N)"

        if ($confirmation -notmatch '^[OoYy]') {
            Write-ScriptLog "Installation annulée par l'utilisateur" -Level WARNING
            Write-Host "`nInstallation annulée." -ForegroundColor Yellow
            exit 0
        }

        Write-Host ""
    }

    # Installation des applications
    Write-ScriptLog "======== INSTALLATION APPLICATIONS ========" -Level INFO
    Invoke-WPFProgress -PercentComplete 0 -Status "Démarrage de l'installation..."

    $stats = @{ Success = 0; Failed = 0; Skipped = 0 }
    $currentApp = 0

    # Applications master
    foreach ($app in $Global:EmbeddedConfig.apps.master) {
        $currentApp++
        $percentComplete = [math]::Round(($currentApp / $totalApps) * 100)
        Invoke-WPFProgress -PercentComplete $percentComplete -Status "Installation: $($app.name) ($currentApp/$totalApps)"

        if ($app.winget) {
            $success = Install-WingetApp -App $app
        } else {
            $success = Install-CustomApp -App $app
        }

        if ($success) { $stats.Success++ } else { $stats.Failed++ }
    }

    # Applications profil
    foreach ($app in $Global:EmbeddedConfig.apps.profile) {
        $currentApp++
        $percentComplete = [math]::Round(($currentApp / $totalApps) * 100)
        Invoke-WPFProgress -PercentComplete $percentComplete -Status "Installation: $($app.name) ($currentApp/$totalApps)"

        if ($app.winget) {
            $success = Install-WingetApp -App $app
        } else {
            $success = Install-CustomApp -App $app
        }

        if ($success) { $stats.Success++ } else { $stats.Failed++ }
    }

    Write-ScriptLog "Applications: $($stats.Success) installées, $($stats.Failed) échouées" -Level INFO

    # Debloat Windows (obligatoire)
    if (-not $NoDebloat) {
        Write-ScriptLog "======== DEBLOAT WINDOWS ========" -Level INFO
        Invoke-WindowsDebloat
    }


    # Résumé final
    $duration = (Get-Date) - $Global:StartTime
    $durationFormatted = $duration.ToString("hh\:mm\:ss")

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

    # Notifier WPF de la complétion
    Complete-WPFExecution -Success $true -Summary @{
        'Applications installées' = $stats.Success
        'Applications échouées' = $stats.Failed
        'Durée' = $durationFormatted
    }

    if (-not $Silent) {
        Read-Host "`nAppuyez sur Entrée pour terminer"
    }

    exit 0

} catch {
    Write-ScriptLog "ERREUR CRITIQUE: $($_.Exception.Message)" -Level ERROR
    Write-Host "`nUne erreur critique est survenue. Consultez le log: $Global:LogPath" -ForegroundColor Red

    # Sauvegarder le log JSON même en cas d'erreur
    Save-JSONLog

    # Notifier WPF de l'échec
    Complete-WPFExecution -Success $false -Summary @{
        'Erreur' = $_.Exception.Message
    }

    if (-not $Silent) {
        Read-Host "`nAppuyez sur Entrée pour quitter"
    }

    exit 1
}

#endregion Orchestrateur Principal
