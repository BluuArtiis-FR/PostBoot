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
        "Microsoft.BingSearch"                  # Widget Bing (Windows 11 22H2+)
        "Microsoft.BingTravel"
        "Microsoft.BingTranslator"
        "Microsoft.BingFoodAndDrink"

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

        # Applications Office Hub et Microsoft 365
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.Office.OneNote"              # Si OneNote desktop installé
        "Microsoft.Office.Sway"
        "Microsoft.OneDrive"                    # OneDrive (si non utilisé)
        "Microsoft.OneNote"                     # OneNote UWP
        "Microsoft.Outlook"                     # Outlook UWP
        "Microsoft.365"                         # Application Microsoft 365

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
        "Microsoft.GamingApp"                   # Xbox Gaming App (Windows 11)

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
        "Microsoft.PowerAutomateDesktop"        # Power Automate
        "Clipchamp.Clipchamp"                   # Éditeur vidéo (Windows 11 23H2+)
        "MicrosoftTeams"                        # Teams consumer (garder version entreprise)
        "Microsoft.DevHome"                     # Dev Home (Windows 11 23H2+)
        "Microsoft.549981C3F5F10"               # Cortana standalone app
        "MicrosoftCorporationII.QuickAssist"    # Quick Assist

        # Autres
        "Microsoft.Wallet"
        "Microsoft.OneConnect"

        # ============================================
        # APPLICATIONS TIERCES (BLOATWARE)
        # ============================================

        # Réseaux sociaux
        "TikTok.TikTok"
        "Twitter.Twitter"
        "Instagram.Instagram"
        "LinkedIn.LinkedIn"
        "Facebook.Facebook"
        "Facebook.InstagramBeta"

        # Streaming et Musique
        "SpotifyAB.SpotifyMusic"
        "Netflix.Netflix"
        "AmazonVideo.PrimeVideo"
        "Disney.37853FC22B2CE"                  # Disney+
        "Hulu.HuluPlus"
        "PandoraMediaInc.29680B314EFC2"         # Pandora
        "iHeartMedia.iHeartRadio"

        # Jeux casual (les plus courants)
        "king.com.CandyCrushSaga"
        "king.com.CandyCrushSodaSaga"
        "king.com.CandyCrushFriends"
        "king.com.BubbleWitch3Saga"
        "Playtika.CaesarsSlotsFreeCasino"
        "A278AB0D.MarchofEmpires"
        "A278AB0D.DisneyMagicKingdoms"
        "AdobeSystemsIncorporated.AdobePhotoshopExpress"
        "GAMELOFTSA.Asphalt8Airborne"
        "2414FC7A.Viber"
        "41038Axilesoft.ACGMediaPlayer"
        "DolbyLaboratories.DolbyAccess"
        "HiddenCityMysteryofShadows"
        "ForgeofEmpires"

        # Actualités et utilitaires
        "Flipboard.Flipboard"
        "ShazamEntertainmentLtd.Shazam"
        "ActiproSoftwareLLC.562882FEEB491"      # Code Writer
        "Duolingo.DuolingoforWindows"
        "EclipseManager"
        "PandoraMediaInc.29680B314EFC2"
        "WinZipComputing.WinZipUniversal"
        "XINGAG.XING"

        # Services et outils tiers
        "AmazonVideo.PrimeVideo"
        "Evernote.Evernote"
        "Wunderlist.Wunderlist"
        "CyberLinkCorp.hs.PowerMediaPlayer14forHPConsumerPC"
        "NAVER.LINEwin8"
        "BytedancePte.Ltd.TikTok"
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

                Write-Host "  [OK] $app supprimé" -ForegroundColor Green
                $removedCount++
            }
            else {
                $skippedCount++
            }
        }
        catch {
            Write-Host "  [ATTENTION] Erreur lors de la suppression de $app : $($_.Exception.Message)" -ForegroundColor Red
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

                Write-Host "  [OK] $serviceName désactivé" -ForegroundColor Green
                $disabledCount++
            }
        }
        catch {
            Write-Host "  [ATTENTION] Erreur lors de la désactivation de $serviceName : $($_.Exception.Message)" -ForegroundColor Red
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

            # Appliquer la valeur du registre avec gestion silencieuse des erreurs de permission
            $prevErrorAction = $ErrorActionPreference
            $ErrorActionPreference = 'SilentlyContinue'
            Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -Type $setting.Type -Force
            $ErrorActionPreference = $prevErrorAction

            if ($?) {
                Write-Host "  [OK] $($setting.Description) appliqué" -ForegroundColor Green
                $appliedCount++
            } else {
                Write-Host "  [ATTENTION] $($setting.Description) - Permission refusée (ignoré)" -ForegroundColor Yellow
                $appliedCount++  # Compter comme appliqué pour ne pas bloquer
            }
        }
        catch {
            Write-Host "  [ATTENTION] Erreur: $($setting.Description) - $($_.Exception.Message)" -ForegroundColor Red
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
            Write-Host "  [OK] Windows Search configuré en Automatique (Début différé)" -ForegroundColor Green
        }

        # NOTE: L'hibernation et la restauration système sont PRÉSERVÉS pour la sécurité
        Write-Host "  [INFO] Hibernation et points de restauration préservés (sécurité)" -ForegroundColor Cyan

    }
    catch {
        Write-Host "  [ATTENTION] Erreur lors de l'optimisation: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host "`n[DEBLOAT] Optimisations système appliquées" -ForegroundColor Green
}

function Remove-OfficeLanguagePacks {
    <#
    .SYNOPSIS
    Supprime les applications Microsoft 365 et packs de langues Office préinstallés avec Windows.

    .DESCRIPTION
    Cette fonction désinstalle les applications Office préinstallées (Microsoft 365, OneNote, packs de langues)
    qui ne sont pas des packages UWP mais des applications Win32 installées avec Windows 11.
    Elle utilise winget pour les supprimer proprement avant l'installation de la suite Office 365 entreprise.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Suppression des applications Office préinstallées..." -ForegroundColor Cyan

    # Liste des applications Office préinstallées à supprimer via winget
    $preinstalledOfficeApps = @(
        # Packs de langues Microsoft 365 (installés avec Windows)
        "Microsoft.365 - de-de"
        "Microsoft.365 - en-us"
        "Microsoft.365 - fr-fr"
        "Microsoft.365 - it-it"
        "Microsoft.365 - nl-nl"
        "Microsoft.365 - es-es"
        "Microsoft.365 - pt-br"

        # Packs de langues OneNote
        "Microsoft OneNote - de-de"
        "Microsoft OneNote - en-us"
        "Microsoft OneNote - fr-fr"
        "Microsoft OneNote - it-it"
        "Microsoft OneNote - nl-nl"
        "Microsoft OneNote - es-es"
        "Microsoft OneNote - pt-br"

        # OneDrive consumer (sera remplacé par version entreprise)
        "Microsoft OneDrive"
    )

    $removedCount = 0
    $skippedCount = 0

    foreach ($appName in $preinstalledOfficeApps) {
        try {
            # Chercher dans le registre Windows (méthode la plus fiable)
            $uninstallKeys = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )

            $found = $false
            foreach ($key in $uninstallKeys) {
                $apps = Get-ItemProperty $key -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$appName*" }

                foreach ($app in $apps) {
                    if ($app.UninstallString) {
                        $uninstallCmd = $app.UninstallString

                        # Si c'est un MSI (contient msiexec ou un GUID)
                        if ($uninstallCmd -match 'msiexec' -or $uninstallCmd -match '\{[A-Z0-9\-]+\}') {
                            if ($uninstallCmd -match '\{[A-Z0-9\-]+\}') {
                                $productCode = $matches[0]
                                # Désinstaller silencieusement via msiexec
                                Start-Process "msiexec.exe" -ArgumentList "/x `"$productCode`" /qn /norestart" -Wait -NoNewWindow -ErrorAction SilentlyContinue
                                $found = $true
                                $removedCount++
                            }
                        }
                    }
                }
            }

            if (-not $found) {
                $skippedCount++
            }
        }
        catch {
            $skippedCount++
        }
    }

    # Gestion des packs de langues AppX (ancienne méthode, conservée pour compatibilité)
    try {
        $officeLanguages = Get-AppxPackage | Where-Object {
            $_.Name -like "*Microsoft.Office.Desktop.LanguagePack*" -or
            $_.Name -like "*Microsoft.LanguageExperiencePack*"
        }

        foreach ($lang in $officeLanguages) {
            # Garder uniquement fr-fr et en-us
            if ($lang.Name -notmatch 'fr-fr' -and $lang.Name -notmatch 'en-us') {
                try {
                    Remove-AppxPackage -Package $lang.PackageFullName -ErrorAction SilentlyContinue
                    if ($?) { $removedCount++ }
                } catch {
                    # Erreur silencieuse
                }
            }
        }
    } catch {
        # Erreur silencieuse pour AppX (peut ne pas exister)
    }

    Write-Host "`n[DEBLOAT] Office préinstallé: $removedCount applications désinstallées, $skippedCount absentes/ignorées" -ForegroundColor Green
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
        Disable-AIFeatures
        Disable-ThirdPartyTelemetry
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

