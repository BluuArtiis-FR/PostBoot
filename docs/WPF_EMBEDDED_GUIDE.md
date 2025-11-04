# Guide d'Utilisation - Script PostBootSetup avec WPF Integre

**Version 2.0** | Tenor Data Solutions

---

## Vue d'ensemble

Le script PostBootSetup avec WPF integre est un **fichier PowerShell unique et autonome** qui contient:
- L'interface graphique WPF complete
- Le script d'installation des applications
- Les modules d'optimisation (Debloat, Performance)
- Aucune dependance externe requise

## Avantages

- **Un seul fichier** - Pas de fichiers externes, pas de module a copier
- **Interface graphique moderne** - Suivi en temps reel de la progression
- **Auto-reparation** - Detection et correction automatique du mode STA
- **Fallback console** - Bascule automatique en mode console si WPF ne fonctionne pas

---

## Etape 1 : Generation du Script

### Via l'Interface Web

1. Ouvrir http://localhost:8080 dans le navigateur
2. Selectionner votre profil ou personnaliser les applications
3. Configurer les modules d'optimisation
4. **IMPORTANT**: Cocher la case "Interface WPF integree"
5. Cliquer sur "Generer le script"
6. Le fichier `.ps1` est telecharge (ex: `PostBootSetup_Installation_WPF.ps1`)

### Via l'API cURL

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

## Etape 2 : Execution du Script

### Methode 1 : Double-Clic (Recommandee)

1. **Clic droit** sur le fichier `.ps1`
2. Selectionner **"Executer avec PowerShell"**
3. Le script detecte automatiquement qu'il n'est pas en mode STA
4. **Message affiche**: "Redemarrage du script en mode STA (requis pour l'interface WPF)..."
5. Une nouvelle fenetre PowerShell s'ouvre **en mode Administrateur + STA**
6. L'interface WPF s'affiche automatiquement

### Methode 2 : PowerShell (Avancee)

```powershell
# Demarrer PowerShell en tant qu'Administrateur
powershell.exe -STA -NoProfile -ExecutionPolicy Bypass -File "C:\Chemin\Vers\PostBootSetup_WPF.ps1"
```

### Methode 3 : Mode Console (Sans GUI)

Si vous souhaitez executer le script sans interface graphique:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Chemin\Vers\PostBootSetup_WPF.ps1" -NoGUI
```

---

## Fonctionnement Automatique du Mode STA

### Qu'est-ce que le mode STA?

STA (Single-Threaded Apartment) est un mode de threading requis pour les interfaces WPF. Par defaut, PowerShell demarre en mode MTA (Multi-Threaded Apartment).

### Detection Automatique

Le script contient une verification automatique au demarrage:

```powershell
# Verification automatique
if (-not $NoGUI -and [Threading.Thread]::CurrentThread.GetApartmentState() -ne 'STA') {
    Write-Host "Redemarrage du script en mode STA (requis pour l'interface WPF)..." -ForegroundColor Yellow

    # Relancer le script en mode STA + Administrateur
    Start-Process powershell.exe -ArgumentList "-STA -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -Wait
    exit
}
```

**Resultat**: Vous n'avez **rien a faire** - le script se relance automatiquement en mode STA si necessaire!

---

## Interface WPF - Guide d'Utilisation

### Au Demarrage de l'Interface

Lorsque l'interface WPF s'affiche, vous voyez:

```
┌─────────────────────────────────────────────────────────┐
│  PostBoot Setup - [Profil]                          [X] │
├─────────────────────────────────────────────────────────┤
│  Statut: Pret a demarrer                       0%       │
│  [████████████████████░░░░░░░░░░░░░░░░░░░]             │
├─────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────┐  │
│  │  [i] Initialisation...                           │  │
│  │                                                   │  │
│  │                                                   │  │
│  │                                                   │  │
│  └───────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  [▶ Executer] [💾 Sauvegarder] [🗑 Effacer] [✖ Fermer] │
└─────────────────────────────────────────────────────────┘
```

### Boutons Disponibles

1. **▶ Executer**
   - Demarre l'installation des applications et l'execution des modules
   - Le bouton est desactive pendant l'execution
   - Les logs s'affichent en temps reel

2. **💾 Sauvegarder logs**
   - Enregistre les logs dans un fichier texte
   - Nom par defaut: `PostBootSetup_Log_YYYYMMDD_HHMMSS.txt`

3. **🗑 Effacer logs**
   - Reinitialise la zone de logs
   - Remet la progression a 0%

4. **✖ Fermer**
   - Ferme l'interface
   - Demande confirmation si un script est en cours d'execution

### Pendant l'Execution

La zone de logs affiche:
- `[ℹ]` Information (Cyan)
- `[✓]` Succes (Vert)
- `[⚠]` Avertissement (Jaune)
- `[✗]` Erreur (Rouge)

La barre de progression se met a jour automatiquement:
- Pourcentage affiche en haut a droite
- Statut detaille (ex: "Installation: Git (5/20)")

---

## Depannage

### Probleme 1 : Le script ne s'execute pas (Politique d'execution)

**Message d'erreur**:
```
Le fichier *.ps1 ne peut pas etre charge, car l'execution de scripts est desactivee sur ce systeme.
```

**Solution**:
```powershell
# Executer en tant qu'Administrateur
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

