# Corrections WPF - PostBootSetup

**Date**: 2025-11-05
**Version**: 5.1

---

## Problèmes Corrigés

### 1. ✅ Interface WPF ne s'affichait pas (Mode STA)

**Symptôme**: Le script s'exécutait en mode console au lieu d'afficher l'interface graphique WPF.

**Cause**: PowerShell n'était pas en mode STA (Single-Threaded Apartment) requis pour WPF. Par défaut, double-cliquer sur un `.ps1` lance PowerShell en mode MTA.

**Solution Appliquée**:
- Ajout d'une vérification automatique du mode STA au démarrage du script
- Si MTA détecté, le script se relance automatiquement en mode STA + Admin
- Lignes 36-50 du script généré

```powershell
# Vérifier et forcer le mode STA (requis pour WPF)
if (-not $NoGUI -and [Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    Write-Host "Redémarrage du script en mode STA (requis pour l'interface WPF)..." -ForegroundColor Yellow

    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-STA -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $($params -join ' ')" -Verb RunAs -Wait
    exit
}
```

**Résultat**: L'interface WPF s'affiche maintenant correctement ✓

---

### 2. ✅ Erreur d'interaction utilisateur dans le Runspace

**Symptôme**:
```
[ERREUR CRITIQUE] Une commande d'invite de l'utilisateur a échoué, car le programme hôte
ou le type de commande ne prend pas en charge l'interaction avec l'utilisateur.
```

**Cause**: Le Runspace qui exécute le script d'installation essayait d'afficher des boîtes de dialogue ou demandes de confirmation, mais n'avait pas de host interactif.

**Solution Appliquée**:
1. Forcer `$Silent = $true` dans le Runspace (ligne 503)
2. Désactiver toutes les préférences de confirmation PowerShell (lignes 524-526)

```powershell
# Forcer Silent pour éviter les invites utilisateur
$runspace.SessionStateProxy.SetVariable("Silent", $true)

# Dans le scriptblock
$ConfirmPreference = 'None'
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Continue'
```

**Résultat**: Plus d'erreur d'interaction utilisateur ✓

---

### 3. ✅ Logs ne s'affichaient pas en temps réel

**Symptôme**: La zone de logs dans l'interface WPF restait vide pendant l'exécution.

**Cause**: Les fonctions `Invoke-WPFLog` et `Invoke-WPFProgress` appelées par `Write-ScriptLog` n'étaient pas définies dans le Runspace.

**Solution Appliquée**:
Ajout de 3 fonctions globales dans le Runspace (lignes 529-586) :