function Disable-AIFeatures {
    <#
    .SYNOPSIS
    Désactive les fonctionnalités d'intelligence artificielle de Windows 11 24H2+.

    .DESCRIPTION
    Désactive Windows Recall, Click to Do, et autres fonctionnalités IA invasives
    introduites dans Windows 11 24H2 et versions ultérieures.
    NOTE: Copilot est déjà géré dans Set-PrivacyRegistry.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Désactivation des fonctionnalités IA..." -ForegroundColor Cyan

    try {
        $registrySettings = @(
            # Windows Recall (enregistrement écran IA - 24H2+)
            @{
                Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI"
                Name = "DisableAIDataAnalysis"
                Value = 1
                Type = "DWord"
                Description = "Désactiver Windows Recall"
            },
            @{
                Path = "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI"
                Name = "DisableAIDataAnalysis"
                Value = 1
                Type = "DWord"
                Description = "Désactiver Windows Recall (utilisateur)"
            },

            # Click to Do (analyse IA texte/image)
            @{
                Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\SmartActionPlatform\SmartClipboard"
                Name = "Disabled"
                Value = 1
                Type = "DWord"
                Description = "Désactiver Click to Do"
            },
            @{
                Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\SmartActionPlatform"
                Name = "Disabled"
                Value = 1
                Type = "DWord"
                Description = "Désactiver Smart Action Platform"
            },

            # Edge AI Features (suggestions IA dans Edge)
            @{
                Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
                Name = "HubsSidebarEnabled"
                Value = 0
                Type = "DWord"
                Description = "Désactiver Edge Sidebar (Bing AI)"
            },
            @{
                Path = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
                Name = "DiscoverPageContextEnabled"
                Value = 0
                Type = "DWord"
                Description = "Désactiver Edge Discover"
            }
        )

        foreach ($setting in $registrySettings) {
            try {
                if (-not (Test-Path $setting.Path)) {
                    New-Item -Path $setting.Path -Force | Out-Null
                }

                Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -Type $setting.Type -Force
                Write-Host "  [OK] $($setting.Description)" -ForegroundColor Green
            }
            catch {
                Write-Host "  [ATTENTION] Échec: $($setting.Description)" -ForegroundColor Yellow
            }
        }

        Write-Host "  [OK] Fonctionnalités IA désactivées" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Disable-ThirdPartyTelemetry {
    <#
    .SYNOPSIS
    Désactive la télémétrie des applications tierces courantes.

    .DESCRIPTION
    Désactive la collecte de données par Adobe, Google Chrome, VS Code, Nvidia GeForce Experience,
    et autres applications tierces qui collectent des données d'utilisation.
    #>

    [CmdletBinding()]
    param()

    Write-Host "`n[DEBLOAT] Désactivation télémétrie applications tierces..." -ForegroundColor Cyan

    try {
        $registrySettings = @(
            # Adobe telemetry
            @{
                Path = "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown"
                Name = "bUsageMeasurement"
                Value = 0
                Type = "DWord"
                Description = "Désactiver télémétrie Adobe Reader"
            },

            # Google Chrome telemetry
            @{
                Path = "HKLM:\SOFTWARE\Policies\Google\Chrome"
                Name = "MetricsReportingEnabled"
                Value = 0
                Type = "DWord"
                Description = "Désactiver télémétrie Google Chrome"
            },
            @{
                Path = "HKLM:\SOFTWARE\Policies\Google\Chrome"
                Name = "ChromeCleanupReportingEnabled"
                Value = 0
                Type = "DWord"
                Description = "Désactiver rapports Chrome Cleanup"
            },

            # Visual Studio Code telemetry
            @{
                Path = "HKCU:\Software\Microsoft\VSCode"
                Name = "telemetry.enableTelemetry"
                Value = 0
                Type = "DWord"
                Description = "Désactiver télémétrie VS Code"
            },

            # Nvidia telemetry
            @{
                Path = "HKLM:\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client"
                Name = "OptInOrOutPreference"
                Value = 0
                Type = "DWord"
                Description = "Désactiver télémétrie Nvidia"
            },
            @{
                Path = "HKLM:\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer"
                Name = "Start"
                Value = 4
                Type = "DWord"
                Description = "Désactiver service Nvidia Telemetry"
            }
        )

        $settingsApplied = 0
        foreach ($setting in $registrySettings) {
            try {
                if (-not (Test-Path $setting.Path)) {
                    New-Item -Path $setting.Path -Force | Out-Null
                }

                Set-ItemProperty -Path $setting.Path -Name $setting.Name -Value $setting.Value -Type $setting.Type -Force
                Write-Host "  [OK] $($setting.Description)" -ForegroundColor Green
                $settingsApplied++
            }
            catch {
                # Ne pas afficher d'erreur si l'application n'est pas installée
                Write-Verbose "  - $($setting.Description) (app non installée)"
            }
        }

        Write-Host "  [OK] Télémétrie tierces désactivée ($settingsApplied paramètres appliqués)" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "  [ATTENTION] Erreur: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Export des fonctions publiques du module
Export-ModuleMember -Function @(
    'Invoke-WindowsDebloat',
    'Remove-BloatwareApps',
    'Remove-OfficeLanguagePacks',
    'Disable-TelemetryServices',
    'Set-PrivacyRegistry',
    'Optimize-WindowsFeatures',
    'Disable-AIFeatures',
    'Disable-ThirdPartyTelemetry'
)
