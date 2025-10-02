# Guide Complet PostBootSetup v5.0

## 🎯 Introduction : Comprendre le projet en 3 minutes

PostBootSetup v5.0 est un système de génération de scripts Windows qui fonctionne en trois étapes simples :

1. **L'utilisateur personnalise** son installation via une interface web
2. **Le serveur Docker génère** un script PowerShell ou un .exe personnalisé
3. **Le script s'exécute** de manière autonome sur le poste Windows cible

### Analogie simple
Imagine un restaurant où tu personnalises ton burger en ligne (interface web), la cuisine prépare ton burger selon tes choix (API Docker), et tu reçois un burger tout prêt à manger (script autonome).

## 📊 Schéma de l'architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     NAVIGATEUR WEB                               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Interface Web (http://localhost)                         │  │
│  │  • Sélection profil (DEV / SUPPORT / SI / Custom)        │  │
│  │  • Choix applications (checkboxes)                        │  │
│  │  • Configuration modules (sliders, toggles)              │  │
│  │  • Bouton "Générer .ps1" ou "Générer .exe"              │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTP POST /api/generate/script
                            │ {config JSON}
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CONTAINER DOCKER API                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  API Flask (Python) - Port 5000                           │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  1. Validation configuration                        │  │  │
│  │  │  2. Chargement modules PowerShell nécessaires      │  │  │
│  │  │  3. Injection config + code dans template          │  │  │
│  │  │  4. Génération script autonome .ps1                │  │  │
│  │  │  5. (Optionnel) Compilation .exe via PS2EXE        │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                              │  │
│  │  Ressources:                                                 │  │
│  │  • config/apps.json (applications disponibles)              │  │
│  │  • config/settings.json (modules d'optimisation)            │  │
│  │  • modules/*.psm1 (code PowerShell)                         │  │
│  │  • templates/main_template.ps1 (squelette)                  │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │ HTTP 200 OK
                            │ {script_id, download_url}
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                     NAVIGATEUR WEB                               │
│  GET /api/download/{script_id}                                  │
│  ⬇ Téléchargement MonScript.ps1 ou MonScript.exe                │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            │ Transfert vers poste Windows
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    POSTE WINDOWS CIBLE                           │
│  Clic droit > Exécuter en tant qu'administrateur               │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Script PowerShell autonome                               │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  📦 Configuration embarquée (JSON inline)          │  │  │
│  │  │  🔧 Fonctions utilitaires                          │  │  │
│  │  │  📜 Module Debloat-Windows (code complet)          │  │  │
│  │  │  📜 Module Optimize-Performance (si activé)        │  │  │
│  │  │  📜 Module Customize-UI (si activé)                │  │  │
│  │  │  🎭 Orchestrateur principal                        │  │  │
│  │  └────────────────────────────────────────────────────┘  │  │
│  │                                                              │  │
│  │  Exécution:                                                  │  │
│  │  1. ✅ Vérification admin + Winget                           │  │
│  │  2. 🧹 Debloat Windows (obligatoire)                         │  │
│  │  3. 📦 Installation applications (master + profil)           │  │
│  │  4. ⚡ Optimisations performance (optionnel)                 │  │
│  │  5. 🎨 Personnalisation UI (optionnel)                       │  │
│  │  6. 📊 Résumé et log final                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🗂️ Structure des fichiers expliquée

### Configuration (config/)

**apps.json** - Définit toutes les applications installables
```json
{
  "master": [                    // Applications obligatoires pour tous
    {
      "name": "Microsoft Office",
      "winget": "Microsoft.Office",  // ID Winget
      "size": "3 GB"
    }
  ],
  "profiles": {
    "DEV": {                     // Profil développeur
      "apps": [
        {
          "name": "VS Code",
          "winget": "Microsoft.VisualStudioCode"
        }
      ]
    }
  },
  "optional": [                  // Applications à la carte
    {"name": "7-Zip", "winget": "7zip.7zip"}
  ]
}
```

**settings.json** - Définit les modules d'optimisation
```json
{
  "modules": {
    "debloat": {
      "required": true,          // ⚠️ OBLIGATOIRE
      "enabled": true,
      "module": "Debloat-Windows",
      "function": "Invoke-WindowsDebloat"
    },
    "performance": {
      "required": false,         // 🟡 Recommandé
      "recommended": true,
      "enabled": true,
      "module": "Optimize-Performance",
      "options": {
        "PageFile": {
          "enabled": true,
          "recommended": true    // Pré-coché dans UI
        }
      }
    }
  }
}
```

### Modules PowerShell (modules/)

**Anatomie d'un module**
```powershell
# modules/Mon-Module.psm1

# Fonction principale (appelée par le script généré)
function Invoke-MonModule {
    param([hashtable]$Options)

    Write-Host "Exécution de mon module..."

    # Logique du module ici
    if ($Options['Option1']) {
        # Faire quelque chose
    }

    return @{
        Success = $true
        Message = "Module exécuté"
    }
}

# Fonctions secondaires
function Ma-Fonction-Helper {
    # Code helper
}

# Export uniquement les fonctions publiques
Export-ModuleMember -Function 'Invoke-MonModule'
```

### API Flask (generator/app.py)

**Flux de génération d'un script**

```python
# 1. Réception de la requête
@app.route('/api/generate/script', methods=['POST'])
def generate_script():
    user_config = request.json  # Configuration utilisateur

    # 2. Validation
    is_valid, error = generator.validate_config(user_config)
    if not is_valid:
        return jsonify({'error': error}), 400

    # 3. Génération du script
    script_content = generator.generate_script(
        user_config,
        profile_name="Custom"
    )

    # Le générateur fait :
    # a) Charge le template de base
    # b) Remplace {{EMBEDDED_CONFIG}} par le JSON
    # c) Charge les modules .psm1 activés
    # d) Remplace {{MODULES_CODE}} par le code des modules
    # e) Génère l'orchestrateur selon les modules
    # f) Assemble le tout

    # 4. Sauvegarde
    script_id = uuid.uuid4()
    script_path = f"generated/Script_{script_id}.ps1"
    save_file(script_path, script_content)

    # 5. Retour au client
    return jsonify({
        'success': True,
        'script_id': script_id,
        'download_url': f'/api/download/{script_id}'
    })
```

## 🔄 Cycle de vie complet d'un script

### Phase 1 : Personnalisation (Interface Web)

```
Utilisateur          Interface Web              API
    │                      │                      │
    │   Accès localhost    │                      │
    ├─────────────────────>│                      │
    │                      │                      │
    │   Sélectionne DEV    │                      │
    │   + Chrome           │                      │
    │   + Debloat ON       │                      │
    │   + Performance ON   │                      │
    │                      │                      │
    │   Clic "Générer"     │                      │
    ├─────────────────────>│                      │
    │                      │  POST /generate      │
    │                      ├─────────────────────>│
    │                      │  {config JSON}       │
```

### Phase 2 : Génération (Docker API)

```
API                 ScriptGenerator           Modules
 │                       │                       │
 │  generate_script()    │                       │
 ├──────────────────────>│                       │
 │                       │                       │
 │                       │  Load template        │
 │                       │                       │
 │                       │  Load apps.json       │
 │                       │                       │
 │                       │  Load settings.json   │
 │                       │                       │
 │                       │  Read Debloat-Windows │
 │                       ├──────────────────────>│
 │                       │  <module code>        │
 │                       │<──────────────────────┤
 │                       │                       │
 │                       │  Read Optimize-Perf   │
 │                       ├──────────────────────>│
 │                       │  <module code>        │
 │                       │<──────────────────────┤
 │                       │                       │
 │                       │  Assemble script      │
 │                       │  • Header             │
 │                       │  • Embedded config    │
 │                       │  • Utilities          │
 │                       │  • Modules code       │
 │                       │  • Orchestrator       │
 │                       │                       │
 │  <script complete>    │                       │
 │<──────────────────────┤                       │
 │                       │                       │
 │  Save to generated/   │                       │
 │                       │                       │
 │  Return download URL  │                       │
```

### Phase 3 : Exécution (Poste Windows)

```
Script              Windows System         Modules
  │                       │                   │
  │  Start                │                   │
  │                       │                   │
  │  Check admin          │                   │
  ├──────────────────────>│                   │
  │  <is admin>           │                   │
  │<──────────────────────┤                   │
  │                       │                   │
  │  Check winget         │                   │
  ├──────────────────────>│                   │
  │  <winget ok>          │                   │
  │<──────────────────────┤                   │
  │                       │                   │
  │  Invoke-Debloat       │                   │
  ├───────────────────────────────────────────>│
  │                       │   Remove bloatware│
  │                       │<──────────────────┤
  │                       │   Disable services│
  │                       │<──────────────────┤
  │  <debloat done>       │                   │
  │<───────────────────────────────────────────┤
  │                       │                   │
  │  Install apps         │                   │
  ├──────────────────────>│                   │
  │  winget install       │                   │
  │  (loop pour chaque)   │                   │
  │                       │                   │
  │  Invoke-Performance   │                   │
  ├───────────────────────────────────────────>│
  │                       │   PageFile        │
  │                       │   PowerPlan       │
  │  <perf done>          │                   │
  │<───────────────────────────────────────────┤
  │                       │                   │
  │  Show summary         │                   │
  │  Exit                 │                   │
```

## 🧪 Exemples pratiques

### Exemple 1 : Script minimal (Debloat seulement)

**Configuration envoyée à l'API**
```json
{
  "profile_name": "Minimal",
  "apps": {
    "master": [],
    "profile": []
  },
  "modules": ["debloat"]
}
```

**Script généré (simplifié)**
```powershell
# Header et métadonnées
$Global:ScriptMetadata = @{
    ProfileName = "Minimal"
}

# Configuration embarquée
$Global:EmbeddedConfig = @'
{
  "apps": {"master": [], "profile": []},
  "modules": ["debloat"]
}
'@ | ConvertFrom-Json

# Fonctions utilitaires
function Write-ScriptLog { ... }
function Test-IsAdministrator { ... }

# Module Debloat-Windows (code complet inline)
function Remove-BloatwareApps { ... }
function Disable-TelemetryServices { ... }
function Set-PrivacyRegistry { ... }
function Invoke-WindowsDebloat { ... }

# Orchestrateur
try {
    Test-IsAdministrator
    Invoke-WindowsDebloat
    Write-Host "Terminé !"
}
catch {
    Write-Error $_
}
```

**Taille** : ~50 KB
**Temps d'exécution** : ~5 minutes

### Exemple 2 : Profil DEV complet

**Configuration**
```json
{
  "profile_name": "DEV",
  "apps": {
    "master": [
      {"name": "Office 365", "winget": "Microsoft.Office"},
      {"name": "Teams", "winget": "Microsoft.Teams"}
    ],
    "profile": [
      {"name": "VS Code", "winget": "Microsoft.VisualStudioCode"},
      {"name": "Git", "winget": "Git.Git"},
      {"name": "Postman", "winget": "Postman.Postman"}
    ]
  },
  "modules": ["debloat", "performance", "ui"],
  "performance_options": {
    "PageFile": true,
    "PowerPlan": true
  },
  "ui_options": {
    "DarkMode": true,
    "ShowFileExtensions": true
  }
}
```

**Script généré** : Contient
- Configuration JSON embarquée (5 apps)
- 3 modules PowerShell complets (Debloat + Performance + UI)
- Orchestrateur qui exécute dans l'ordre

**Taille** : ~120 KB
**Temps d'exécution** : ~20-30 minutes (selon vitesse réseau)

### Exemple 3 : Génération .exe

**Requête API**
```bash
curl -X POST http://localhost:5000/api/generate/executable \
  -H "Content-Type: application/json" \
  -d '{
    "profile_name": "Custom",
    "apps": {...},
    "modules": ["debloat"]
  }'
```

**Processus**
1. API génère le script .ps1
2. Sauvegarde dans `generated/Script_abc123.ps1`
3. Appelle PS2EXE pour compiler
   ```powershell
   Invoke-ps2exe `
     -inputFile Script_abc123.ps1 `
     -outputFile Script_abc123.exe `
     -requireAdmin `
     -noConsole:$false `
     -title "PostBootSetup - Custom"
   ```
4. Supprime le .ps1 temporaire
5. Retourne l'URL de téléchargement du .exe

**Fichier généré**
- Nom : `PostBootSetup_Custom_abc123.exe`
- Taille : ~2-3 MB (selon modules inclus)
- Avantages :
  - Icône personnalisable
  - Pas besoin de bypass ExecutionPolicy
  - Look professionnel
  - Peut être signé numériquement

## 🛠️ Personnalisation avancée

### Ajouter un nouveau module d'optimisation

**Étape 1 : Créer le module PowerShell**

```powershell
# modules/Configure-Network.psm1

function Set-DNSServers {
    param(
        [string]$Primary = "1.1.1.1",
        [string]$Secondary = "1.0.0.1"
    )

    Write-Host "Configuration DNS: $Primary, $Secondary"

    $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

    foreach ($adapter in $adapters) {
        Set-DnsClientServerAddress `
            -InterfaceIndex $adapter.ifIndex `
            -ServerAddresses ($Primary, $Secondary)
    }

    Write-Host "✓ DNS configurés"
}

function Disable-IPv6 {
    Write-Host "Désactivation IPv6..."

    Get-NetAdapterBinding -ComponentID ms_tcpip6 |
        ForEach-Object {
            Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6
        }

    Write-Host "✓ IPv6 désactivé"
}

function Invoke-NetworkConfiguration {
    param([hashtable]$Options)

    if ($Options['DNS']) {
        Set-DNSServers -Primary $Options['DNSPrimary'] -Secondary $Options['DNSSecondary']
    }

    if ($Options['DisableIPv6']) {
        Disable-IPv6
    }

    return @{
        Success = $true
        Configured = $Options.Keys -join ", "
    }
}

Export-ModuleMember -Function 'Invoke-NetworkConfiguration'
```

**Étape 2 : Référencer dans settings.json**

```json
{
  "modules": {
    "network": {
      "name": "Configuration réseau",
      "module": "Configure-Network",
      "function": "Invoke-NetworkConfiguration",
      "description": "Configure DNS et options réseau",
      "required": false,
      "recommended": false,
      "enabled": false,
      "category": "network",
      "options": {
        "DNS": {
          "name": "Configurer DNS",
          "enabled": false,
          "value": true
        },
        "DNSPrimary": {
          "name": "DNS primaire",
          "enabled": false,
          "value": "1.1.1.1"
        },
        "DNSSecondary": {
          "name": "DNS secondaire",
          "enabled": false,
          "value": "1.0.0.1"
        },
        "DisableIPv6": {
          "name": "Désactiver IPv6",
          "enabled": false,
          "value": false
        }
      }
    }
  }
}
```

**Étape 3 : Redémarrer l'API**

```bash
docker-compose restart api
```

**Étape 4 : Utiliser le nouveau module**

```bash
curl -X POST http://localhost:5000/api/generate/script \
  -H "Content-Type: application/json" \
  -d '{
    "modules": ["debloat", "network"],
    "network_options": {
      "DNS": true,
      "DNSPrimary": "8.8.8.8",
      "DNSSecondary": "8.8.4.4",
      "DisableIPv6": true
    }
  }'
```

Le module sera automatiquement inclus dans le script généré !

## 📈 Évolutions futures possibles

### Interface web React moderne

```jsx
// Exemple de composant React pour sélection profil

function ProfileSelector() {
  const [profiles, setProfiles] = useState([]);
  const [selectedProfile, setSelectedProfile] = useState(null);

  useEffect(() => {
    fetch('http://localhost:5000/api/profiles')
      .then(res => res.json())
      .then(data => setProfiles(data.profiles));
  }, []);

  return (
    <div className="profiles-grid">
      {profiles.map(profile => (
        <ProfileCard
          key={profile.id}
          profile={profile}
          selected={selectedProfile === profile.id}
          onClick={() => setSelectedProfile(profile.id)}
        />
      ))}
    </div>
  );
}
```

### Système de templates personnalisés

Permettre à l'utilisateur de créer ses propres templates de scripts :

```json
{
  "templates": {
    "minimal": {
      "description": "Script minimal sans UI",
      "includes": ["header", "utils", "debloat"],
      "excludes": ["ui_customizations"]
    },
    "gaming": {
      "description": "Optimisé pour le gaming",
      "includes": ["debloat", "performance"],
      "extra_tweaks": [
        "disable_game_bar",
        "optimize_gpu",
        "disable_fullscreen_optimization"
      ]
    }
  }
}
```

### Analytics et télémétrie

Le script généré pourrait optionnellement remonter des statistiques :

```powershell
function Send-Telemetry {
    param($Stats)

    if ($Global:EmbeddedConfig.telemetry_enabled) {
        $payload = @{
            script_id = $Global:ScriptMetadata.ScriptID
            profile = $Global:ScriptMetadata.ProfileName
            apps_installed = $Stats.Success
            apps_failed = $Stats.Failed
            duration = $Stats.Duration
            os_version = (Get-WmiObject Win32_OperatingSystem).Version
        } | ConvertTo-Json

        Invoke-RestMethod -Uri "https://api.postbootsetup.com/telemetry" `
                          -Method POST `
                          -Body $payload `
                          -ContentType "application/json" `
                          -ErrorAction SilentlyContinue
    }
}
```

## 🎓 Ressources et apprentissage

### Pour les débutants

1. **Comprendre PowerShell**
   - Lire : [microsoft.com/powershell](https://docs.microsoft.com/powershell)
   - Tester : Ouvrir PowerShell et essayer les cmdlets de base
     ```powershell
     Get-Process
     Get-Service
     Get-WmiObject Win32_OperatingSystem
     ```

2. **Comprendre Docker**
   - Lire : [docker.com/get-started](https://www.docker.com/get-started)
   - Tester : `docker run hello-world`

3. **Comprendre les APIs REST**
   - Lire : [restfulapi.net](https://restfulapi.net/)
   - Tester : `curl http://localhost:5000/api/health`

### Pour les développeurs

1. **Architecture du code**
   - Lire : `ARCHITECTURE.md` (détails techniques)
   - Explorer : `generator/app.py` (structure de l'API)

2. **Modules PowerShell**
   - Lire : `modules/Debloat-Windows.psm1` (exemple complet)
   - Modifier : Ajouter une fonction de test

3. **Tests et debugging**
   - Lire : `test_api.sh` (exemples de tests)
   - Expérimenter : Modifier `test_config_example.json`

### Exercices pratiques

**Exercice 1 : Créer un module simple**
Objectif : Ajouter un module qui change le fond d'écran

```powershell
# modules/Set-Wallpaper.psm1

function Set-DesktopWallpaper {
    param([string]$ImagePath)

    # Télécharger l'image si URL
    if ($ImagePath -match '^https?://') {
        $tempPath = "$env:TEMP\wallpaper.jpg"
        Invoke-WebRequest -Uri $ImagePath -OutFile $tempPath
        $ImagePath = $tempPath
    }

    # Appliquer via le registre
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
                     -Name Wallpaper -Value $ImagePath

    # Rafraîchir
    rundll32.exe user32.dll, UpdatePerUserSystemParameters

    Write-Host "✓ Fond d'écran modifié"
}

function Invoke-WallpaperConfiguration {
    param([hashtable]$Options)

    if ($Options['ImageURL']) {
        Set-DesktopWallpaper -ImagePath $Options['ImageURL']
    }

    return @{Success = $true}
}

Export-ModuleMember -Function 'Invoke-WallpaperConfiguration'
```

Ajouter ensuite dans settings.json et tester !

**Exercice 2 : Créer un endpoint API personnalisé**

```python
# Dans generator/app.py

@app.route('/api/validate/config', methods=['POST'])
def validate_user_config():
    """Valide une configuration sans générer de script."""
    try:
        user_config = request.json
        is_valid, error = generator.validate_config(user_config)

        if is_valid:
            # Calculer des statistiques
            total_apps = len(user_config.get('apps', {}).get('master', [])) + \
                         len(user_config.get('apps', {}).get('profile', []))

            estimated_time = total_apps * 2  # 2 min par app en moyenne
            estimated_size = 50 + (total_apps * 10)  # KB

            return jsonify({
                'success': True,
                'valid': True,
                'stats': {
                    'total_apps': total_apps,
                    'estimated_time_minutes': estimated_time,
                    'estimated_size_kb': estimated_size
                }
            })
        else:
            return jsonify({
                'success': True,
                'valid': False,
                'error': error
            })

    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 500
```

---

## 📞 Conclusion et support

Tu disposes maintenant d'une architecture complète, modulaire et évolutive pour PostBootSetup v5.0. Tous les composants sont en place et documentés.

**Prochaine étape recommandée** : Créer l'interface web moderne en React ou Vue.js qui consommera l'API.

**Besoin d'aide ?**
- 📖 Documentation : Tous les fichiers .md
- 💬 Issues : Sur le repository Git
- 📧 Email : it@tenorsolutions.com

**Bon développement ! 🚀**