Ou utiliser directement:
```powershell
powershell.exe -ExecutionPolicy Bypass -File "PostBootSetup_WPF.ps1"
```

---

### Probleme 2 : L'interface WPF ne s'affiche pas

**Symptomes**:
- Le script s'execute en mode console
- Pas d'interface graphique visible

**Causes possibles**:

1. **Mode STA non active** (Normalement auto-corrige)
   - Verifier le message: "Redemarrage du script en mode STA..."
   - Si absent, relancer avec `-STA`:
   ```powershell
   powershell.exe -STA -File "PostBootSetup_WPF.ps1"
   ```

2. **Execution via SSH ou session distante**
   - WPF ne fonctionne pas en session non-interactive
   - Solution: Utiliser le parametre `-NoGUI`
   ```powershell
   .\PostBootSetup_WPF.ps1 -NoGUI
   ```

3. **Erreur WPF (affichee en rouge)**
   - Le script bascule automatiquement en mode console
   - Consulter le message d'erreur affiche
   - Verifier que PowerShell 5.1+ est installe

---

### Probleme 3 : Erreur "Add-Type : Unable to load assembly"

**Message d'erreur**:
```
Add-Type : Unable to load assembly 'PresentationFramework'
```

**Cause**: .NET Framework absent ou corrompu

**Solution**:
1. Verifier .NET Framework 4.8+:
   ```powershell
   Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' | Get-ItemPropertyValue -Name Release
   ```
2. Reinstaller .NET Framework 4.8
3. Utiliser le mode console: `.\PostBootSetup_WPF.ps1 -NoGUI`

---

### Probleme 4 : Le script demande toujours les privileges Administrateur

**Cause**: Le script contient `-Verb RunAs` pour garantir l'execution en admin

**Solution**:
- C'est le comportement normal et voulu
- Les installations via Winget necessitent des privileges eleves

---

### Probleme 5 : La barre de progression ne bouge pas

**Cause**: Script d'installation non configure avec `Invoke-WPFProgress`

**Verification**: Consulter les logs dans l'interface
- Si aucun log n'apparait: probleme de communication WPF
- Si logs presents mais progression bloquee: probleme dans le script d'installation

**Solution temporaire**: Les logs continuent de s'afficher en temps reel

---

## Parametres Disponibles

Le script supporte plusieurs parametres:

```powershell
.\PostBootSetup_WPF.ps1 [-NoGUI] [-Silent] [-NoDebloat] [-LogPath <chemin>]
```

### -NoGUI
Force l'execution en mode console (pas d'interface WPF)

**Exemple**:
```powershell
.\PostBootSetup_WPF.ps1 -NoGUI
```

### -Silent
Mode silencieux - pas de confirmation utilisateur

**Exemple**:
```powershell
.\PostBootSetup_WPF.ps1 -Silent
```

### -NoDebloat
Desactive le module Debloat Windows

**Exemple**:
```powershell
.\PostBootSetup_WPF.ps1 -NoDebloat
```

### -LogPath
Specifie un chemin personnalise pour le fichier de log

**Exemple**:
```powershell
.\PostBootSetup_WPF.ps1 -LogPath "C:\Logs\PostBoot.log"
```

### Combinaison de parametres

```powershell
.\PostBootSetup_WPF.ps1 -Silent -NoDebloat -LogPath "C:\Temp\install.log"
```

---

## Fichiers Generes

Apres execution, le script genere:

