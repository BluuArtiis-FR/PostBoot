# PostBootSetup v5.2 - Profils et Optimisations

## 📋 Vue d'ensemble

Ce document détaille **exactement** ce qui est proposé par chaque profil et toutes les optimisations disponibles.

---

## 📦 Applications Master (Obligatoires pour tous)

Ces 12 applications sont **précochées automatiquement** dans tous les profils (sauf Custom) :

| Application | Taille | Catégorie | Description |
|-------------|--------|-----------|-------------|
| **Microsoft Office 365** | 3 GB | Bureautique | Suite bureautique complète (Word, Excel, PowerPoint, Outlook, OneDrive) |
| **Microsoft Teams** | 150 MB | Communication | Plateforme collaboration et visioconférence |
| **Notepad++** | 8 MB | Éditeur | Éditeur de texte avancé avec coloration syntaxique |
| **Visual Studio Code** | 85 MB | Éditeur | Éditeur de code Microsoft, extensible via plugins |
| **Flameshot** | 5 MB | Capture | Outil de capture d'écran et annotation |
| **VPN Stormshield** | 40 MB | VPN | Client VPN connexion sécurisée (2 VPN: Lyon + Paris) |
| **Microsoft PowerToys** | 25 MB | Utilitaires | Ensemble d'outils système (FancyZones, PowerRename, etc.) |
| **PDF Gear** | 150 MB | PDF | Lecteur et éditeur PDF gratuit |
| **Winget** | 5 MB | Gestionnaire | Gestionnaire de paquets Windows (App Installer) |
| **7-Zip** | 2 MB | Compression | Logiciel de compression/décompression archives |
| **VAULT** | <1 MB | PWA | Progressive Web App - Tenor Password Manager |
| **DOCS** | <1 MB | PWA | Progressive Web App - Tenor Documentation |

**Total Master** : ~3.5 GB (OneDrive Entreprise inclus dans Office 365)

---

## 👨‍💻 Profil DEV .NET (Développeur .NET)

### Applications incluses (4)

| Application | Taille | Description |
|-------------|--------|-------------|
| **Git** | 45 MB | Système de contrôle de version distribué |
| **SQL Server Management Studio** | 600 MB | Outil d'administration bases de données SQL Server |
| **DBeaver** | 110 MB | Client SQL universel (MySQL, PostgreSQL, Oracle, etc.) |
| **Postman** | 180 MB | Plateforme tests API REST |

**Total DEV .NET** : ~935 MB

### Cas d'usage
- Développement d'applications .NET (C#, ASP.NET)
- Administration bases de données SQL Server
- Gestion versions avec Git
- Tests d'APIs REST

---

## 👨‍💻 Profil DEV WinDev (Développeur WinDev)

### Applications incluses (5)

| Application | Taille | Description |
|-------------|--------|-------------|
| **Git** | 45 MB | Système de contrôle de version distribué |
| **SQL Server Management Studio** | 600 MB | Outil d'administration bases de données SQL Server |
| **DBeaver** | 110 MB | Client SQL universel (MySQL, PostgreSQL, Oracle, etc.) |
| **Postman** | 180 MB | Plateforme tests API REST |
| **WinSCP** | 10 MB | Client SFTP/FTP/SCP pour transfert fichiers sécurisé |

**Total DEV WinDev** : ~945 MB

### Cas d'usage
- Développement d'applications WinDev/WebDev/WinDev Mobile
- Administration bases de données HFSQL et SQL Server
- Transfert SFTP/FTP sécurisé vers serveurs de production
- Tests d'APIs et webservices

---

## 🎧 Profil TENOR (Projet & Support & Commerce)

### Applications incluses (5)

