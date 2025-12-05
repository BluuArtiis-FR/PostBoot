# Profil Personnalisé - Guide d'utilisation

## Nouvelles fonctionnalités

Le profil personnalisé supporte maintenant 3 modes de fonctionnement:

### 1. Mode avec applications master précochées (par défaut)

**Comportement**: Toutes les applications master sont automatiquement incluses

```json
{
  "profile": "Custom",
  "preselect_master": true,
  "profile_apps": [],
  "optional_apps": []
}
```

**Résultat**: Installation de toutes les apps master + apps supplémentaires sélectionnées

### 2. Mode personnalisé complet (tout décocher)

**Comportement**: Partir de zéro, sélectionner uniquement les apps souhaitées

```json
{
  "profile": "Custom",
  "preselect_master": false,
  "master_apps": ["Microsoft.VisualStudioCode", "Microsoft.PowerToys"],
  "profile_apps": [],
  "optional_apps": []
}
```

**Résultat**: Seulement VS Code et PowerToys installés

### 3. Mode basé sur un profil existant

**Comportement**: Partir d'un profil standard et ajouter des apps supplémentaires

```json
{
  "profile": "Custom",
  "base_profile": "DEV_DOTNET",
  "profile_apps": [],
  "optional_apps": ["AgileBits.1Password"]
}
```

**Résultat**:
- Toutes les apps master (Office 365, Teams, Notepad++, VS Code, etc.)
- Toutes les apps du profil DEV_DOTNET (Visual Studio, SQL Server, etc.)
- 1Password en supplément

## Paramètres disponibles

| Paramètre | Type | Défaut | Description |
|-----------|------|--------|-------------|
| `profile` | string | "Custom" | Nom du profil |
| `preselect_master` | boolean | true | Précocher automatiquement les apps master |
| `base_profile` | string | null | Profil de base à utiliser (DEV_DOTNET, DEV_WINDEV, TENOR, SI) |
| `master_apps` | array | [] | Liste des IDs d'apps master à inclure manuellement |
| `profile_apps` | array | [] | Liste des IDs d'apps de profil à inclure |
| `optional_apps` | array | [] | Liste des IDs d'apps optionnelles à inclure |

## Exemples d'utilisation

### Exemple 1: Développeur avec apps de base

```json
{
  "profile": "Custom",
  "preselect_master": true,
  "optional_apps": [
    "Git.Git",
    "Postman.Postman",
    "Docker.DockerDesktop"
  ]
}
```

### Exemple 2: Utilisateur minimaliste

```json
{
  "profile": "Custom",
  "preselect_master": false,
  "master_apps": [
    "Microsoft.VisualStudioCode",
    "Microsoft.PowerToys",
    "Flameshot.Flameshot"
  ]
}
```

### Exemple 3: DEV .NET + outils data

```json
{
  "profile": "Custom",
  "base_profile": "DEV_DOTNET",
  "optional_apps": [
    "MongoDB.Compass",
    "dbeaver.dbeaver",
    "Postman.Postman"
  ]
}
```

### Exemple 4: Profil SI avec apps supplémentaires

```json
{
  "profile": "Custom",
  "base_profile": "SI",
  "optional_apps": [
    "Canonical.Ubuntu"
  ]
}
```

## Apps Master incluses par défaut

Lorsque `preselect_master` est `true` (défaut), les apps suivantes sont incluses:
- Microsoft Office 365 (Word, Excel, PowerPoint, Outlook, OneDrive)
- Microsoft Teams
- Notepad++ (avec plugins XML Tools et Compare)
- Visual Studio Code
- Flameshot (capture d'écran)
- VPN Stormshield
- Microsoft PowerToys
- PDF Gear
- VAULT (PWA)
- DOCS (PWA)

## Profils de base disponibles

| Profil | Description | Apps incluses |
|--------|-------------|---------------|
| DEV_DOTNET | Développeur .NET/C# | Visual Studio 2022, SQL Server Express, .NET SDK, etc. |
| DEV_WINDEV | Développeur WinDev | WinDev 28, HFSQL, etc. |
| TENOR | Configuration standard TENOR | Apps master + Avast Business (config TENOR) |
| SI | Service Informatique | Wireshark, Nmap, PowerShell Core, Terraform, Burp Suite, etc. |

## Notes

- Les applications master sont celles qui sont communes à tous les profils
- Le paramètre `base_profile` est additionnel: il n'empêche pas d'ajouter d'autres apps
- La déduplication est automatique: si une app est dans plusieurs sources, elle n'est incluse qu'une fois
- Le support des plugins (Notepad++) est maintenant pleinement fonctionnel même avec `customInstall`
