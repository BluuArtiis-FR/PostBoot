# 📖 Aide PostBootSetup v5.0

Guide d'utilisation de PostBootSetup - Générateur de scripts d'installation Windows

---

## 🎯 Qu'est-ce que PostBootSetup ?

PostBootSetup est un générateur de scripts PowerShell qui vous permet de créer des scripts personnalisés pour :
- **Installer automatiquement** des applications Windows via Winget
- **Optimiser Windows** (suppression de bloatware, performances, personnalisation)
- **Générer un diagnostic** complet de votre système

---

## 🚀 Guide Rapide (5 minutes)

### 1. Accéder à l'application
Ouvrir https://postboot.tenorsolutions.com dans votre navigateur

### 2. Choisir un espace
Trois espaces sont disponibles sur la page d'accueil :
- **Installation** : Sélectionner les applications à installer
- **Optimisations** : Configurer les optimisations Windows
- **Diagnostic** : Configurer le diagnostic système

### 3. Configurer l'installation
1. Sélectionner un **profil** (ou "Personnalisé" pour tout choisir)
2. Cocher les **applications** souhaitées
3. Cliquer sur **"Continuer"**

### 4. Configurer les optimisations
1. Activer/désactiver **Performance** et **UI**
2. Cocher les options souhaitées
3. Cliquer sur **"Continuer"**

### 5. Générer le script
1. Sélectionner les **modules** à inclure (Installation, Optimisations, Diagnostic)
2. Cliquer sur **"Générer le script"**
3. Le fichier `.ps1` se télécharge automatiquement

### 6. Exécuter le script
```powershell
# Sur le PC Windows cible
# Clic droit sur le fichier .ps1 → "Exécuter avec PowerShell"
# OU en ligne de commande :
PowerShell -ExecutionPolicy Bypass -File .\PostBootSetup_*.ps1
```

---

## 📋 Les Profils

### Profils Prédéfinis

#### 🔵 DEV .NET
Pour les développeurs .NET
- Visual Studio 2022
- SQL Server Express
- Git, Postman, DBeaver
- Python, Node.js

#### 🟣 DEV WinDev
Pour les développeurs WinDev
- WinDev (lien custom)
- SQL Server Express
- Git, eCarAdmin, EDI Translator

#### 🟠 TENOR
Pour l'équipe Projet & Support
- eCarAdmin
- EDI Translator
- Gestion Temps

#### 🟢 SI
Pour les administrateurs système
- Git, SSMS, DBeaver
- Wireshark, Nmap
- Burp Suite Community

#### ⚪ Personnalisé
Sélectionner manuellement parmi toutes les applications disponibles (40+)

---

## ⚙️ Les Modules d'Optimisation

### 🧹 Debloat Windows (Obligatoire)
Supprime automatiquement :
- Applications préinstallées inutiles (Candy Crush, Xbox, etc.)
- Bloatware Microsoft
- Telemetry excessive
- Cortana et suggestions

### ⚡ Performance (Optionnel)
- **PageFile** : Configuration du fichier d'échange
- **PowerPlan** : Mode haute performance
- **StartupPrograms** : Désactivation programmes au démarrage
- **Network** : Optimisation TCP/IP
- **VisualEffects** : Désactivation effets visuels

### 🎨 UI (Optionnel)
- **Dark Mode** : Mode sombre Windows
- **Afficher extensions** : Extensions de fichiers visibles
- **Afficher chemin complet** : Dans l'explorateur
- **Afficher fichiers cachés**
- **Ce PC au démarrage** : Au lieu de "Accès rapide"
- **Position de la barre des tâches**

---

## 🔧 Applications Master (Obligatoires)

Ces 11 applications sont installées automatiquement dans tous les profils :
1. Microsoft Office 365
2. Google Chrome
3. Mozilla Firefox
4. Adobe Acrobat Reader
5. VLC Media Player
6. WinRAR
7. 7-Zip
8. Notepad++
9. TeamViewer
10. AnyDesk
11. Microsoft Teams

