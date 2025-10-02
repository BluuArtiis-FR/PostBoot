# 🚀 Guide Utilisateur - PostBootSetup v5.0

> Guide complet pour utiliser l'interface web de génération de scripts PostBootSetup

---

## 📋 Table des Matières

- [Introduction](#introduction)
- [Accès à l'interface](#accès-à-linterface)
- [Créer un script personnalisé](#créer-un-script-personnalisé)
- [Profils prédéfinis](#profils-prédéfinis)
- [Optimisations disponibles](#optimisations-disponibles)
- [Télécharger et exécuter](#télécharger-et-exécuter)
- [FAQ](#faq)

---

## Introduction

PostBootSetup v5.0 est un générateur de scripts PowerShell autonomes permettant d'installer et configurer automatiquement des postes Windows.

### Fonctionnement en 3 étapes

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ 1. Installation │ -> │ 2. Optimisations │ -> │ 3. Téléchargement│
│   Applications  │    │   Windows        │    │   Script .ps1   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

---

## Accès à l'interface

### URL d'accès

**Développement local:**
```
http://localhost:8080
```

**Production:**
```
https://postboot.tenorsolutions.com
```

### Compatibilité navigateur

- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Edge 90+
- ✅ Safari 14+

---

## Créer un script personnalisé

### Étape 1: Installation

1. **Sélectionner un profil** ou choisir "Personnalisé"
2. **Applications Master** (obligatoires - 11 apps)
   - Chrome
   - 7-Zip
   - Adobe Acrobat Reader
   - VLC Media Player
   - Microsoft Teams
   - Outlook (Microsoft 365)
   - Word (Microsoft 365)
   - Excel (Microsoft 365)
   - PowerPoint (Microsoft 365)
   - OneNote (Microsoft 365)
   - OneDrive

3. **Applications Profil** (selon le profil choisi)
   - DEV .NET: Visual Studio, SQL Server, Git, Postman...
   - DEV WinDev: WinDev, SQL Server Management Studio...
   - TENOR: eCarAdmin, EDI Translator, Gestion Temps
   - SI: Git, DBeaver, Wireshark, Nmap...

4. **Applications Optionnelles** (choix libre)
   - Sélectionnez parmi 40+ applications disponibles

### Étape 2: Optimisations

#### Debloat Windows (Obligatoire)

Nettoyage automatique du système:
- ✅ Suppression des applications préinstallées inutiles (Bloatware)
- ✅ Désactivation de la télémétrie Windows
- ✅ Désactivation des services inutiles
- ✅ Optimisation des paramètres de confidentialité

#### Performance (Optionnel)

Optimisations de performance:
- **Effets visuels**: Désactive animations et transparence
- **Fichier de pagination**: Configure le PageFile optimal
- **Programmes au démarrage**: Désactive programmes inutiles
- **Paramètres réseau**: Optimise TCP/IP et DNS
- **Plan d'alimentation**: Force "Performances élevées"

#### UI - Interface Utilisateur (Optionnel)

Personnalisation de l'interface:
- **Mode sombre**: Active le thème sombre Windows
- **Position barre des tâches**: Bas, Haut, Gauche, Droite
- **Extensions de fichiers**: Affiche les extensions
- **Fichiers cachés**: Affiche ou masque
- **Chemin complet**: Affiche le chemin complet dans l'Explorateur
- **Icônes bureau**: Ce PC, Corbeille, Dossier utilisateur, Réseau

### Étape 3: Diagnostic (Inclus automatiquement)

Le script généré inclut une fonctionnalité de diagnostic:
- Génère un rapport HTML après installation
- Affiche l'état système complet
- Liste les applications installées
- Détecte les problèmes éventuels

---

## Profils prédéfinis

### 💻 Développeur .NET

**Applications incluses:**
- Visual Studio 2022 Community
- SQL Server 2022 Express
- SQL Server Management Studio (SSMS)
- Git
- Postman
- Python 3.12
- Node.js LTS
- VS Code
- DBeaver

**Use cases:**
- Développement C# / .NET
- Développement web ASP.NET
- Développement API REST

---

### 🎯 Développeur WinDev

**Applications incluses:**
- WinDev (installation manuelle requise)
- SQL Server 2022 Express
- SQL Server Management Studio
- Git
- eCarAdmin
- EDI Translator
- Gestion Temps

**Use cases:**
- Développement applications métier WinDev
- Maintenance applications existantes

---

### 🏢 TENOR (Projet & Support)

**Applications incluses:**
- eCarAdmin
- EDI Translator
- Gestion Temps

**Use cases:**
- Postes projet TENOR
- Support client
- Saisie temps

---

### 🔧 SI (Admin Système)

**Applications incluses:**
- Git
- SQL Server Management Studio
- DBeaver
- Wireshark
- Nmap
- Burp Suite Community
- PuTTY
- WinSCP
- Sysinternals Suite

**Use cases:**
- Administration système
- Analyse réseau
- Sécurité & audit
- Troubleshooting

---

### ⚙️ Personnalisé

**Flexibilité totale:**
- Sélection manuelle de toutes les applications
- Configuration sur mesure des optimisations
- Adapté aux besoins spécifiques

---

## Optimisations disponibles

### Debloat Windows (Obligatoire)

| Optimisation | Description | Impact |
|--------------|-------------|--------|
| **Suppression Bloatware** | Supprime apps préinstallées inutiles | ⚠️ Élevé |
| **Télémétrie** | Désactive collecte de données Microsoft | 🟢 Moyen |
| **Services inutiles** | Désactive services non essentiels | 🟢 Moyen |
| **Confidentialité** | Configure paramètres de vie privée | 🟢 Faible |

**Applications supprimées:**
- Xbox Game Bar, Xbox Identity Provider
- Cortana
- Microsoft Solitaire Collection
- Candy Crush, Bubble Witch
- OneDrive (optionnel, à décocher si utilisé)
- Paint 3D, 3D Viewer
- Tips, Get Help, Feedback Hub

---

### Performance (Optionnel)

| Optimisation | Description | Gain estimé |
|--------------|-------------|-------------|
| **Effets visuels** | Désactive animations | +5-10% perf |
| **PageFile** | Configure fichier de pagination optimal | Variable |
| **Startup Programs** | Réduit temps démarrage | -30s boot |
| **Network** | Optimise TCP/IP, DNS | +10% réseau |
| **PowerPlan** | Force mode haute performance | +15% CPU |

---

### UI - Personnalisation (Optionnel)

| Option | Valeurs | Description |
|--------|---------|-------------|
| **Mode sombre** | Activé / Désactivé | Thème sombre Windows |
| **Position barre** | Bas / Haut / Gauche / Droite | Position taskbar |
| **Extensions** | Afficher / Masquer | Extensions de fichiers |
| **Fichiers cachés** | Afficher / Masquer | Fichiers/dossiers cachés |
| **Chemin complet** | Activé / Désactivé | Chemin dans barre titre |
| **Icônes bureau** | Sélection multiple | Ce PC, Corbeille, etc. |

---

## Télécharger et exécuter

### Téléchargement

1. Cliquez sur **"Générer le script"**
2. Le script est téléchargé: `PostBootSetup_[Profil]_[ID].ps1`
3. Taille: ~20-30 Ko (script autonome)

### Exécution

#### Sur la machine cible

1. **Copier** le script sur la machine cible
2. **Clic droit** > "Exécuter avec PowerShell" (en tant qu'Admin)
3. OU via invite de commande:

```powershell
# Exécution normale
PowerShell -ExecutionPolicy Bypass -File .\PostBootSetup_XXX.ps1

# Mode silencieux (sans interactions)
PowerShell -ExecutionPolicy Bypass -File .\PostBootSetup_XXX.ps1 -Silent

# Sans Debloat (désactiver nettoyage Windows)
PowerShell -ExecutionPolicy Bypass -File .\PostBootSetup_XXX.ps1 -NoDebloat
```

#### Paramètres disponibles

| Paramètre | Type | Description |
|-----------|------|-------------|
| `-Silent` | Switch | Mode silencieux, sans interactions |
| `-NoDebloat` | Switch | Désactive module Debloat Windows |
| `-LogPath` | String | Chemin personnalisé pour les logs |

#### Durée d'exécution

- **Installation applications**: 15-45 minutes (selon nombre d'apps)
- **Optimisations**: 2-5 minutes
- **Diagnostic**: 1-2 minutes

**Total estimé**: 20-50 minutes

---

## FAQ

### Le script nécessite-t-il une connexion Internet?

✅ **Oui**, les applications sont téléchargées via Winget depuis les dépôts Microsoft.

### Puis-je exécuter le script hors ligne?

❌ **Non**, les téléchargements d'applications nécessitent Internet. Seules les optimisations peuvent fonctionner hors ligne.

### Le script peut-il endommager Windows?

🟢 **Non**, toutes les modifications sont réversibles. Le script crée un point de restauration avant de commencer.

### Que faire si une application échoue?

Le script continue avec les applications suivantes. Consultez le fichier log:
```
C:\Users\[User]\AppData\Local\Temp\PostBootSetup_YYYYMMDD_HHMMSS.log
```

### Comment annuler les optimisations?

- **Debloat**: Réinstaller les apps via Microsoft Store
- **Performance**: Restaurer le point de restauration
- **UI**: Modifier manuellement les paramètres Windows

### Le script fonctionne-t-il sur Windows 11?

✅ **Oui**, compatible Windows 10 (1809+) et Windows 11.

### Puis-je personnaliser le catalogue d'applications?

✅ **Oui** pour les administrateurs, en éditant `config/apps.json` sur le serveur.

### Les scripts générés expirent-ils?

❌ **Non**, les scripts sont autonomes et valables indéfiniment.

### Comment obtenir de l'aide?

- **Email**: si@tenorsolutions.com
- **Documentation**: `\\tenor.local\data\Déploiement\SI\PostBootSetup\`
- **GitHub**: https://github.com/BluuArtiis-FR/PostBoot/issues

---

## Liens utiles

- [🏠 Retour README](../README.md)
- [💻 Guide Développeur](DEVELOPER.md)
- [🔌 Documentation API](API.md)
- [🆘 Dépannage](../AIDE.md)

---

**© 2025 Tenor Data Solutions** - Guide Utilisateur PostBootSetup v5.0