1. **`Invoke-WPFLog`** - Affiche les messages dans la zone de logs
   ```powershell
   function global:Invoke-WPFLog {
       param([string]$Message, [string]$Level = 'INFO')

       $timestamp = Get-Date -Format 'HH:mm:ss'
       $prefix = switch ($Level) {
           'SUCCESS' { '[✓]' }
           'ERROR'   { '[✗]' }
           'WARNING' { '[⚠]' }
           default   { '[ℹ]' }
       }

       $formattedMessage = "[$timestamp] $prefix $Message`n"

       $Dispatcher.Invoke([action]{
           $LogControl.AppendText($formattedMessage)
           $LogControl.ScrollToEnd()
       })
   }
   ```

2. **`Invoke-WPFProgress`** - Met à jour la barre de progression
   ```powershell
   function global:Invoke-WPFProgress {
       param([int]$PercentComplete, [string]$Status)

       $Dispatcher.Invoke([action]{
           if ($PercentComplete -ge 0 -and $PercentComplete -le 100) {
               $ProgressBar.Value = $PercentComplete
               $PercentLabel.Text = "$PercentComplete%"
           }
           if ($Status) {
               $StatusLabel.Text = $Status
           }
       })
   }
   ```

3. **`Complete-WPFExecution`** - Notification de fin d'exécution
   ```powershell
   function global:Complete-WPFExecution {
       param([bool]$Success, [string]$Summary)

       $Dispatcher.Invoke([action]{
           if ($Success) {
               $StatusLabel.Text = "✓ $Summary"
               $ProgressBar.Value = 100
               $PercentLabel.Text = "100%"
           } else {
               $StatusLabel.Text = "✗ $Summary"
           }
       })
   }
   ```

**Résultat**: Les logs s'affichent maintenant en temps réel avec timestamps et icônes colorées ✓

---

## Fonctionnalités Confirmées

### ✅ Affichage des Logs en Temps Réel

**OUI**, les logs s'affichent en temps réel dans l'interface WPF pendant :
- L'installation des applications
- L'exécution des optimisations (Debloat, Performance)
- Les téléchargements
- Les erreurs éventuelles

Chaque appel à `Write-ScriptLog` dans le script d'installation déclenche automatiquement `Invoke-WPFLog` qui met à jour l'interface.

**Format des logs** :
```
[HH:mm:ss] [ℹ] Information générale
[HH:mm:ss] [✓] Opération réussie
[HH:mm:ss] [⚠] Avertissement
[HH:mm:ss] [✗] Erreur
```

### ✅ Barre de Progression

La barre de progression se met à jour automatiquement :
- Pendant l'installation des applications (pourcentage basé sur nombre d'apps)
- Pendant les optimisations (pourcentage par module)
- Affichage du statut détaillé (ex: "Installation: Git (5/20)")

---

## Fichiers Modifiés

### `generator/app.py`

**Lignes modifiées** :
- **241-255** : Ajout de la vérification et relance en mode STA
- **503** : Force `$Silent = $true` dans le Runspace
- **524-526** : Désactivation des préférences de confirmation PowerShell
- **529-586** : Définition des fonctions `Invoke-WPFLog`, `Invoke-WPFProgress`, `Complete-WPFExecution`

**Statistiques du nouveau script généré** :
- Lignes : **2426** (+66 lignes)
- Fonctions : **31** (+3 fonctions)
- Tokens : **7352**

---

## Fichiers de Test Générés

1. **`generated/PostBootSetup_WPF_FIXED.ps1`** - Script corrigé prêt à utiliser
2. **`generated/VerificationWPF_STA.ps1`** - Script de vérification
3. **`generated/TestWPF_STA_Fixed.ps1`** - Script de test antérieur

---

## Instructions pour Générer un Nouveau Script

### Via l'Interface Web (Recommandé)

1. Ouvrir http://localhost:8080
2. Sélectionner votre profil ou personnaliser
3. **Cocher "Interface WPF intégrée"**
4. Générer et télécharger
5. Double-cliquer sur le fichier `.ps1` téléchargé

### Via l'API

```bash
curl -X POST http://localhost:5000/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "config": {
      "profile": "TENOR",
      "embed_wpf": true
    },
    "scriptTypes": ["installation", "optimizations"],
    "embedWpf": true
  }' \
  --output PostBootSetup_WPF.ps1
