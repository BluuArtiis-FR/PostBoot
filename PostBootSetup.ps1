# PostBootSetup v4.0 - Tenor Data Solutions
# Installation et configuration automatisée des postes de travail

param(
    [string]$UserProfile = "",
    [switch]$Silent,
    [switch]$WebUI,
    [switch]$SkipAdmin,
    [switch]$Help
)

# Configuration globale
$Global:ScriptRoot = $PSScriptRoot
$Global:Version = "4.0"
$Global:StartTime = Get-Date

# Couleurs Tenor
$TenorBlue = @{ForegroundColor="Blue"}
$TenorGreen = @{ForegroundColor="Green"}
$TenorRed = @{ForegroundColor="Red"}
$TenorYellow = @{ForegroundColor="Yellow"}

# Affichage de l'en-tête
function Show-Header {
    try {
        Clear-Host
    }
    catch {
        # Ignore clear errors
    }
    Write-Host @"

================================================================
                 PostBootSetup v$Global:Version
              Tenor Data Solutions - Service IT
================================================================

"@ @TenorBlue
}

# Affichage de l'aide
function Show-Help {
    Write-Host @"
UTILISATION:
  .\PostBootSetup.ps1 [OPTIONS]

PROFILS DISPONIBLES:
  DEV        Développeur (VS Code, Git, SQL, etc.)
  SUPPORT    Support client (eCarAdmin, TeamViewer, etc.)
  SI         Admin système (Wireshark, Docker, etc.)

OPTIONS:
  -UserProfile   Sélectionner un profil automatiquement
  -Silent        Installation silencieuse
  -WebUI         Interface web (nécessite Python)
  -SkipAdmin     Ignorer la vérification admin
  -Help          Afficher cette aide

EXEMPLES:
  .\PostBootSetup.ps1                        # Interface interactive
  .\PostBootSetup.ps1 -UserProfile DEV       # Installation directe profil DEV
  .\PostBootSetup.ps1 -Silent                # Installation silencieuse
  .\PostBootSetup.ps1 -WebUI                 # Interface web moderne

"@ @TenorYellow
}

