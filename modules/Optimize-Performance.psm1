# Module: Optimize-Performance.psm1
# Description: Optimisations de performance système optionnelles
# Version: 1.0
# Requis: Non (sélectionnable par l'utilisateur)

<#
.SYNOPSIS
Module d'optimisation des performances Windows.

.DESCRIPTION
Ce module contient des fonctions d'optimisation de performance qui peuvent être activées ou désactivées
selon les besoins de l'utilisateur. Contrairement au debloat obligatoire, ces optimisations sont modulaires
et configurables via l'interface de personnalisation.
#>

function Disable-VisualEffects {
    <#
    .SYNOPSIS
    Désactive les effets visuels Windows pour améliorer les performances.

    .DESCRIPTION
    Cette fonction configure Windows pour privilégier les performances plutôt que l'apparence
    en désactivant les animations, transparences et autres effets visuels.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Désactivation des effets visuels..." -ForegroundColor Cyan

    try {
        # Configuration pour les meilleures performances
        $visualEffectsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"

        if (-not (Test-Path $visualEffectsPath)) {
            New-Item -Path $visualEffectsPath -Force | Out-Null
        }

        Set-ItemProperty -Path $visualEffectsPath -Name "VisualFXSetting" -Value 2 -Type DWord -Force

        # Désactiver les animations dans la barre des tâches
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Value 0 -Type DWord -Force

        # Désactiver les animations de fenêtres
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -Type String -Force

        Write-Host "  ✓ Effets visuels désactivés" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Optimize-PageFile {
    <#
    .SYNOPSIS
    Configure le fichier d'échange (pagefile) pour des performances optimales.

    .DESCRIPTION
    Cette fonction ajuste la taille et l'emplacement du fichier d'échange Windows
    selon les recommandations de performance pour systèmes modernes.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Optimisation du fichier d'échange..." -ForegroundColor Cyan

    try {
        # Obtenir la quantité de RAM installée
        $ram = (Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB

        # Calculer la taille optimale du pagefile (1.5x la RAM pour systèmes < 16GB, sinon fixe à 8GB)
        if ($ram -lt 16) {
            $pageFileSize = [Math]::Round($ram * 1.5) * 1024
        }
        else {
            $pageFileSize = 8192
        }

        Write-Host "  RAM détectée: $([Math]::Round($ram, 2)) GB" -ForegroundColor Yellow
        Write-Host "  Taille du pagefile: $($pageFileSize / 1024) GB" -ForegroundColor Yellow

        # Configuration via WMI
        $computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges
        $computersys.AutomaticManagedPagefile = $false
        $computersys.Put() | Out-Null

        $pagefile = Get-WmiObject Win32_PageFileSetting
        if ($pagefile) {
            $pagefile.Delete()
        }

        Set-WmiInstance -Class Win32_PageFileSetting -Arguments @{
            Name = "C:\pagefile.sys"
            InitialSize = $pageFileSize
            MaximumSize = $pageFileSize
        } | Out-Null

        Write-Host "  ✓ Fichier d'échange optimisé" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Disable-StartupPrograms {
    <#
    .SYNOPSIS
    Désactive les programmes au démarrage non essentiels.

    .DESCRIPTION
    Cette fonction analyse et désactive les programmes qui se lancent automatiquement
    au démarrage de Windows pour accélérer le temps de boot.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Optimisation des programmes au démarrage..." -ForegroundColor Cyan

    try {
        # Liste des programmes à désactiver au démarrage (patterns courants)
        $disablePatterns = @(
            "*Adobe*",
            "*CCXProcess*",
            "*Skype*",
            "*Spotify*",
            "*Discord*"
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

        Write-Host "  ✓ $disabledCount programmes au démarrage désactivés" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Optimize-NetworkSettings {
    <#
    .SYNOPSIS
    Optimise les paramètres réseau pour de meilleures performances.

    .DESCRIPTION
    Cette fonction applique des optimisations réseau recommandées pour améliorer
    la latence et le débit, particulièrement utile pour le travail à distance.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Optimisation des paramètres réseau..." -ForegroundColor Cyan

    try {
        # Désactiver l'auto-tuning de la fenêtre de réception TCP
        Write-Host "  Configuration TCP/IP..." -ForegroundColor Yellow
        netsh interface tcp set global autotuninglevel=normal 2>$null

        # Activer le scaling côté réception (RSS)
        netsh interface tcp set global rss=enabled 2>$null

        # Optimiser les paramètres de congestion TCP
        netsh interface tcp set global congestionprovider=ctcp 2>$null

        # Désactiver le heuristic optimization
        netsh interface tcp set heuristics disabled 2>$null

        Write-Host "  ✓ Paramètres réseau optimisés" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Set-PowerPlan {
    <#
    .SYNOPSIS
    Configure le plan d'alimentation pour les performances maximales.

    .DESCRIPTION
    Cette fonction active le plan d'alimentation "Performances élevées" de Windows
    pour garantir que le processeur fonctionne à pleine capacité.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[PERFORMANCE] Configuration du plan d'alimentation..." -ForegroundColor Cyan

    try {
        # Obtenir le GUID du plan "Performances élevées"
        $highPerfGuid = (powercfg -l | Select-String "Performances élevées|High performance").ToString().Split()[3]

        if ($highPerfGuid) {
            powercfg -setactive $highPerfGuid 2>$null
            Write-Host "  ✓ Plan 'Performances élevées' activé" -ForegroundColor Green
        }
        else {
            # Si le plan n'existe pas, le dupliquer depuis le plan équilibré
            powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            Write-Host "  ✓ Plan de performance créé et activé" -ForegroundColor Green
        }

        return $true
    }
    catch {
        Write-Host "  ⚠ Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Invoke-PerformanceOptimizations {
    <#
    .SYNOPSIS
    Fonction principale qui exécute toutes les optimisations de performance sélectionnées.

    .DESCRIPTION
    Cette fonction orchestre l'exécution des optimisations de performance selon
    les paramètres choisis par l'utilisateur dans la configuration.

    .PARAMETER Options
    Hashtable contenant les options d'optimisation à activer (clé = nom, valeur = $true/$false).

    .EXAMPLE
    Invoke-PerformanceOptimizations -Options @{
        VisualEffects = $true
        PageFile = $true
        StartupPrograms = $true
        Network = $false
        PowerPlan = $true
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
    Write-Host "        OPTIMISATIONS DE PERFORMANCE - OPTIONNEL" -ForegroundColor Blue
    Write-Host "================================================================`n" -ForegroundColor Blue

    # Mapper les options aux fonctions
    $optimizationMap = @{
        "VisualEffects" = { Disable-VisualEffects }
        "PageFile" = { Optimize-PageFile }
        "StartupPrograms" = { Disable-StartupPrograms }
        "Network" = { Optimize-NetworkSettings }
        "PowerPlan" = { Set-PowerPlan }
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
                Write-Host "  ⚠ Échec de $option : $($_.Exception.Message)" -ForegroundColor Red
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

# Export des fonctions publiques du module
Export-ModuleMember -Function @(
    'Invoke-PerformanceOptimizations',
    'Disable-VisualEffects',
    'Optimize-PageFile',
    'Disable-StartupPrograms',
    'Optimize-NetworkSettings',
    'Set-PowerPlan'
)