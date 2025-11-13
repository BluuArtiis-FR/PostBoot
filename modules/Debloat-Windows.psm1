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
        # NOTE: ShowSyncProviderNotifications PRÉSERVÉ car OneDrive Entreprise est requis
        # Masquer ces notifications empêcherait les utilisateurs de voir les erreurs de synchro

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

function Remove-OfficeLanguagePacks {
    <#
    .SYNOPSIS
    Supprime les packs de langues Office inutiles pour garder uniquement Français et Anglais.

    .DESCRIPTION
    Cette fonction détecte et supprime tous les packs de langues Office préinstallés
    sauf le français (fr-fr) et l'anglais (en-us). Cela libère de l'espace disque et
    évite l'encombrement dans les menus Office.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Nettoyage des langues Office inutiles..." -ForegroundColor Cyan

    # Langues à conserver (français et anglais)
    $keepLanguages = @('fr-fr', 'en-us')

    try {
        # Chercher les packs de langues Office installés via AppX
        $officeLanguages = Get-AppxPackage | Where-Object {
            $_.Name -like "*Microsoft.Office.Desktop.LanguagePack*" -or
            $_.Name -like "*Microsoft.LanguageExperiencePack*"
        }

        $removed = 0
        foreach ($lang in $officeLanguages) {
            # Vérifier si c'est une langue à garder
            $isKeepLang = $false
            foreach ($keepLang in $keepLanguages) {
                if ($lang.Name -match $keepLang) {
                    $isKeepLang = $true
                    break
                }
            }

            if (-not $isKeepLang) {
                try {
                    Write-Host "  → Suppression de $($lang.Name)..." -ForegroundColor Gray
                    Remove-AppxPackage -Package $lang.PackageFullName -ErrorAction Stop
                    $removed++
                } catch {
                    Write-Host "  ✗ Échec: $($lang.Name)" -ForegroundColor Yellow
                }
            } else {
                Write-Host "  ✓ Conservation de $($lang.Name)" -ForegroundColor Green
            }
        }

        if ($removed -gt 0) {
            Write-Host "  ✓ $removed pack(s) de langues Office supprimés" -ForegroundColor Green
        } else {
            Write-Host "  ℹ Aucun pack de langue à supprimer" -ForegroundColor Gray
        }

    } catch {
        Write-Host "  ✗ Erreur lors du nettoyage des langues: $($_.Exception.Message)" -ForegroundColor Yellow
    }
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
        Remove-OfficeLanguagePacks
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
    'Remove-OfficeLanguagePacks',
    'Disable-TelemetryServices',
    'Set-PrivacyRegistry',
    'Optimize-WindowsFeatures'
)