# Vérification des prérequis
function Test-Prerequisites {
    Write-Host "Vérification des prérequis..." @TenorYellow

    # Admin check
    if (-not $SkipAdmin) {
        $currentPrincipal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

        if (-not $isAdmin) {
            Write-Host "Droits administrateur requis" @TenorRed
            Write-Host "Relancement en tant qu'administrateur..." @TenorYellow

            # Construire les paramètres pour le relancement
            $params = @()
            if ($UserProfile) {
                $params += "-UserProfile '$UserProfile'"
            }
            if ($Silent) {
                $params += "-Silent"
            }
            if ($WebUI) {
                $params += "-WebUI"
            }
            if ($Help) {
                $params += "-Help"
            }

            $arguments = "-File `"$PSCommandPath`" " + ($params -join " ")

            try {
                # Relancer en tant qu'administrateur
                Start-Process powershell -Verb RunAs -ArgumentList $arguments -Wait
                Write-Host "Script relancé avec les droits administrateur" @TenorGreen
                exit 0
            }
            catch {
                Write-Host "Impossible de relancer en tant qu'administrateur: $_" @TenorRed
                Write-Host "Veuillez exécuter ce script en tant qu'administrateur manuellement" @TenorYellow
                Read-Host "Appuyez sur Entrée pour quitter"
                return $false
            }
        }
    }

    # Winget check
    try {
        $null = winget --version
        Write-Host "Winget disponible" @TenorGreen
    }
    catch {
        Write-Host "Winget non disponible" @TenorRed
        return $false
    }

    # Configuration check
    if (-not (Test-Path "$Global:ScriptRoot\config\apps.json")) {
        Write-Host "Configuration manquante" @TenorRed
        return $false
    }

    Write-Host "Prérequis validés" @TenorGreen
    return $true
}

# Chargement de la configuration
function Get-Configuration {
    try {
        $appsConfig = Get-Content "$Global:ScriptRoot\config\apps.json" | ConvertFrom-Json
        $settingsConfig = Get-Content "$Global:ScriptRoot\config\settings.json" | ConvertFrom-Json

        return @{
            Apps = $appsConfig
            Settings = $settingsConfig
        }
    }
    catch {
        Write-Host "Erreur chargement configuration: $_" @TenorRed
        return $null
    }
}

# Interface de sélection de profil
function Select-UserProfile {
    param($Config)

    Write-Host "`nProfils disponibles:" @TenorBlue
    $profiles = @($Config.Apps.profiles.PSObject.Properties)

    if ($profiles.Count -eq 0) {
        Write-Host "Aucun profil disponible" @TenorRed
        return $null
    }

    for ($i = 0; $i -lt $profiles.Count; $i++) {
        $profileItem = $profiles[$i]
        Write-Host "  $($i + 1). $($profileItem.Value.name) - $($profileItem.Value.description)"
    }

    do {
        $choice = Read-Host "`nChoisissez un profil (1-$($profiles.Count))"
        try {
            $profileIndex = [int]$choice - 1
        } catch {
            $profileIndex = -1
        }
    } while ($profileIndex -lt 0 -or $profileIndex -ge $profiles.Count)

    return $profiles[$profileIndex].Name
}

# Installation d'une application Winget
function Install-WingetApp {
    param($App)

    Write-Host "Installation: $($App.name)..." @TenorYellow

    try {
        $null = winget install --id $App.winget --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$($App.name) installé" @TenorGreen
            return $true
        }
        else {
            Write-Host "Échec: $($App.name)" @TenorRed
            return $false
        }
    }
    catch {
        Write-Host "Erreur: $($App.name) - $_" @TenorRed
        return $false
    }
}

# Installation d'une application custom
function Install-CustomApp {
    param($App)

    Write-Host "Téléchargement: $($App.name)..." @TenorYellow

    try {
        # Déterminer l'extension du fichier
        $uri = [System.Uri]$App.url
        $fileName = Split-Path $uri.LocalPath -Leaf
        if (-not $fileName -or $fileName -notmatch '\.[a-zA-Z0-9]+$') {
            $fileName = "$($App.name -replace '[^a-zA-Z0-9]', '_').exe"
        }

        $tempPath = "$env:TEMP\$fileName"
        Invoke-WebRequest -Uri $App.url -OutFile $tempPath -UseBasicParsing

        Write-Host "Installation: $($App.name)..." @TenorYellow

        # Arguments d'installation selon le type de fichier
        $installArgs = if ($App.installArgs) {
            $App.installArgs
        } elseif ($tempPath -match '\.msi$') {
            "/quiet /norestart"
        } else {
            "/S"
        }

        Start-Process -FilePath $tempPath -ArgumentList $installArgs -Wait -NoNewWindow

        Remove-Item $tempPath -ErrorAction SilentlyContinue
        Write-Host "$($App.name) installé" @TenorGreen
        return $true
    }
    catch {
        Write-Host "Erreur: $($App.name) - $_" @TenorRed
        return $false
    }
}

# Installation des applications
function Install-Apps {
    param($Config, $SelectedProfile)

    $stats = @{Success = 0; Failed = 0}

    Write-Host "`nInstallation des applications..." @TenorBlue

    # Applications Master (obligatoires)
    Write-Host "`nApplications obligatoires:" @TenorYellow
    foreach ($app in $Config.Apps.master) {
        if ($app.winget) {
            $success = Install-WingetApp -App $app
        }
        else {
            $success = Install-CustomApp -App $app
        }

        if ($success) {
            $stats.Success++
        }
        else {
            $stats.Failed++
        }
    }

    # Applications du profil
    if ($SelectedProfile -and $Config.Apps.profiles.$SelectedProfile) {
        Write-Host "`nApplications du profil $SelectedProfile :" @TenorYellow
        foreach ($app in $Config.Apps.profiles.$SelectedProfile.apps) {
            if ($app.winget) {
                $success = Install-WingetApp -App $app
            }
            else {
                $success = Install-CustomApp -App $app
            }

            if ($success) {
                $stats.Success++
            }
            else {
                $stats.Failed++
            }
        }
    }

    return $stats
}

# Application des optimisations
function Set-Optimizations {
    param($Config)

    Write-Host "`nApplication des optimisations..." @TenorBlue

    foreach ($category in $Config.Settings.optimizations.PSObject.Properties) {
        Write-Host "`n$($category.Name):" @TenorYellow

        foreach ($opt in $category.Value) {
            if (-not $opt.enabled) {
                continue
            }

            Write-Host "  $($opt.name)..."

            try {
                if ($opt.command) {
                    Invoke-Expression $opt.command
                }
                elseif ($opt.registry) {
                    Set-ItemProperty -Path "Registry::$($opt.registry)" -Name $opt.value -Value $opt.data -Force
                }
                Write-Host "  $($opt.name) appliqué" @TenorGreen
            }
            catch {
                Write-Host "  Erreur: $($opt.name)" @TenorRed
            }
        }
    }
}

# Configuration entreprise
function Set-EnterpriseConfig {
    param($Config)

    Write-Host "`nConfiguration entreprise..." @TenorBlue

    # Variables d'environnement
    if ($Config.Settings.enterprise.environment) {
        foreach ($env in $Config.Settings.enterprise.environment.PSObject.Properties) {
            [Environment]::SetEnvironmentVariable($env.Name, $env.Value, "Machine")
            Write-Host "Variable: $($env.Name)" @TenorGreen
        }
    }
}

# Interface web
function Start-WebInterface {
    Write-Host "Lancement de l'interface web..." @TenorYellow

    # Serveur HTTP simple PowerShell - ouverture directe du HTML
    $htmlPath = "$Global:ScriptRoot\web\index.html"
    if (Test-Path $htmlPath) {
        Write-Host "Ouverture du fichier HTML directement..." @TenorYellow
        Start-Process $htmlPath
    } else {
        Write-Host "Fichier index.html introuvable: $htmlPath" @TenorRed
        Write-Host "Basculement vers l'interface console..." @TenorYellow
        Start-Sleep 2
    }
}

# Résumé final
function Show-Summary {
    param($Stats, $Duration)

    Write-Host @"

================================================================
                         RESUME
================================================================
  Installations reussies: $($Stats.Success.ToString().PadLeft(2))
  Installations echouees: $($Stats.Failed.ToString().PadLeft(2))
  Duree totale: $($Duration.ToString("mm\:ss"))

  Support: it@tenorsolutions.com
================================================================

"@ @TenorBlue
}

# PROGRAMME PRINCIPAL
try {
    Show-Header

    if ($Help) {
        Show-Help
        exit 0
    }

    if ($WebUI) {
        Start-WebInterface
        exit 0
    }

    if (-not (Test-Prerequisites)) {
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }

    $config = Get-Configuration
    if (-not $config) {
        Read-Host "Appuyez sur Entrée pour quitter"
        exit 1
    }

    if (-not $UserProfile -and -not $Silent) {
        $UserProfile = Select-UserProfile -Config $config
    }

    $stats = Install-Apps -Config $config -SelectedProfile $UserProfile
    Set-Optimizations -Config $config
    Set-EnterpriseConfig -Config $config

    $duration = (Get-Date) - $Global:StartTime
    Show-Summary -Stats $stats -Duration $duration

    if (-not $Silent) {
        Read-Host "`nAppuyez sur Entrée pour terminer"
    }

}
catch {
    Write-Host "`nERREUR CRITIQUE: $_" @TenorRed
    Read-Host "Appuyez sur Entrée pour quitter"
    exit 1
}