---

## 📦 Génération du Script

### Types de scripts générables

#### Script Complet
Inclut Installation + Optimisations + Diagnostic (recommandé)

#### Script Installation Seul
Uniquement l'installation d'applications

#### Script Optimisations Seul
Uniquement les optimisations Windows (sans installation)

#### Script Diagnostic Seul
Uniquement le diagnostic système

### Format du script
- **Nom** : `PostBootSetup_[Type]_[ID].ps1`
- **Taille** : Variable selon les apps (50 MB - 10 GB)
- **Format** : PowerShell autonome (pas de dépendances)

---

## 💡 Conseils d'Utilisation

### Avant de générer
✅ Vérifier la **taille totale** affichée
✅ S'assurer d'avoir une **connexion Internet** stable
✅ Prévoir **suffisamment d'espace disque**

### Lors de l'exécution
✅ Exécuter en tant qu'**Administrateur**
✅ Ne pas interrompre le script
✅ Surveiller les logs dans la console PowerShell

### Après l'exécution
✅ Redémarrer le PC si demandé
✅ Vérifier les logs dans `C:\PostBootSetup\logs\`
✅ Valider que les applications sont installées

---

## ❓ FAQ

### Q : Combien de temps prend l'exécution ?
**R** : Entre 15 minutes et 2 heures selon le nombre d'applications et la connexion Internet.

### Q : Puis-je exécuter le script plusieurs fois ?
**R** : Oui, le script détecte les applications déjà installées et les ignore.

### Q : Que faire si une installation échoue ?
**R** : Le script continue avec les applications suivantes. Consultez les logs pour identifier l'erreur.

### Q : Les optimisations sont-elles réversibles ?
**R** : La plupart oui, via les paramètres Windows. Le Debloat est plus difficile à annuler.

### Q : Puis-je ajouter mes propres applications ?
**R** : Contactez l'équipe SI pour ajouter des applications au catalogue.

### Q : Le script fonctionne sur quelle version de Windows ?
**R** : Windows 10 (1809+) et Windows 11

### Q : Winget doit-il être installé ?
**R** : Non, le script l'installe automatiquement si absent.

### Q : Puis-je utiliser le script hors ligne ?
**R** : Non, une connexion Internet est requise pour télécharger les applications.

---

## 🆘 Problèmes Courants

### Le script ne démarre pas
```powershell
# Solution : Autoriser l'exécution
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

### "Winget n'est pas reconnu"
Le script installe Winget automatiquement. Patienter quelques secondes.

### Une application ne s'installe pas
Vérifier :
- Connexion Internet active
- Espace disque suffisant
- Antivirus ne bloque pas Winget
- Consulter les logs : `C:\PostBootSetup\logs\`

### Erreur "Accès refusé"
Exécuter PowerShell en tant qu'**Administrateur**

---

## 📞 Support

### Documentation
- [README.md](README.md) - Vue d'ensemble
- [CHANGELOG.md](CHANGELOG.md) - Historique des versions
- [DEPLOIEMENT_DEBIAN12.md](DEPLOIEMENT_DEBIAN12.md) - Déploiement serveur

### Contact
- **Email** : si@tenorsolutions.com
- **Issues GitHub** : https://github.com/TenorDataSolutions/PostBoot/issues
- **Documentation réseau** : `\\tenor.local\data\Déploiement\SI\PostBootSetup\`

---

## 🔄 Mises à jour

PostBootSetup est mis à jour régulièrement avec :
- Nouvelles applications
- Corrections de bugs
- Nouvelles optimisations
- Améliorations de l'interface

Consultez le [CHANGELOG.md](CHANGELOG.md) pour les dernières nouveautés.

---

## 📝 Contribuer

Vous avez une suggestion ? Une application à ajouter ?

1. Créer une **Issue** sur GitHub
2. Ou contacter : si@tenorsolutions.com

---

**PostBootSetup v5.2** - Tenor Data Solutions
© 2025 - Usage interne uniquement
