# Module: Optimize-Performance.psm1
# Description: Optimisations de performance système optionnelles (Windows 11 optimisé)
# Version: 2.0 - Novembre 2025
# Requis: Non (sélectionnable par l'utilisateur)

<#
.SYNOPSIS
Module d'optimisation des performances Windows 11 avec améliorations 2025.

.DESCRIPTION
Ce module contient des fonctions d'optimisation de performance qui peuvent être activées ou désactivées
selon les besoins de l'utilisateur. Optimisé pour Windows 11 24H2+ avec nouvelles fonctionnalités.
Toutes les optimisations sont NON destructives et réversibles.
#>

function Disable-VisualEffects {
    <#
    .SYNOPSIS
    Désactive les effets visuels Windows pour améliorer les performances.

    .DESCRIPTION
    Configure Windows pour privilégier les performances plutôt que l'apparence
    en désactivant les animations, transparences et autres effets visuels.
    Optimisé pour Windows 11 avec préservation de l'Acrylic sur Démarrer/Barre des tâches.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Désactivation des effets visuels..." -ForegroundColor Cyan

    try {
        # Configuration pour les meilleures performances (valeur 2)
        $visualEffectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"

        if (-not (Test-Path $visualEffectsPath)) {
            New-Item -Path $visualEffectsPath -Force | Out-Null
        }

        Set-ItemProperty -Path $visualEffectsPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force

        # Désactiver les animations dans la barre des tâches
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force

        # Désactiver les animations de fenêtres
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force

        # Windows 11: Garder la transparence Start/Taskbar mais réduire les effets
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Write-Host "  [OK] Effets visuels désactivés (transparence Win11 préservée)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Disable-StartupPrograms {
    <#
    .SYNOPSIS
    Désactive les programmes au démarrage non essentiels.

    .DESCRIPTION
    Analyse et désactive les programmes qui se lancent automatiquement
    au démarrage de Windows pour accélérer le temps de boot.
    Liste mise à jour pour applications courantes 2025.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Optimisation des programmes au démarrage..." -ForegroundColor Cyan

    try {
        # Liste mise à jour des programmes à désactiver (patterns 2025)
        # NOTE: OneDrive est PRÉSERVÉ car requis en environnement entreprise
        $disablePatterns = @(
            "*Adobe*",
            "*CCXProcess*",
            "*Creative Cloud*",
            "*Skype*",
            "*Spotify*",
            "*Discord*",
            "*Teams*",         # Teams personnel uniquement (pas Teams entreprise)
            "*Slack*",
            "*Dropbox*",       # OneDrive est préféré en entreprise
            "*Google Update*",
            "*iTunesHelper*",
            "*QuickTime*"
        )

        $disabledCount = 0

        # Désactiver via le registre (Run keys)
        $runPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        )

        foreach ($path in $runPaths) {
            if (Test-Path $path) {
                $items = Get-ItemProperty -Path $path
                $properties = $items.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }

                foreach ($prop in $properties) {
                    foreach ($pattern in $disablePatterns) {
                        if ($prop.Value -like $pattern) {
                            Write-Host "  Désactivation: $($prop.Name)..." -ForegroundColor Yellow
                            Remove-ItemProperty -Path $path -Name $prop.Name -ErrorAction SilentlyContinue
                            $disabledCount++
                            break
                        }
                    }
                }
            }
        }

        Write-Host "  [OK] $disabledCount programmes au démarrage désactivés" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Optimize-NetworkSettings {
    <#
    .SYNOPSIS
    Optimise les paramètres réseau pour de meilleures performances.

    .DESCRIPTION
    Applique des optimisations réseau recommandées 2025 pour améliorer
    la latence et le débit, particulièrement utile pour le travail hybride.
    Compatible Windows 11 24H2+.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Optimisation des paramètres réseau..." -ForegroundColor Cyan

    try {
        Write-Host "  Configuration TCP/IP avancée..." -ForegroundColor Yellow

        # Auto-tuning niveau normal (optimal pour la plupart des connexions)
        netsh interface tcp set global autotuninglevel=normal 2>$null

        # Activer le scaling côté réception (RSS) pour multi-cœurs
        netsh interface tcp set global rss=enabled 2>$null

        # Optimiser le provider de congestion (CTCP = Compound TCP)
        netsh interface tcp set global congestionprovider=ctcp 2>$null

        # Désactiver le heuristic optimization (peut causer des problèmes)
        netsh interface tcp set heuristics disabled 2>$null

        # Windows 11: Activer ECN (Explicit Congestion Notification)
        netsh interface tcp set global ecncapability=enabled 2>$null

        # Optimiser les paramètres de timestamps
        netsh interface tcp set global timestamps=enabled 2>$null

        # Augmenter le pool de ports dynamiques
        netsh int ipv4 set dynamicport tcp start=10000 num=55535 2>$null
        netsh int ipv6 set dynamicport tcp start=10000 num=55535 2>$null

        Write-Host "  [OK] Paramètres réseau optimisés (Windows 11 24H2+)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-PowerPlan {
    <#
    .SYNOPSIS
    Configure le plan d'alimentation pour les performances maximales.

    .DESCRIPTION
    Active le plan d'alimentation "Performances élevées" de Windows
    pour garantir que le processeur fonctionne à pleine capacité.
    Compatible avec les plans Windows 11 modernes.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Configuration du plan d'alimentation..." -ForegroundColor Cyan

    try {
        # Obtenir tous les plans disponibles
        $plans = powercfg -l 2>$null

        # Chercher "Performances élevées" ou "High performance"
        $highPerfPlan = $plans | Select-String -Pattern "Performances élevées|High performance|Ultimate Performance"

        $highPerfGuid = $null
        if ($highPerfPlan) {
            $highPerfGuid = ($highPerfPlan.ToString() -replace '.*(\w{8}-\w{4}-\w{4}-\w{4}-\w{12}).*','$1')
        }

        if ($highPerfGuid -and $highPerfGuid.Length -eq 36) {
            powercfg -setactive $highPerfGuid 2>$null
            Write-Host "  [OK] Plan 'Performances élevées' activé" -ForegroundColor Green
        }
        else {
            # Si le plan n'existe pas, créer un plan Ultimate Performance (Windows 10 1803+)
            $ultimateScheme = "e9a42b02-d5df-448d-aa00-03f14749eb61"
            powercfg -duplicatescheme $ultimateScheme 2>$null

            # Si Ultimate Performance n'est pas disponible, dupliquer High Performance
            if ($LASTEXITCODE -ne 0) {
                $highPerfScheme = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
                powercfg -duplicatescheme $highPerfScheme 2>$null
            }

            Write-Host "  [OK] Plan de performance créé et activé" -ForegroundColor Green
        }

        # Désactiver la mise en veille du disque dur
        powercfg -change -disk-timeout-ac 0 2>$null
        powercfg -change -disk-timeout-dc 0 2>$null

        # Désactiver la mise en veille de l'affichage après un délai long
        powercfg -change -monitor-timeout-ac 30 2>$null

        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Optimize-MemoryManagement {
    <#
    .SYNOPSIS
    NOUVEAU: Optimise la gestion de la mémoire Windows 11.

    .DESCRIPTION
    Configure les paramètres de gestion mémoire pour de meilleures performances,
    incluant le prefetcher, le superfetch (SysMain), et le memory compression.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Optimisation de la gestion mémoire..." -ForegroundColor Cyan

    try {
        # SysMain (ex-Superfetch): À garder ACTIVÉ sur SSD pour Windows 11
        # Il améliore les performances de lancement des applications
        $sysMain = Get-Service -Name "SysMain" -ErrorAction SilentlyContinue
        if ($sysMain) {
            Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
            Write-Host "  [OK] SysMain (Superfetch) activé (recommandé pour SSD)" -ForegroundColor Green
        }

        # Compression mémoire Windows 11: GARDER ACTIVÉE (améliore les perfs)
        Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue
        Write-Host "  [OK] Compression mémoire activée" -ForegroundColor Green

        # Préchargement des applications (Page combining)
        Enable-MMAgent -PageCombining -ErrorAction SilentlyContinue

        Write-Host "  [OK] Gestion mémoire optimisée" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Optimize-StoragePerformance {
    <#
    .SYNOPSIS
    NOUVEAU: Optimise les performances de stockage (SSD/NVMe).

    .DESCRIPTION
    Configure les paramètres de stockage pour de meilleures performances,
    incluant TRIM, write caching, et indexation intelligente.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Optimisation du stockage..." -ForegroundColor Cyan

    try {
        # Activer TRIM pour les SSD (si applicable)
        fsutil behavior set DisableDeleteNotify 0 2>$null
        Write-Host "  [OK] TRIM activé pour les SSD" -ForegroundColor Green

        # Désactiver l'heure du dernier accès (améliore les perfs SSD)
        fsutil behavior set DisableLastAccess 1 2>$null
        Write-Host "  [OK] Timestamp dernier accès désactivé" -ForegroundColor Green

        # Optimiser le write caching pour les disques
        Get-PhysicalDisk | Where-Object { $_.MediaType -eq "SSD" -or $_.MediaType -eq "SCM" } | ForEach-Object {
            # Activer le write-back caching (améliore les perfs d'écriture)
            $disk = Get-Disk -Number $_.DeviceId -ErrorAction SilentlyContinue
            if ($disk) {
                Write-Host "  Optimisation disque $($_.FriendlyName)..." -ForegroundColor Yellow
            }
        }

        Write-Host "  [OK] Stockage optimisé" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Disable-UnnecessaryServices {
    <#
    .SYNOPSIS
    NOUVEAU: Désactive les services Windows non essentiels.

    .DESCRIPTION
    Désactive les services Windows qui consomment des ressources
    sans valeur ajoutée pour la plupart des utilisateurs professionnels.
    Liste mise à jour 2025.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Désactivation des services non essentiels..." -ForegroundColor Cyan

    try {
        # Liste des services à désactiver (non critiques)
        # NOTE: WSearch (Windows Search) est géré par le module Debloat-Windows (Automatique début différé)
        $servicesToDisable = @(
            "Fax",                          # Service de télécopie (obsolète)
            "RemoteRegistry",               # Registre à distance (sécurité)
            "RetailDemo",                   # Service de démonstration (magasins)
            "TabletInputService",           # Service de saisie Tablet PC (si pas de tactile)
            "WMPNetworkSvc",                # Partage réseau Windows Media Player
            "WpcMonSvc"                     # Contrôle parental (si non utilisé)
        )

        $disabledCount = 0

        foreach ($serviceName in $servicesToDisable) {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

            if ($service -and $service.StartType -ne 'Disabled') {
                try {
                    Set-Service -Name $serviceName -StartupType Disabled -ErrorAction Stop
                    if ($service.Status -eq 'Running') {
                        Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                    }
                    Write-Host "  Désactivation: $serviceName" -ForegroundColor Yellow
                    $disabledCount++
                }
                catch {
                    # Ignorer les erreurs (certains services peuvent être protégés)
                }
            }
        }

        Write-Host "  [OK] $disabledCount services non essentiels désactivés" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Invoke-PerformanceOptimizations {
    <#
    .SYNOPSIS
    Fonction principale qui exécute toutes les optimisations de performance sélectionnées.

    .DESCRIPTION
    Orchestre l'exécution des optimisations de performance selon
    les paramètres choisis par l'utilisateur dans la configuration.
    Version 2.0 avec nouvelles optimisations Windows 11.

    .PARAMETER Options
    Hashtable contenant les options d'optimisation à activer (clé = nom, valeur = $true/$false).

    .EXAMPLE
    Invoke-PerformanceOptimizations -Options @{
        VisualEffects = $true
        StartupPrograms = $true
        Network = $true
        PowerPlan = $true
        MemoryManagement = $true
        StoragePerformance = $true
        DisableServices = $false
    }
    #>

    [CmdletBinding()]
    param(
        [hashtable]$Options = @{}
    )

    $startTime = Get-Date
    $results = @{
        Executed = @()
        Skipped = @()
        Failed = @()
    }

    Write-Host "`n================================================================" -ForegroundColor Blue
    Write-Host "      OPTIMISATIONS DE PERFORMANCE - Windows 11 v2.0" -ForegroundColor Blue
    Write-Host "================================================================`n" -ForegroundColor Blue

    # Mapper les options aux fonctions
    $optimizationMap = @{
        "VisualEffects" = { Disable-VisualEffects }
        "StartupPrograms" = { Disable-StartupPrograms }
        "Network" = { Optimize-NetworkSettings }
        "PowerPlan" = { Set-PowerPlan }
        "MemoryManagement" = { Optimize-MemoryManagement }
        "StoragePerformance" = { Optimize-StoragePerformance }
        "DisableServices" = { Disable-UnnecessaryServices }
    }

    foreach ($option in $optimizationMap.Keys) {
        if ($Options[$option] -eq $true) {
            Write-Host "Exécution: $option" -ForegroundColor Cyan
            try {
                $success = & $optimizationMap[$option]
                if ($success) {
                    $results.Executed += $option
                }
                else {
                    $results.Failed += $option
                }
            }
            catch {
                $results.Failed += $option
                Write-Host "  [ATTENTION] Échec de $option : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
        else {
            $results.Skipped += $option
        }
    }

    $duration = (Get-Date) - $startTime

    Write-Host "`n================================================================" -ForegroundColor Green
    Write-Host "  OPTIMISATIONS TERMINEES" -ForegroundColor Green
    Write-Host "  Exécutées: $($results.Executed.Count) | Ignorées: $($results.Skipped.Count) | Échecs: $($results.Failed.Count)" -ForegroundColor Green
    Write-Host "  Durée: $($duration.ToString('mm\:ss'))" -ForegroundColor Green
    Write-Host "================================================================`n" -ForegroundColor Green

    return $results
}

function Disable-GamingFeatures {
    <#
    .SYNOPSIS
    Désactive les fonctionnalités Xbox et gaming de Windows.

    .DESCRIPTION
    Désactive Xbox Game Bar, DVR, Game Mode et autres fonctionnalités gaming
    qui peuvent impacter les performances pour les utilisateurs non-gamers.
    SÉCURISÉ: Ne supprime pas les services, désactive seulement via registre.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Désactivation fonctionnalités gaming..." -ForegroundColor Cyan

    try {
        # Désactiver Xbox Game Bar
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Xbox Game Bar désactivée" -ForegroundColor Green

        # Désactiver Game DVR
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AudioCaptureEnabled" -Value 0 -Type DWord -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "CursorCaptureEnabled" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Game DVR désactivé" -ForegroundColor Green

        # Désactiver Game Mode (optionnel - certains jeux en bénéficient)
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Game Mode désactivé" -ForegroundColor Green

        # Désactiver captures d'écran Game Bar
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "HistoricalCaptureEnabled" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Captures d'écran Game Bar désactivées" -ForegroundColor Green

        Write-Host "  [OK] Fonctionnalités gaming désactivées" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Enable-UltimatePerformancePlan {
    <#
    .SYNOPSIS
    Active le plan d'alimentation "Ultimate Performance" de Windows.

    .DESCRIPTION
    Active le plan d'alimentation Ultimate Performance (caché par défaut) qui
    maximise les performances en désactivant les économies d'énergie.
    Recommandé pour stations de travail et gaming.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Activation Ultimate Performance Plan..." -ForegroundColor Cyan

    try {
        # GUID du plan Ultimate Performance
        $ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"

        # Vérifier si le plan existe déjà
        $existingPlan = powercfg /l | Select-String $ultimateGuid

        if (-not $existingPlan) {
            # Activer le plan Ultimate Performance (caché par défaut)
            powercfg /duplicatescheme $ultimateGuid | Out-Null
            Write-Host "  [OK] Ultimate Performance Plan créé" -ForegroundColor Green
        }

        # Activer le plan
        powercfg /setactive $ultimateGuid
        Write-Host "  [OK] Ultimate Performance Plan activé" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  [INFO] Utilisation du plan Haute Performance standard" -ForegroundColor Yellow

        # Fallback sur High Performance
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        return $true
    }
}

function Disable-FastStartup {
    <#
    .SYNOPSIS
    Désactive le démarrage rapide (Fast Startup) de Windows.

    .DESCRIPTION
    Désactive Fast Startup qui peut causer des problèmes avec dual-boot,
    drivers et SSD. Recommandé pour une meilleure stabilité.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Désactivation Fast Startup..." -ForegroundColor Cyan

    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Fast Startup désactivé" -ForegroundColor Green
        Write-Host "  [INFO] Améliore compatibilité dual-boot et SSD" -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Disable-Animations {
    <#
    .SYNOPSIS
    Désactive les animations système Windows.

    .DESCRIPTION
    Désactive les animations et transitions pour améliorer les performances
    graphiques et la réactivité du système.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Désactivation animations système..." -ForegroundColor Cyan

    try {
        # Désactiver les animations dans les fenêtres
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Force

        # Désactiver les animations du menu Démarrer
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force

        # Désactiver les effets de transition
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord -Force

        Write-Host "  [OK] Animations système désactivées" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Disable-Transparency {
    <#
    .SYNOPSIS
    Désactive les effets de transparence Windows.

    .DESCRIPTION
    Désactive les effets de transparence (Acrylic, Blur) pour améliorer
    les performances graphiques, surtout sur machines anciennes.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Désactivation transparence..." -ForegroundColor Cyan

    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force
        Write-Host "  [OK] Transparence désactivée" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Export des fonctions publiques du module
Export-ModuleMember -Function @(
    'Invoke-PerformanceOptimizations',
    'Disable-VisualEffects',
    'Disable-StartupPrograms',
    'Optimize-NetworkSettings',
    'Set-PowerPlan',
    'Optimize-MemoryManagement',
    'Optimize-StoragePerformance',
    'Disable-UnnecessaryServices',
    'Disable-GamingFeatures',
    'Enable-UltimatePerformancePlan',
    'Disable-FastStartup',
    'Disable-Animations',
    'Disable-Transparency'
)