1. **Fichier de log texte**
   - Emplacement: `%TEMP%\PostBootSetup_YYYYMMDD_HHMMSS.log`
   - Contenu: Tous les messages d'information, succes, erreurs

2. **Fichier JSON (si active)**
   - Emplacement: `%TEMP%\PostBootSetup_YYYYMMDD_HHMMSS.json`
   - Contenu: Logs structures pour analyse automatique

3. **Logs WPF sauvegardes** (si utilise le bouton Sauvegarder)
   - Emplacement: Choisi par l'utilisateur
   - Nom par defaut: `PostBootSetup_Log_YYYYMMDD_HHMMSS.txt`

---

## Exemple d'Utilisation Complete

### Scenario: Installation sur un nouveau PC client

1. **Sur le serveur**: Generer le script via http://localhost:8080
   - Selectionner le profil "TENOR"
   - Cocher "Interface WPF integree"
   - Telecharger `PostBootSetup_Installation_WPF.ps1`

2. **Copier le fichier sur le PC client**
   - Via USB, reseau, ou telechargement direct
   - Un seul fichier `.ps1` suffit!

3. **Sur le PC client**: Executer le script
   - Double-clic sur le fichier `.ps1`
   - OU: Clic droit → "Executer avec PowerShell"
   - OU: `powershell.exe -File "PostBootSetup_Installation_WPF.ps1"`

4. **Auto-relancement en mode STA**
   - Message affiche: "Redemarrage du script en mode STA..."
   - Nouvelle fenetre PowerShell (Admin + STA)

5. **Interface WPF s'affiche**
   - Cliquer sur "Executer"
   - Suivre la progression en temps reel

6. **Fin de l'installation**
   - Sauvegarder les logs si necessaire
   - Fermer l'interface

---

## Architecture Technique

### Structure du Script

```
PostBootSetup_WPF.ps1
│
├─ [Header + Synopsis]
│  └─ Documentation, parametres
│
├─ [Verification Mode STA]
│  └─ Auto-relancement si necessaire
│
├─ [Installation Script Embedded]
│  └─ $Global:InstallationScriptBlock { ... }
│
├─ [Interface WPF]
│  ├─ function Show-WPFInterface { ... }
│  ├─ XAML Definition
│  ├─ Event Handlers
│  └─ Runspace Execution
│
└─ [Main Execution Logic]
   ├─ if ($NoGUI) → Mode console
   └─ else → Show-WPFInterface (avec fallback)
```

### Communication WPF ↔ PowerShell

```
┌─────────────────┐
│  Interface WPF  │
│  (UI Thread)    │
└────────┬────────┘
         │
         │ Variables globales:
         │ $Global:WPFLogControl
         │ $Global:WPFProgressBar
         │ $Global:WPFStatusLabel
         │
         ▼
┌─────────────────┐
│   Runspace      │
│  (STA Thread)   │
└────────┬────────┘
         │
         │ Invoke-WPFLog
         │ Invoke-WPFProgress
         │ Complete-WPFExecution
         │
         ▼
┌─────────────────┐
│ Script Install  │
│ $InstallScript  │
└─────────────────┘
```

---

## FAQ

### Q1: Puis-je utiliser ce script sur Windows Server?
**R**: Oui, mais WPF necessite "Desktop Experience". Sur Server Core, utilisez `-NoGUI`.

### Q2: Le script fonctionne-t-il en mode deconnecte (pas d'internet)?
**R**: Partiellement. Les optimisations fonctionnent, mais Winget necessite une connexion pour telecharger les applications.

### Q3: Combien de temps prend l'installation?
**R**: Entre 5 et 30 minutes selon le nombre d'applications et la vitesse d'internet.

### Q4: Le script peut-il endommager mon systeme?
**R**: Non. Toutes les operations sont reversibles. Les points de restauration et l'hibernation sont preserves.

### Q5: Puis-je annuler l'installation en cours?
**R**: Oui, cliquez sur le bouton "Fermer" ou fermez la fenetre PowerShell. L'installation s'arrete.

---

## Support et Contact

**Contact**: si@tenorsolutions.com
**Documentation complete**: [README.md](../README.md)
**GitHub**: [PostBoot Issues](https://github.com/BluuArtiis-FR/PostBoot/issues)

---

<div align="center">

**PostBootSetup avec WPF Integre v2.0**

Made with PowerShell + WPF by Tenor Data Solutions SI Team

© 2025 Tenor Data Solutions - Usage interne uniquement

</div>
