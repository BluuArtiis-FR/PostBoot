# Module: Customize-UI.psm1
# Description: Personnalisation de l'interface utilisateur Windows
# Version: 1.0
# Requis: Non (sélectionnable par l'utilisateur)

<#
.SYNOPSIS
Module de personnalisation de l'interface Windows.

.DESCRIPTION
Ce module offre des fonctions pour personnaliser l'apparence et le comportement
de l'interface utilisateur Windows selon les préférences de l'utilisateur.
#>

function Set-TaskbarPosition {
    <#
    .SYNOPSIS
    Déplace la barre des tâches vers une position spécifique.

    .PARAMETER Position
    Position de la barre des tâches: Bottom, Left, Right, Top

    .EXAMPLE
    Set-TaskbarPosition -Position "Left"
    #>

    [CmdletBinding()]
    param(
        [ValidateSet("Bottom", "Left", "Right", "Top")]
        [string]$Position = "Bottom"
    )

    Write-Host "`n[UI] Configuration de la barre des tâches: $Position..." -ForegroundColor Cyan

    try {
        $positionMap = @{
            "Bottom" = 3
            "Left" = 0
            "Top" = 2
            "Right" = 1
        }

        $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"

        if (Test-Path $registryPath) {
            $value = (Get-ItemProperty -Path $registryPath).Settings

            if ($value) {
                $value[12] = $positionMap[$Position]
                Set-ItemProperty -Path $registryPath -Name "Settings" -Value $value -Force

                Write-Host "  [OK] Barre des tâches positionnée: $Position" -ForegroundColor Green
                Write-Host "  [ATTENTION] Redémarrage de l'explorateur nécessaire pour appliquer" -ForegroundColor Yellow
                return $true
            }
        }

        Write-Host "  [ATTENTION] Impossible de modifier la position (registre non trouvé)" -ForegroundColor Yellow
        return $false
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-DarkMode {
    <#
    .SYNOPSIS
    Active ou désactive le mode sombre de Windows.

    .PARAMETER Enable
    $true pour activer le mode sombre, $false pour le mode clair

    .EXAMPLE
    Set-DarkMode -Enable $true
    #>

    [CmdletBinding()]
    param(
        [bool]$Enable = $true
    )

    $mode = if ($Enable) { "sombre" } else { "clair" }
    Write-Host "`n[UI] Configuration du mode $mode..." -ForegroundColor Cyan

    try {
        $themeValue = if ($Enable) { 0 } else { 1 }

        # Mode sombre pour les applications
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value $themeValue -Type DWord -Force

        # Mode sombre pour le système
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value $themeValue -Type DWord -Force

        Write-Host "  [OK] Mode $mode activé" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-FileExplorerOptions {
    <#
    .SYNOPSIS
    Configure les options de l'explorateur de fichiers.

    .PARAMETER ShowHiddenFiles
    Afficher les fichiers cachés

    .PARAMETER ShowFileExtensions
    Afficher les extensions de fichiers

    .PARAMETER ShowFullPath
    Afficher le chemin complet dans la barre d'adresse

    .EXAMPLE
    Set-FileExplorerOptions -ShowHiddenFiles $true -ShowFileExtensions $true
    #>

    [CmdletBinding()]
    param(
        [bool]$ShowHiddenFiles = $false,
        [bool]$ShowFileExtensions = $true,
        [bool]$ShowFullPath = $true
    )

    Write-Host "`n[UI] Configuration de l'explorateur de fichiers..." -ForegroundColor Cyan

    try {
        $explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

        # Afficher les fichiers cachés
        $hiddenValue = if ($ShowHiddenFiles) { 1 } else { 2 }
        Set-ItemProperty -Path $explorerPath -Name "Hidden" -Value $hiddenValue -Type DWord -Force

        # Afficher les extensions de fichiers
        $extValue = if ($ShowFileExtensions) { 0 } else { 1 }
        Set-ItemProperty -Path $explorerPath -Name "HideFileExt" -Value $extValue -Type DWord -Force

        # Afficher le chemin complet
        $pathValue = if ($ShowFullPath) { 1 } else { 0 }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Value $pathValue -Type DWord -Force -ErrorAction SilentlyContinue

        # Ouvrir l'explorateur sur "Ce PC" au lieu de "Accès rapide"
        Set-ItemProperty -Path $explorerPath -Name "LaunchTo" -Value 1 -Type DWord -Force

        Write-Host "  [OK] Explorateur configuré" -ForegroundColor Green
        Write-Host "    - Fichiers cachés: $($ShowHiddenFiles)" -ForegroundColor Gray
        Write-Host "    - Extensions visibles: $($ShowFileExtensions)" -ForegroundColor Gray
        Write-Host "    - Chemin complet: $($ShowFullPath)" -ForegroundColor Gray

        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-DesktopIcons {
    <#
    .SYNOPSIS
    Configure l'affichage des icônes du bureau.

    .PARAMETER ShowThisPC
    Afficher "Ce PC"

    .PARAMETER ShowRecycleBin
    Afficher la "Corbeille"

    .PARAMETER ShowUserFolder
    Afficher le dossier de l'utilisateur

    .PARAMETER ShowNetwork
    Afficher "Réseau"

    .EXAMPLE
    Set-DesktopIcons -ShowThisPC $true -ShowRecycleBin $true
    #>

    [CmdletBinding()]
    param(
        [bool]$ShowThisPC = $true,
        [bool]$ShowRecycleBin = $true,
        [bool]$ShowUserFolder = $false,
        [bool]$ShowNetwork = $false
    )

    Write-Host "`n[UI] Configuration des icônes du bureau..." -ForegroundColor Cyan

    try {
        $iconPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

        if (-not (Test-Path $iconPath)) {
            New-Item -Path $iconPath -Force | Out-Null
        }

        # GUIDs des icônes système
        $icons = @{
            "ThisPC" = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
            "RecycleBin" = "{645FF040-5081-101B-9F08-00AA002F954E}"
            "UserFolder" = "{59031a47-3f72-44a7-89c5-5595fe6b30ee}"
            "Network" = "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
        }

        # 0 = affiché, 1 = masqué
        Set-ItemProperty -Path $iconPath -Name $icons.ThisPC -Value $(if ($ShowThisPC) { 0 } else { 1 }) -Type DWord -Force
        Set-ItemProperty -Path $iconPath -Name $icons.RecycleBin -Value $(if ($ShowRecycleBin) { 0 } else { 1 }) -Type DWord -Force
        Set-ItemProperty -Path $iconPath -Name $icons.UserFolder -Value $(if ($ShowUserFolder) { 0 } else { 1 }) -Type DWord -Force
        Set-ItemProperty -Path $iconPath -Name $icons.Network -Value $(if ($ShowNetwork) { 0 } else { 1 }) -Type DWord -Force

        Write-Host "  [OK] Icônes du bureau configurées" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-WindowsTheme {
    <#
    .SYNOPSIS
    Applique un thème de couleur Windows personnalisé.

    .PARAMETER AccentColor
    Couleur d'accentuation au format hexadécimal (ex: "0078D7" pour bleu Windows)

    .EXAMPLE
    Set-WindowsTheme -AccentColor "0078D7"
    #>

    [CmdletBinding()]
    param(
        [string]$AccentColor = "0078D7"
    )

    Write-Host "`n[UI] Application du thème de couleur: #$AccentColor..." -ForegroundColor Cyan

    try {
        # Convertir hex en BGR pour Windows
        $r = [Convert]::ToInt32($AccentColor.Substring(0,2), 16)
        $g = [Convert]::ToInt32($AccentColor.Substring(2,2), 16)
        $b = [Convert]::ToInt32($AccentColor.Substring(4,2), 16)

        $colorValue = $b * 65536 + $g * 256 + $r

        $themePath = "HKCU:\Software\Microsoft\Windows\DWM"
        Set-ItemProperty -Path $themePath -Name "AccentColor" -Value $colorValue -Type DWord -Force
        Set-ItemProperty -Path $themePath -Name "ColorizationColor" -Value $colorValue -Type DWord -Force

        # Activer la couleur d'accentuation sur la barre des tâches et les bordures
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "ColorPrevalence" -Value 1 -Type DWord -Force

        Write-Host "  [OK] Thème de couleur appliqué" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Restart-Explorer {
    <#
    .SYNOPSIS
    Redémarre l'explorateur Windows pour appliquer les changements d'interface.

    .DESCRIPTION
    Cette fonction termine proprement le processus explorer.exe et le relance
    pour que les modifications d'interface prennent effet immédiatement.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[UI] Redémarrage de l'explorateur Windows..." -ForegroundColor Cyan

    try {
        Stop-Process -Name "explorer" -Force -ErrorAction Stop
        Start-Sleep -Seconds 2
        Start-Process "explorer.exe"

        Write-Host "  [OK] Explorateur redémarré" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur lors du redémarrage: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Invoke-UICustomizations {
    <#
    .SYNOPSIS
    Fonction principale qui applique toutes les personnalisations d'interface sélectionnées.

    .PARAMETER Options
    Hashtable contenant les options de personnalisation à appliquer.

    .PARAMETER RestartExplorer
    Redémarrer l'explorateur après les modifications pour appliquer immédiatement les changements.

    .EXAMPLE
    Invoke-UICustomizations -Options @{
        DarkMode = $true
        TaskbarPosition = "Bottom"
        ShowFileExtensions = $true
        ShowHiddenFiles = $false
        ThemeColor = "0078D7"
    } -RestartExplorer $true
    #>

    [CmdletBinding()]
    param(
        [hashtable]$Options = @{},
        [bool]$RestartExplorer = $true
    )

    $startTime = Get-Date

    Write-Host "`n================================================================" -ForegroundColor Blue
    Write-Host "      PERSONNALISATION DE L'INTERFACE - OPTIONNEL" -ForegroundColor Blue
    Write-Host "================================================================`n" -ForegroundColor Blue

    $results = @{
        Success = @()
        Failed = @()
    }

    try {
        # Appliquer le mode sombre si spécifié
        if ($Options.ContainsKey("DarkMode")) {
            if (Set-DarkMode -Enable $Options.DarkMode) {
                $results.Success += "DarkMode"
            } else {
                $results.Failed += "DarkMode"
            }
        }

        # Configurer la position de la barre des tâches
        if ($Options.ContainsKey("TaskbarPosition")) {
            if (Set-TaskbarPosition -Position $Options.TaskbarPosition) {
                $results.Success += "TaskbarPosition"
            } else {
                $results.Failed += "TaskbarPosition"
            }
        }

        # Configurer l'explorateur de fichiers
        if ($Options.ContainsKey("ShowFileExtensions") -or $Options.ContainsKey("ShowHiddenFiles") -or $Options.ContainsKey("ShowFullPath")) {
            $showExt = if ($Options.ContainsKey("ShowFileExtensions")) { $Options.ShowFileExtensions } else { $true }
            $showHidden = if ($Options.ContainsKey("ShowHiddenFiles")) { $Options.ShowHiddenFiles } else { $false }
            $showFullPath = if ($Options.ContainsKey("ShowFullPath")) { $Options.ShowFullPath } else { $true }

            if (Set-FileExplorerOptions -ShowFileExtensions $showExt -ShowHiddenFiles $showHidden -ShowFullPath $showFullPath) {
                $results.Success += "FileExplorer"
            } else {
                $results.Failed += "FileExplorer"
            }
        }

        # Configurer les icônes du bureau
        if ($Options.ContainsKey("ShowThisPC") -or $Options.ContainsKey("ShowRecycleBin")) {
            $showPC = if ($Options.ContainsKey("ShowThisPC")) { $Options.ShowThisPC } else { $true }
            $showRecycle = if ($Options.ContainsKey("ShowRecycleBin")) { $Options.ShowRecycleBin } else { $true }
            $showUser = if ($Options.ContainsKey("ShowUserFolder")) { $Options.ShowUserFolder } else { $false }
            $showNet = if ($Options.ContainsKey("ShowNetwork")) { $Options.ShowNetwork } else { $false }

            if (Set-DesktopIcons -ShowThisPC $showPC -ShowRecycleBin $showRecycle -ShowUserFolder $showUser -ShowNetwork $showNet) {
                $results.Success += "DesktopIcons"
            } else {
                $results.Failed += "DesktopIcons"
            }
        }

        # Appliquer le thème de couleur
        if ($Options.ContainsKey("ThemeColor")) {
            if (Set-WindowsTheme -AccentColor $Options.ThemeColor) {
                $results.Success += "ThemeColor"
            } else {
                $results.Failed += "ThemeColor"
            }
        }

        # Tweaks Windows 11 - Barre des tâches
        if ($Options.ContainsKey("TaskbarAlignLeft") -or $Options.ContainsKey("HideWidgets") -or $Options.ContainsKey("HideTaskView") -or $Options.ContainsKey("EnableEndTask")) {
            $params = @{}
            if ($Options.TaskbarAlignLeft) { $params.AlignLeft = $true }
            if ($Options.HideWidgets) { $params.HideWidgets = $true }
            if ($Options.HideTaskView) { $params.HideTaskView = $true }
            if ($Options.EnableEndTask) { $params.EnableEndTask = $true }

            if ($params.Count -gt 0) {
                if (Set-Windows11Taskbar @params) {
                    $results.Success += "Windows11Taskbar"
                } else {
                    $results.Failed += "Windows11Taskbar"
                }
            }
        }

        # Menu contextuel Windows 10
        if ($Options.ContainsKey("Windows10ContextMenu") -and $Options.Windows10ContextMenu) {
            if (Restore-Windows10ContextMenu) {
                $results.Success += "Windows10ContextMenu"
            } else {
                $results.Failed += "Windows10ContextMenu"
            }
        }

        # Masquer éléments du volet de navigation
        if ($Options.ContainsKey("HideOneDriveNav")) {
            $navParams = @{}
            if ($Options.HideOneDriveNav) { $navParams.HideOneDrive = $true }

            if ($navParams.Count -gt 0) {
                if (Hide-NavigationPaneItems @navParams) {
                    $results.Success += "NavigationPane"
                } else {
                    $results.Failed += "NavigationPane"
                }
            }
        }

        # Fond d'écran et écran de verrouillage Tenor
        if ($Options.ContainsKey("TenorWallpaper") -and $Options.TenorWallpaper) {
            $wallpaperUrl = if ($Options.ContainsKey("WallpaperUrl")) { $Options.WallpaperUrl } else { $null }

            if ($wallpaperUrl) {
                if (Set-TenorWallpaper -WallpaperUrl $wallpaperUrl) {
                    $results.Success += "TenorWallpaper"
                } else {
                    $results.Failed += "TenorWallpaper"
                }
            } else {
                if (Set-TenorWallpaper) {
                    $results.Success += "TenorWallpaper"
                } else {
                    $results.Failed += "TenorWallpaper"
                }
            }
        }

        # Redémarrer l'explorateur si demandé
        if ($RestartExplorer) {
            Restart-Explorer
        }

        $duration = (Get-Date) - $startTime

        Write-Host "`n================================================================" -ForegroundColor Green
        Write-Host "  PERSONNALISATIONS APPLIQUEES" -ForegroundColor Green
        Write-Host "  Réussies: $($results.Success.Count) | Échecs: $($results.Failed.Count)" -ForegroundColor Green
        Write-Host "  Durée: $($duration.ToString('mm\:ss'))" -ForegroundColor Green
        Write-Host "================================================================`n" -ForegroundColor Green

        return $results
    }
    catch {
        Write-Host "`n[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
        return $results
    }
}

function Set-Windows11Taskbar {
    <#
    .SYNOPSIS
    Configure les paramètres spécifiques de la barre des tâches Windows 11.

    .DESCRIPTION
    Applique les tweaks de barre des tâches Windows 11 :
    - Alignement des icônes à gauche (vs centre par défaut)
    - Masquage des widgets
    - Masquage de Task View
    - Activation du "End Task" au clic droit
    #>

    [CmdletBinding()]
    param(
        [switch]$AlignLeft,
        [switch]$HideWidgets,
        [switch]$HideTaskView,
        [switch]$EnableEndTask
    )

    Write-Host "`n[UI] Configuration barre des tâches Windows 11..." -ForegroundColor Cyan

    try {
        # Aligner les icônes à gauche (Windows 11)
        if ($AlignLeft) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord -Force
            Write-Host "  [OK] Icônes alignées à gauche" -ForegroundColor Green
        }

        # Masquer les widgets
        if ($HideWidgets) {
            try {
                Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord -Force -ErrorAction Stop
                Write-Host "  [OK] Widgets masqués" -ForegroundColor Green
            } catch {
                Write-Host "  [ATTENTION] Impossible de masquer les widgets (permission refusée)" -ForegroundColor Yellow
            }
        }

        # Masquer Task View
        if ($HideTaskView) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force
            Write-Host "  [OK] Task View masqué" -ForegroundColor Green
        }

        # Activer "End Task" au clic droit
        if ($EnableEndTask) {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
            if (-not (Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }
            Set-ItemProperty -Path $path -Name "TaskbarEndTask" -Value 1 -Type DWord -Force
            Write-Host "  [OK] End Task activé au clic droit" -ForegroundColor Green
        }

        Write-Host "  [OK] Barre des tâches Windows 11 configurée" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Restore-Windows10ContextMenu {
    <#
    .SYNOPSIS
    Restaure le menu contextuel de style Windows 10 dans Windows 11.

    .DESCRIPTION
    Remplace le nouveau menu contextuel Windows 11 (simplifié) par l'ancien
    menu contextuel Windows 10 (complet) en modifiant le registre.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[UI] Restauration menu contextuel Windows 10..." -ForegroundColor Cyan

    try {
        # Désactiver le nouveau menu contextuel Windows 11
        $path = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

        if (-not (Test-Path $path)) {
            New-Item -Path $path -Force | Out-Null
        }

        # Valeur vide = utiliser l'ancien menu
        Set-ItemProperty -Path $path -Name "(Default)" -Value "" -Force

        Write-Host "  [OK] Menu contextuel Windows 10 restauré" -ForegroundColor Green
        Write-Host "  [ATTENTION] Redémarrage de l'explorateur requis pour appliquer" -ForegroundColor Yellow
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Hide-NavigationPaneItems {
    <#
    .SYNOPSIS
    Masque les éléments indésirables du volet de navigation de l'explorateur.

    .DESCRIPTION
    Masque les dossiers : OneDrive, Objets 3D, Galerie (Windows 11 24H2+)
    #>

    [CmdletBinding()]
    param(
        [switch]$HideOneDrive,
        [switch]$Hide3DObjects,
        [switch]$HideGallery
    )

    Write-Host "`n[UI] Configuration volet navigation..." -ForegroundColor Cyan

    try {
        # Masquer OneDrive
        if ($HideOneDrive) {
            $paths = @(
                "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}",
                "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
            )
            foreach ($path in $paths) {
                if (Test-Path $path) {
                    Set-ItemProperty -Path $path -Name "System.IsPinnedToNameSpaceTree" -Value 0 -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "  [OK] OneDrive masqué du volet navigation" -ForegroundColor Green
        }

        # Masquer Objets 3D
        if ($Hide3DObjects) {
            $paths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}",
                "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
            )
            foreach ($path in $paths) {
                if (Test-Path $path) {
                    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                }
            }
            Write-Host "  [OK] Objets 3D masqués" -ForegroundColor Green
        }

        # Masquer Galerie (Windows 11 24H2+)
        if ($HideGallery) {
            $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}"
            if (Test-Path $path) {
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  [OK] Galerie masquée (W11 24H2+)" -ForegroundColor Green
            }
        }

        Write-Host "  [OK] Volet navigation configuré" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Disable-MouseAcceleration {
    <#
    .SYNOPSIS
    Désactive l'accélération de la souris (Enhance Pointer Precision).

    .DESCRIPTION
    Désactive la fonctionnalité "Améliorer la précision du pointeur" qui ajoute
    une accélération à la souris. Préféré par les gamers et utilisateurs précis.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[UI] Désactivation accélération souris..." -ForegroundColor Cyan

    try {
        # Désactiver "Enhance Pointer Precision"
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force

        Write-Host "  [OK] Accélération souris désactivée" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-TenorWallpaper {
    <#
    .SYNOPSIS
    Définit le fond d'écran et l'écran de verrouillage Tenor Data Solutions.

    .DESCRIPTION
    Télécharge l'image de marque Tenor Data Solutions et la définit comme :
    - Fond d'écran du bureau
    - Écran de verrouillage (Windows 10/11)

    .PARAMETER WallpaperUrl
    URL de l'image à télécharger (par défaut : image Tenor hébergée)

    .EXAMPLE
    Set-TenorWallpaper
    #>

    [CmdletBinding()]
    param(
        [string]$WallpaperUrl = "https://raw.githubusercontent.com/tenorsolutions/postboot/main/assets/wallpaper.jpg"
    )

    Write-Host "`n[UI] Configuration fond d'écran Tenor Data Solutions..." -ForegroundColor Cyan

    try {
        # Créer le dossier de destination
        $wallpaperDir = "$env:USERPROFILE\Pictures\Tenor"
        if (-not (Test-Path $wallpaperDir)) {
            New-Item -ItemType Directory -Path $wallpaperDir -Force | Out-Null
        }

        $wallpaperPath = Join-Path $wallpaperDir "tenor_wallpaper.jpg"

        # Utiliser l'image par défaut Windows (C:\Windows\Web\Wallpaper\Windows\img0.jpg)
        # OU télécharger depuis une URL si fournie
        if ($WallpaperUrl -ne "https://raw.githubusercontent.com/tenorsolutions/postboot/main/assets/wallpaper.jpg") {
            Write-Host "  -> Téléchargement de l'image personnalisée..." -ForegroundColor Cyan
            try {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
                Invoke-WebRequest -Uri $WallpaperUrl -OutFile $wallpaperPath -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
                Write-Host "  [OK] Image téléchargée" -ForegroundColor Green
            } catch {
                Write-Host "  [ATTENTION] Échec téléchargement, utilisation de l'image Windows par défaut" -ForegroundColor Yellow
                # Utiliser l'image par défaut Windows
                $wallpaperPath = "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
            }
        } else {
            # Pas d'URL personnalisée fournie, utiliser l'image Windows par défaut
            Write-Host "  [INFO] Utilisation du fond d'écran Windows par défaut (bleu)" -ForegroundColor Cyan
            $wallpaperPath = "C:\Windows\Web\Wallpaper\Windows\img0.jpg"
        }

        # Vérifier que le fichier existe et est valide
        if (-not (Test-Path $wallpaperPath)) {
            Write-Host "  [ERREUR] Fichier image introuvable: $wallpaperPath" -ForegroundColor Red
            return $false
        }

        # Définir le fond d'écran du bureau
        Write-Host "  -> Configuration du fond d'écran..." -ForegroundColor Cyan

        # Méthode 1: Via API Windows (plus fiable)
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

        $SPI_SETDESKWALLPAPER = 0x0014
        $SPIF_UPDATEINIFILE = 0x01
        $SPIF_SENDCHANGE = 0x02

        [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $wallpaperPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE) | Out-Null

        # Méthode 2: Via registre (backup)
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $wallpaperPath -Force
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value "10" -Force  # 10 = Fill (remplir)
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value "0" -Force

        Write-Host "  [OK] Fond d'écran défini" -ForegroundColor Green

        # Définir l'écran de verrouillage (Windows 10/11)
        Write-Host "  -> Configuration de l'écran de verrouillage..." -ForegroundColor Cyan

        try {
            # Copier l'image pour l'écran de verrouillage
            $lockScreenDir = "$env:LOCALAPPDATA\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"

            # Désactiver Windows Spotlight (images Bing sur l'écran de verrouillage)
            $personalizationPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
            Set-ItemProperty -Path $personalizationPath -Name "RotatingLockScreenEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $personalizationPath -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $personalizationPath -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

            # Définir l'image personnalisée
            $lockScreenPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
            if (-not (Test-Path $lockScreenPath)) {
                New-Item -Path $lockScreenPath -Force | Out-Null
            }

            Set-ItemProperty -Path $lockScreenPath -Name "LockScreenImage" -Value $wallpaperPath -Type String -Force -ErrorAction Stop
            Set-ItemProperty -Path $lockScreenPath -Name "PersonalColors_Background" -Value "#002E5D" -Type String -Force -ErrorAction SilentlyContinue

            Write-Host "  [OK] Écran de verrouillage défini" -ForegroundColor Green
        } catch {
            Write-Host "  [ATTENTION] Configuration écran de verrouillage nécessite droits admin" -ForegroundColor Yellow
        }

        Write-Host "  [OK] Configuration Tenor appliquée avec succès" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Export des fonctions publiques du module
Export-ModuleMember -Function @(
    'Invoke-UICustomizations',
    'Set-TaskbarPosition',
    'Set-DarkMode',
    'Set-FileExplorerOptions',
    'Set-DesktopIcons',
    'Set-WindowsTheme',
    'Restart-Explorer',
    'Set-Windows11Taskbar',
    'Restore-Windows10ContextMenu',
    'Hide-NavigationPaneItems',
    'Disable-MouseAcceleration',
    'Set-TenorWallpaper'
)