| Application | Taille | Description |
|-------------|--------|-------------|
| **eCarAdmin** | 50 MB | Outil spécifique Tenor pour gestion eCarAdmin |
| **EDI Translator** | 30 MB | Traducteur EDI pour échanges de données clients |
| **TeamViewer** | 45 MB | Prise de contrôle à distance pour support client |
| **Java JRE** | 70 MB | Environnement d'exécution Java (requis pour apps métier) |
| **Gestion Temps** | 40 MB | Application de gestion du temps de travail Tenor |

**Total TENOR** : ~235 MB

### Cas d'usage
- Support technique client
- Assistance à distance
- Utilisation applications métier Tenor
- Gestion projets clients
- Suivi temps de travail

---

## 🖥️ Profil SI (Système d'Information)

### Applications incluses (13)

| Application | Taille | Description |
|-------------|--------|-------------|
| **Wireshark** | 65 MB | Analyseur de protocoles réseau pour diagnostic |
| **Nmap** | 25 MB | Scanner de ports et audit sécurité réseau |
| **Docker Desktop** | 500 MB | Plateforme de containerisation pour déploiements |
| **PowerShell Core** | 100 MB | PowerShell multi-plateforme (version 7+) |
| **Python 3.12** | 25 MB | Langage de programmation pour scripts automation |
| **HashiCorp Terraform** | 50 MB | Infrastructure as Code (IaC) |
| **Advanced IP Scanner** | 15 MB | Scanner réseau rapide |
| **Fortinet VPN Client** | 25 MB | Client VPN Fortinet |
| **AWS CLI** | 40 MB | Interface ligne de commande Amazon Web Services |
| **RSAT Active Directory** | 20 MB | Outils d'administration Active Directory |
| **RSAT DNS** | 10 MB | Outils d'administration DNS |
| **RSAT Group Policy** | 15 MB | Outils d'administration GPO |
| **RSAT DHCP** | 10 MB | Outils d'administration DHCP |

**Total SI** : ~900 MB

### Cas d'usage
- Administration système et réseau
- Analyse trafic réseau et sécurité
- Développement scripts d'automatisation
- Gestion infrastructure Docker et cloud
- Administration Active Directory
- Déploiement infrastructure as code

---

## 🎁 Applications optionnelles (Disponibles pour tous)

Ces applications peuvent être ajoutées à **n'importe quel profil** :

| Application | Taille | Description |
|-------------|--------|-------------|
| **VLC Media Player** | 40 MB | Lecteur multimédia universel |
| **Firefox** | 60 MB | Navigateur web alternatif à Edge |
| **Google Chrome** | 80 MB | Navigateur web Google |
| **PeaZip** | 10 MB | Gestionnaire d'archives alternatif à 7-Zip |

---

## ⚡ Module 1 : Debloat Windows (OBLIGATOIRE)

Ce module est **toujours activé** et ne peut pas être désactivé.

### Actions effectuées

#### 🗑️ Suppression bloatware
Supprime les applications Windows préinstallées inutiles :
- Xbox et Xbox Game Bar
- Candy Crush et autres jeux
- Skype (préinstallé)
- OneDrive personnel (entreprise conservé)
- Get Help / Tips / Your Phone
- 3D Viewer, Paint 3D
- Weather, Maps, News
- Microsoft Solitaire Collection

**Gain espace** : ~2-5 GB

#### 📡 Désactivation télémétrie
- Télémétrie Microsoft (niveau 0)
- Rapports d'erreurs Windows
- Feedback et diagnostics
- Cortana (assistant vocal)
- Historique des activités
- Timeline Windows

#### 🔒 Optimisation confidentialité
Modifie les registres pour :
- Désactiver tracking localisation
- Bloquer publicités ciblées
- Désactiver suggestions dans le menu Démarrer
- Supprimer collecte données d'utilisation

#### 🛠️ Services désactivés
- DiagTrack (télémétrie)
- dmwappushservice (messages WAP)
- RetailDemo (mode démo)
- XblAuthManager, XblGameSave, XboxNetApiSvc (services Xbox)

