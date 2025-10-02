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

                Write-Host "  ✓ Barre des tâches positionnée: $Position" -ForegroundColor Green
                Write-Host "  ⚠ Redémarrage de l'explorateur nécessaire pour appliquer" -ForegroundColor Yellow
                return $true
            }
        }

        Write-Host "  ⚠ Impossible de modifier la position (registre non trouvé)" -ForegroundColor Yellow
        return $false
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
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

        Write-Host "  ✓ Mode $mode activé" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
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

        Write-Host "  ✓ Explorateur configuré" -ForegroundColor Green
        Write-Host "    - Fichiers cachés: $($ShowHiddenFiles)" -ForegroundColor Gray
        Write-Host "    - Extensions visibles: $($ShowFileExtensions)" -ForegroundColor Gray
        Write-Host "    - Chemin complet: $($ShowFullPath)" -ForegroundColor Gray

        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
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

        Write-Host "  ✓ Icônes du bureau configurées" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
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

        Write-Host "  ✓ Thème de couleur appliqué" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
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

        Write-Host "  ✓ Explorateur redémarré" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur lors du redémarrage: $($_.Exception.Message)" -ForegroundColor Red
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
            if (Set-FileExplorerOptions -ShowFileExtensions ($Options.ShowFileExtensions ?? $true) -ShowHiddenFiles ($Options.ShowHiddenFiles ?? $false) -ShowFullPath ($Options.ShowFullPath ?? $true)) {
                $results.Success += "FileExplorer"
            } else {
                $results.Failed += "FileExplorer"
            }
        }

        # Configurer les icônes du bureau
        if ($Options.ContainsKey("ShowThisPC") -or $Options.ContainsKey("ShowRecycleBin")) {
            if (Set-DesktopIcons -ShowThisPC ($Options.ShowThisPC ?? $true) -ShowRecycleBin ($Options.ShowRecycleBin ?? $true) -ShowUserFolder ($Options.ShowUserFolder ?? $false) -ShowNetwork ($Options.ShowNetwork ?? $false)) {
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

# Export des fonctions publiques du module
Export-ModuleMember -Function @(
    'Invoke-UICustomizations',
    'Set-TaskbarPosition',
    'Set-DarkMode',
    'Set-FileExplorerOptions',
    'Set-DesktopIcons',
    'Set-WindowsTheme',
    'Restart-Explorer'
)
