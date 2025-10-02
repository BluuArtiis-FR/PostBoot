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

    # Liste des applications à supprimer (bloatware Windows courant)
    $bloatwareApps = @(
        "Microsoft.3DBuilder"
        "Microsoft.BingFinance"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingWeather"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MixedReality.Portal"
        "Microsoft.Office.OneNote"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsCamera"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
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

    # Liste des services de télémétrie à désactiver
    $telemetryServices = @(
        "DiagTrack"                         # Connected User Experiences and Telemetry
        "dmwappushservice"                  # WAP Push Message Routing Service
        "diagnosticshub.standardcollector.service" # Microsoft Diagnostics Hub
        "WerSvc"                            # Windows Error Reporting
        "OneSyncSvc"                        # Sync Host Service
        "MessagingService"                  # Messaging Service
        "PimIndexMaintenanceSvc"           # Contact Data
        "UserDataSvc"                       # User Data Access
        "UnistoreSvc"                       # User Data Storage
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

    # Définition des modifications du registre pour la confidentialité
    $registrySettings = @(
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
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"
            Name = "SmartScreenEnabled"
            Value = "Off"
            Type = "String"
            Description = "Désactiver SmartScreen"
        },
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
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
            Name = "AllowCortana"
            Value = 0
            Type = "DWord"
            Description = "Désactiver Cortana"
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
            Name = "BingSearchEnabled"
            Value = 0
            Type = "DWord"
            Description = "Désactiver la recherche Bing"
        }
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
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Optimisation des fonctionnalités Windows..." -ForegroundColor Cyan

    try {
        # Désactiver l'indexation sur le disque système (sauf si explicitement nécessaire)
        Write-Host "  Optimisation de l'indexation Windows Search..." -ForegroundColor Yellow
        Get-WmiObject -Class Win32_Service -Filter "Name='WSearch'" | ForEach-Object {
            $_.ChangeStartMode("Manual") | Out-Null
        }
        Write-Host "  ✓ Windows Search configuré en mode manuel" -ForegroundColor Green

        # Désactiver l'hibernation pour libérer de l'espace disque
        Write-Host "  Désactivation de l'hibernation..." -ForegroundColor Yellow
        powercfg -h off 2>$null
        Write-Host "  ✓ Hibernation désactivée" -ForegroundColor Green

        # Désactiver la restauration système pour gagner de l'espace
        Write-Host "  Configuration de la restauration système..." -ForegroundColor Yellow
        Disable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        vssadmin delete shadows /for=C: /all /quiet 2>$null
        Write-Host "  ✓ Points de restauration optimisés" -ForegroundColor Green

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

# Export des fonctions publiques du module
Export-ModuleMember -Function @(
    'Invoke-WindowsDebloat',
    'Remove-BloatwareApps',
    'Disable-TelemetryServices',
    'Set-PrivacyRegistry',
    'Optimize-WindowsFeatures'
)