**Impact performance** : Amélioration démarrage ~10-15%

---

## ⚡ Module 2 : Optimisations Performance (RECOMMANDÉ)

Ce module est **optionnel** mais **fortement recommandé**.

### Option 1 : Optimiser fichier d'échange ⭐ RECOMMANDÉ

**Ce que ça fait** :
- Configure le pagefile (fichier d'échange mémoire virtuelle)
- Définit une taille fixe = taille RAM (ex: 16 GB RAM = 16 GB pagefile)
- Évite la fragmentation du pagefile

**Bénéfices** :
- ✅ Performances mémoire améliorées de 5-10%
- ✅ Moins de ralentissements quand RAM saturée
- ✅ Meilleure gestion multitâche

**Impact disque** : Utilise l'équivalent de votre RAM en espace disque

---

### Option 2 : Plan d'alimentation haute performance ⭐ RECOMMANDÉ

**Ce que ça fait** :
- Active le plan "Performances élevées" de Windows
- Désactive mise en veille processeur
- Maximise fréquence CPU en permanence

**Bénéfices** :
- ✅ Réactivité système immédiate
- ✅ Pas de latence lors de tâches intensives
- ✅ Performances CPU maximales

**Inconvénient** : Consommation électrique légèrement supérieure (~5-10W)

---

### Option 3 : Désactiver programmes au démarrage ⭐ RECOMMANDÉ

**Ce que ça fait** :
- Analyse les programmes configurés pour démarrer automatiquement
- Désactive ceux qui ne sont pas essentiels :
  - OneDrive (si déjà supprimé)
  - Skype
  - Adobe updaters
  - Spotify, Discord (si présents)
  - Applications en arrière-plan

**Bénéfices** :
- ✅ Temps de boot réduit de 20-40%
- ✅ Moins de RAM utilisée au démarrage
- ✅ Système plus réactif après ouverture de session

---

### Option 4 : Optimiser paramètres réseau

**Ce que ça fait** :
- Désactive QoS (Quality of Service packet scheduler)
- Optimise taille buffer TCP/IP
- Désactive NetBIOS sur TCP/IP
- Ajuste paramètres DNS

**Bénéfices** :
- ✅ Latence réseau réduite (~5-15ms)
- ✅ Débit amélioré pour grandes transferts
- ✅ Moins de overhead protocole

**Recommandé pour** : Serveurs, postes gaming, travail réseau intensif

---

### Option 5 : Désactiver effets visuels

**Ce que ça fait** :
- Désactive animations fenêtres
- Supprime transparence Aero
- Désactive ombres portées
- Simplifie barres de tâches et menus

**Bénéfices** :
- ✅ Performances graphiques améliorées de 10-20%
- ✅ Idéal pour machines avec GPU faible
- ✅ Interface plus réactive

**Inconvénient** : Interface visuellement moins moderne

---

## 🎨 Module 3 : Personnalisation Interface (OPTIONNEL)

Ce module est **complètement optionnel** et concerne uniquement l'apparence.

### Option 1 : Mode sombre

**Ce que ça fait** :
- Active le thème sombre système Windows
- Applications modernes utilisent le mode sombre
- Barre des tâches, Explorateur, Paramètres en sombre

**Bénéfices** :
- ✅ Réduction fatigue oculaire
- ✅ Meilleur contraste en faible luminosité
- ✅ Économie batterie sur écrans OLED

---

### Option 2 : Afficher extensions fichiers

**Ce que ça fait** :
- Affiche `.txt`, `.exe`, `.pdf`, etc. dans l'Explorateur
- Supprime le masquage par défaut de Windows

**Bénéfices** :
- ✅ Sécurité accrue (détection virus type `facture.pdf.exe`)
- ✅ Meilleure compréhension types de fichiers
- ✅ Recommandé pour utilisateurs techniques

---

### Option 3 : Afficher chemin complet

**Ce que ça fait** :
- Affiche le chemin complet dans la barre d'adresse de l'Explorateur
- Ex: `C:\Users\nom\Documents\Projets` au lieu de `Projets`

**Bénéfices** :
- ✅ Navigation plus rapide
- ✅ Copier/coller chemins facilité
- ✅ Utile pour développeurs et administrateurs

---

### Option 4 : Afficher fichiers cachés

**Ce que ça fait** :
- Révèle les fichiers/dossiers système cachés
- Affiche fichiers `.htaccess`, `thumbs.db`, etc.

**Bénéfices** :
- ✅ Accès complet au système de fichiers
- ✅ Utile pour dépannage avancé

**Attention** : Risque de suppression accidentelle fichiers système

---

### Option 5 : Icônes bureau (Ce PC, Corbeille)

**Ce que ça fait** :
- Affiche l'icône "Ce PC" sur le bureau
- Affiche l'icône "Corbeille" sur le bureau

**Bénéfices** :
- ✅ Accès rapide aux disques
- ✅ Gestion corbeille simplifiée

---

### Option 6 : Redémarrer explorateur

**Ce que ça fait** :
- Redémarre `explorer.exe` après application des changements UI
- Force la prise en compte immédiate des modifications

**Recommandé** : Toujours activer si vous utilisez le module UI

---

## 📊 Récapitulatif par profil

### Configuration DEV .NET complète

| Composant | Contenu |
|-----------|---------|
| **Applications Master** | Office, Teams, Notepad++, VS Code, Greenshot, VPN, PowerToys, PDF Gear, Winget, OneDrive |
| **Applications DEV .NET** | Git, SSMS, DBeaver, Postman |
| **Total apps** | 14 applications |
| **Taille totale** | ~4.5 GB |
| **Debloat** | ✅ Toujours activé |
| **Performance** | ⭐ Recommandé (PageFile, PowerPlan, Startup) |
| **UI** | ⚪ Optionnel |

---

### Configuration DEV WinDev complète

| Composant | Contenu |
|-----------|---------|
| **Applications Master** | Office, Teams, Notepad++, VS Code, Greenshot, VPN, PowerToys, PDF Gear, Winget, OneDrive |
| **Applications DEV WinDev** | Git, SSMS, DBeaver, Postman, FileZilla |
| **Total apps** | 15 applications |
| **Taille totale** | ~4.6 GB |
| **Debloat** | ✅ Toujours activé |
| **Performance** | ⭐ Recommandé (PageFile, PowerPlan, Startup) |
| **UI** | ⚪ Optionnel |

---

### Configuration TENOR complète

| Composant | Contenu |
|-----------|---------|
| **Applications Master** | Office, Teams, Notepad++, VS Code, Greenshot, VPN, PowerToys, PDF Gear, Winget, OneDrive |
| **Applications TENOR** | eCarAdmin, EDI Translator, TeamViewer, Java JRE, Gestion Temps |
| **Total apps** | 15 applications |
| **Taille totale** | ~3.8 GB |
| **Debloat** | ✅ Toujours activé |
| **Performance** | ⭐ Recommandé (PageFile, PowerPlan, Startup) |
| **UI** | ⚪ Optionnel |

---

### Configuration SI complète

| Composant | Contenu |
|-----------|---------|
| **Applications Master** | Office, Teams, Notepad++, VS Code, Greenshot, VPN, PowerToys, PDF Gear, Winget, OneDrive |
| **Applications SI** | Wireshark, Nmap, Docker, PowerShell Core, Python, Terraform, IP Scanner, Fortinet VPN, AWS CLI, RSAT (AD, DNS, GPO, DHCP) |
| **Total apps** | 23 applications |
| **Taille totale** | ~4.5 GB |
| **Debloat** | ✅ Toujours activé |
| **Performance** | ⭐ Recommandé (toutes options) |
| **UI** | ⭐ Recommandé (afficher extensions, chemin complet) |

---

## 🎯 Recommandations par type d'utilisateur

### Utilisateur bureautique / Support client
- **Profil** : TENOR
- **Performance** : PageFile + Startup uniquement
- **UI** : Mode sombre si souhaité

### Développeur .NET
- **Profil** : DEV .NET
- **Performance** : Toutes options sauf VisualEffects
- **UI** : Extensions + Chemin complet obligatoires

### Développeur WinDev
- **Profil** : DEV WinDev
- **Performance** : Toutes options sauf VisualEffects
- **UI** : Extensions + Chemin complet obligatoires

### Administrateur système
- **Profil** : SI
- **Performance** : Toutes options activées
- **UI** : Extensions + Chemin complet + Fichiers cachés

---

## 💾 Gain d'espace disque estimé

| Action | Gain |
|--------|------|
| Debloat (suppression apps) | 2-5 GB |
| Désactivation hibernation | 4-16 GB (= taille RAM) |
| Nettoyage fichiers temp | 0.5-2 GB |
| **Total possible** | **6.5-23 GB** |

---

## ⏱️ Temps d'installation estimé

| Configuration | Temps | Détails |
|--------------|-------|---------|
| **Debloat uniquement** | 5-10 min | Suppression bloatware + télémétrie |
| **+ Performance** | 10-15 min | + optimisations système |
| **+ Applications Master** | 30-40 min | + installation 10 apps (Office = 3 GB) |
| **+ Profil DEV .NET** | 45-55 min | + installation 4 apps supplémentaires |
| **+ Profil DEV WinDev** | 45-55 min | + installation 5 apps supplémentaires |
| **+ Profil TENOR** | 35-45 min | + installation 5 apps supplémentaires |
| **+ Profil SI** | 50-70 min | + installation 13 apps (Docker + RSAT longs) |

**Facteurs influençant** : Vitesse Internet, performances PC, nombre d'apps

---

## 🔧 Modification des profils

Tu peux facilement **personnaliser** les profils en éditant :

### Ajouter/retirer applications
Éditer `config/apps.json` :

```json
{
  "profiles": {
    "DEV_DOTNET": {
      "apps": [
        {
          "name": "Nouvelle App",
          "winget": "Publisher.AppName",
          "size": "100 MB"
        }
      ]
    }
  }
}
```

### Modifier optimisations
Éditer `config/settings.json` :

```json
{
  "modules": {
    "performance": {
      "options": {
        "NouvellOption": {
          "name": "Nom affiché",
          "description": "Ce que ça fait",
          "enabled": true,
          "recommended": true
        }
      }
    }
  }
}
```

**Après modification** : Redémarrer Docker avec `docker-compose restart`

---

## 📞 Questions fréquentes

**Q : Puis-je désactiver le Debloat ?**
R : Non, c'est obligatoire car il corrige des problèmes de confidentialité et libère beaucoup d'espace.

**Q : Les optimisations Performance ralentissent-elles le PC ?**
R : Au contraire ! Elles accélèrent le système. Seule exception : "Haute performance" consomme plus d'électricité.

**Q : Puis-je avoir DEV .NET + SI ensemble ?**
R : Oui ! En mode "Configuration personnalisée", coche les apps des deux profils.

**Q : Que se passe-t-il si une app n'est pas disponible via Winget ?**
R : Le script continue et note l'erreur dans les logs. Les autres apps s'installent normalement.

**Q : Puis-je réexécuter le script plusieurs fois ?**
R : Oui, le script est idempotent. Il détecte les apps déjà installées et les saute.

**Q : Quelle est la différence entre SUPPORT et TENOR ?**
R : "SUPPORT" a été renommé en "TENOR" pour refléter les équipes Projet, Support et Commerce qui utilisent les mêmes outils métier Tenor.

---

© 2025 Tenor Data Solutions - Configuration PostBootSetup v5.2