```

---

## Comportement Attendu à l'Exécution

### Étape 1 : Double-clic sur le script
```
Redémarrage du script en mode STA (requis pour l'interface WPF)...
```
↓ Nouvelle fenêtre PowerShell s'ouvre (Admin + STA)

### Étape 2 : Interface WPF s'affiche
```
┌─────────────────────────────────────────────────┐
│  PostBoot Setup - Test WPF                  [X] │
├─────────────────────────────────────────────────┤
│  Statut: Prêt à démarrer              0%        │
│  [████████░░░░░░░░░░░░░░░░░░░░░░░]              │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐  │
│  │ [ℹ] Initialisation...                    │  │
│  │                                           │  │
│  └───────────────────────────────────────────┘  │
├─────────────────────────────────────────────────┤
│  [▶ Exécuter] [💾 Sauvegarder] [✖ Fermer]      │
└─────────────────────────────────────────────────┘
```

### Étape 3 : Clic sur "Exécuter"
Les logs s'affichent en temps réel :
```
[14:23:45] [ℹ] ========================================
[14:23:45] [✓] DÉMARRAGE DE L'INSTALLATION
[14:23:45] [ℹ] ========================================
[14:23:46] [ℹ] Vérification Winget...
[14:23:47] [✓] Winget disponible
[14:23:48] [ℹ] Installation: Git.Git (1/1)
[14:23:49] [ℹ] Téléchargement de Git.Git...
[14:24:15] [✓] Git.Git installé avec succès
```

Barre de progression se met à jour automatiquement :
- `0%` → `25%` → `50%` → `75%` → `100%`

---

## Tests de Validation

### ✅ Test 1 : Mode STA Auto-Détection
**Commande** : Double-clic sur le script
**Résultat Attendu** : Message jaune "Redémarrage du script en mode STA..." → Interface WPF s'affiche
**Statut** : PASSÉ ✓

### ✅ Test 2 : Pas d'Erreur d'Interaction Utilisateur
**Commande** : Exécuter l'installation via l'interface WPF
**Résultat Attendu** : Aucune erreur de type "interaction utilisateur échouée"
**Statut** : PASSÉ ✓

### ✅ Test 3 : Logs en Temps Réel
**Commande** : Observer la zone de logs pendant l'installation
**Résultat Attendu** : Messages apparaissent immédiatement avec timestamps
**Statut** : PASSÉ ✓

### ✅ Test 4 : Barre de Progression
**Commande** : Observer la barre pendant l'installation
**Résultat Attendu** : Pourcentage et statut se mettent à jour
**Statut** : PASSÉ ✓

### ✅ Test 5 : Validation Syntaxe PowerShell
**Commande** : `ValidateScript.ps1 PostBootSetup_WPF_FIXED.ps1`
**Résultat** :
```
[OK] Script PowerShell valide
Statistiques:
  - Lignes: 2426
  - Fonctions: 31
  - Tokens: 7352
```
**Statut** : PASSÉ ✓

---

## Prochaines Étapes (Recommandées)

### 1. Documentation Utilisateur
- Guide simplifié pour les techniciens
- Captures d'écran de l'interface WPF
- FAQ sur les erreurs courantes

### 2. Tests Supplémentaires
- Test sur Windows 10 (différentes versions)
- Test sur Windows 11 (23H2, 24H2)
- Test avec profil TENOR complet (nombreuses applications)

### 3. Améliorations Futures (Optionnelles)
- Ajout d'un bouton "Pause" pour suspendre l'installation
- Statistiques détaillées en fin d'installation
- Export HTML du rapport d'installation
- Bouton "Annuler" pour arrêter l'installation en cours

---

## Remarques Importantes

### Mode Silent Forcé dans le Runspace
Le script force automatiquement `$Silent = $true` dans le Runspace pour éviter les invites utilisateur. Cela signifie que :
- ✅ Aucune boîte de dialogue ne bloque l'exécution
- ✅ Les logs WPF restent actifs
- ⚠️ Les `Write-Host` ne s'affichent pas dans la console PowerShell (mais les logs WPF fonctionnent)

### Performances
L'exécution en Runspace séparé permet :
- Interface WPF reste réactive pendant l'installation
- Pas de blocage de l'UI
- Possibilité d'afficher des logs en temps réel

### Compatibilité
- **Requis** : PowerShell 5.1+
- **Requis** : Windows 10 1809+ ou Windows 11
- **Requis** : .NET Framework 4.8+
- **Recommandé** : Exécution en tant qu'Administrateur (auto-demandé)

---

## Support

**Contact SI** : si@tenorsolutions.com
**Documentation** : [README.md](README.md) | [WPF_EMBEDDED_GUIDE.md](docs/WPF_EMBEDDED_GUIDE.md)
**GitHub Issues** : [PostBoot Issues](https://github.com/BluuArtiis-FR/PostBoot/issues)

---

<div align="center">

**PostBootSetup v5.1 avec WPF Corrigé**

© 2025 Tenor Data Solutions SI Team

</div>
