# ============================================
# Module: Install-WebApps
# Description: Installation et gestion des Progressive Web Apps Edge
# ============================================

function Install-EdgeWebApp {
    <#
    .SYNOPSIS
    Installe une Progressive Web App via Microsoft Edge

    .DESCRIPTION
    Crée une PWA Edge, génère un raccourci et l'épingle à la barre des tâches pour tous les utilisateurs

    .PARAMETER Url
    URL de l'application web

    .PARAMETER Name
    Nom de l'application

    .PARAMETER IconPath
    Chemin optionnel vers l'icône personnalisée
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$IconPath
    )

    try {
        Write-Host "Installation de la Web App: $Name" -ForegroundColor Cyan

        # Vérifier que Edge est installé
        $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
        if (!(Test-Path $edgePath)) {
            $edgePath = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
        }

        if (!(Test-Path $edgePath)) {
            Write-Warning "Microsoft Edge n'est pas installé"
            return
        }

        # Créer le dossier pour les raccourcis Web Apps
        $webAppsPath = "$env:LOCALAPPDATA\Microsoft\Edge\WebApps"
        if (!(Test-Path $webAppsPath)) {
            New-Item -Path $webAppsPath -ItemType Directory -Force | Out-Null
        }

        # Générer l'App ID (hash de l'URL)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Url)
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        $hash = $hasher.ComputeHash($bytes)
        $appId = [System.BitConverter]::ToString($hash).Replace('-', '').Substring(0, 32).ToLower()

        # Créer le raccourci dans le menu Démarrer
        $startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        $shortcutPath = Join-Path $startMenuPath "$Name.lnk"

        # Arguments Edge pour PWA
        $arguments = "--profile-directory=Default --app-id=$appId --app=`"$Url`""

        # Créer le raccourci avec COM
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $edgePath
        $shortcut.Arguments = $arguments
        $shortcut.WorkingDirectory = Split-Path $edgePath
        $shortcut.Description = $Name

        if ($IconPath -and (Test-Path $IconPath)) {
            $shortcut.IconLocation = $IconPath
        }

        $shortcut.Save()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null

        Write-Host "  → Raccourci créé: $shortcutPath" -ForegroundColor Green

        # Épingler à la barre des tâches pour l'utilisateur actuel
        Pin-ToTaskbar -ShortcutPath $shortcutPath

        # Copier le raccourci dans le profil par défaut pour les futurs utilisateurs
        $defaultStartMenu = "C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
        if (!(Test-Path $defaultStartMenu)) {
            New-Item -Path $defaultStartMenu -ItemType Directory -Force | Out-Null
        }

        Copy-Item $shortcutPath "$defaultStartMenu\$Name.lnk" -Force -ErrorAction SilentlyContinue

        # Configurer l'épinglage par défaut dans le registre du profil par défaut
        Set-TaskbarPinForAllUsers -ShortcutName "$Name.lnk"

        Write-Host "  ✓ Web App '$Name' installée avec succès" -ForegroundColor Green

    } catch {
        Write-Warning "Erreur lors de l'installation de $Name : $_"
    }
}

function Pin-ToTaskbar {
    <#
    .SYNOPSIS
    Épingle un raccourci à la barre des tâches

    .PARAMETER ShortcutPath
    Chemin vers le fichier .lnk
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$ShortcutPath
    )

    try {
        if (!(Test-Path $ShortcutPath)) {
            Write-Warning "Le raccourci n'existe pas: $ShortcutPath"
            return
        }

        # Méthode 1: Via le registre TaskbarLinks (Windows 11)
        $taskbarPath = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
        if (!(Test-Path $taskbarPath)) {
            New-Item -Path $taskbarPath -ItemType Directory -Force | Out-Null
        }

        Copy-Item $ShortcutPath $taskbarPath -Force -ErrorAction SilentlyContinue

        Write-Host "  → Épinglé à la barre des tâches" -ForegroundColor Green

    } catch {
        Write-Warning "Impossible d'épingler à la barre des tâches: $_"
    }
}

function Set-TaskbarPinForAllUsers {
    <#
    .SYNOPSIS
    Configure l'épinglage par défaut pour tous les futurs utilisateurs

    .PARAMETER ShortcutName
    Nom du fichier raccourci (.lnk)
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string]$ShortcutName
    )

    try {
        # Charger le registre du profil par défaut
        $defaultUserHive = "C:\Users\Default\NTUSER.DAT"

        if (!(Test-Path $defaultUserHive)) {
            Write-Warning "NTUSER.DAT du profil par défaut introuvable"
            return
        }

        # Monter le registre
        reg load "HKU\DefaultUser" $defaultUserHive 2>&1 | Out-Null
        Start-Sleep -Milliseconds 500

        # Copier le raccourci dans le dossier Taskbar du profil par défaut
        $defaultTaskbarPath = "C:\Users\Default\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar"
        if (!(Test-Path $defaultTaskbarPath)) {
            New-Item -Path $defaultTaskbarPath -ItemType Directory -Force | Out-Null
        }

        $currentTaskbarPath = "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\$ShortcutName"
        if (Test-Path $currentTaskbarPath) {
            Copy-Item $currentTaskbarPath $defaultTaskbarPath -Force -ErrorAction SilentlyContinue
        }

        # Démonter le registre
        Start-Sleep -Milliseconds 500
        reg unload "HKU\DefaultUser" 2>&1 | Out-Null

        Write-Host "  → Configuration pour futurs utilisateurs OK" -ForegroundColor Green

    } catch {
        Write-Warning "Erreur configuration futurs utilisateurs: $_"
        # S'assurer que le registre est démonté
        reg unload "HKU\DefaultUser" 2>&1 | Out-Null
    }
}

function Install-TenorWebApps {
    <#
    .SYNOPSIS
    Installe toutes les Web Apps Tenor
    #>

    Write-Host "`n=== Installation des Web Apps Tenor ===" -ForegroundColor Cyan

    # Web App 1: Tenor Password Manager
    Install-EdgeWebApp -Url "https://password.tenorsolutions.com/#!/" -Name "Tenor Password"

    # Web App 2: Tenor Documentation
    Install-EdgeWebApp -Url "https://docs.tenorsolutions.com/" -Name "Tenor Docs"

    Write-Host "`n✓ Installation des Web Apps terminée`n" -ForegroundColor Green
}

# Exporter les fonctions
Export-ModuleMember -Function Install-EdgeWebApp, Install-TenorWebApps
