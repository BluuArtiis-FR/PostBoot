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

# Export des fonctions publiques
Export-ModuleMember -Function @(
    'Test-WPFAvailability',
    'Invoke-WPFLog',
    'Invoke-WPFProgress',
    'Complete-WPFExecution'
)
