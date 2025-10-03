# 🔧 Dépannage - PostBootSetup v5.0

> Solutions aux problèmes courants rencontrés lors de l'utilisation de PostBootSetup

---

## 📋 Table des Matières

- [Installation d'applications](#installation-dapplications)
- [VPN Stormshield](#vpn-stormshield)
- [Modules d'optimisation](#modules-doptimisation)
- [Script PowerShell](#script-powershell)
- [Docker & API](#docker--api)

---

## Installation d'applications

### ❌ Une application échoue à s'installer

**Symptômes:**
- Message "✗ Erreur [AppName]: ..."
- L'application n'apparaît pas après le script

**Solutions:**

1. **Vérifier les logs**
   ```powershell
   # Ouvrir le fichier log (chemin affiché en fin de script)
   notepad $env:TEMP\PostBootSetup_*.log
   ```

2. **Installation manuelle**
   - Le log indique l'URL ou l'ID Winget de l'application
   - Installer manuellement avec Winget:
   ```powershell
   winget install --id <AppID> -e
   ```

3. **Connexion Internet**
   - Vérifier que la machine a accès à Internet
   - Vérifier les proxys/pare-feu
   - Tester: `Test-NetConnection google.com -Port 443`

---

## VPN Stormshield

### ❌ Le VPN Stormshield ne s'installe pas automatiquement

**Symptômes:**
```
✗ Erreur VPN Stormshield: certificat SSL invalide
→ Installation manuelle requise: https://vpn.stormshield.eu/
```

**Cause:**
- Problème de certificat SSL sur le serveur de téléchargement
- Version du client VPN obsolète dans la configuration

**Solution automatique (implémentée):**

Le script tente maintenant 2 méthodes:
1. WebClient avec TLS 1.2
2. Invoke-WebRequest en fallback

**Solution manuelle:**

1. **Télécharger manuellement**
   - Aller sur https://vpn.stormshield.eu/
   - Télécharger "Installer FR (msi)" version Windows x64
   - Sauvegarder le fichier

2. **Installer**
   ```powershell
   # En tant qu'administrateur
   msiexec /i "Stormshield_SSLVPN_Client_x.x.x_fr_x64.msi" /qn /norestart
   ```

3. **Mettre à jour la configuration** (pour les admins)
   - Éditer `config/apps.json`
   - Mettre à jour l'URL avec la dernière version:
   ```json
   {
     "name": "VPN Stormshield",
     "url": "https://vpn.stormshield.eu/download/Stormshield_SSLVPN_Client_X.X.X_fr_x64.msi",
     ...
   }
   ```

**Vérification:**
```powershell
# Vérifier l'installation
Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Stormshield*" }
```

---

## Modules d'optimisation

### ❌ Les modules Performance/UI ne sont pas appliqués

**Symptômes:**
- Le script se termine mais les optimisations ne sont pas visibles
- Aucun message d'erreur

**Causes possibles:**

1. **Modules désactivés dans la configuration**
   - Vérifier dans l'interface web que les modules sont cochés
   - Regarder la ligne "Modules activés:" dans le header du script généré

2. **Paramètre -NoDebloat utilisé**
   ```powershell
   # Ne PAS utiliser -NoDebloat si vous voulez les optimisations
   .\PostBootSetup.ps1          # ✅ Correct
   .\PostBootSetup.ps1 -NoDebloat  # ❌ Skip optimisations
   ```

**Vérification:**
```powershell
# Ouvrir le script et chercher
Get-Content .\PostBootSetup.ps1 | Select-String "region Module"

# Devrait afficher:
# #region Module Debloat-Windows
# #region Module Optimize-Performance
# #region Module Customize-UI
```

---

## Script PowerShell

### ❌ Erreur "Les scripts sont désactivés sur ce système"

**Message complet:**
```
.\PostBootSetup.ps1 : Impossible de charger le fichier car l'exécution de scripts
est désactivée sur ce système.
```

**Solution:**
```powershell
# Méthode 1: Bypass pour cette exécution (recommandé)
PowerShell -ExecutionPolicy Bypass -File .\PostBootSetup.ps1

# Méthode 2: Changer la politique (en tant qu'admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### ❌ Erreur de syntaxe PowerShell

**Symptômes:**
```
Jeton inattendu '??' dans l'expression
```

**Cause:**
- Version de PowerShell trop ancienne (< 5.1)
- Script généré avant le fix de compatibilité

**Solution:**
1. **Vérifier la version PowerShell**
   ```powershell
   $PSVersionTable.PSVersion
   # Doit être >= 5.1
   ```

2. **Régénérer le script**
   - Les scripts générés après le 02/10/2025 sont compatibles PowerShell 5.1+
   - Supprimer l'ancien script et en générer un nouveau

### ❌ Erreur Export-ModuleMember

**Symptômes:**
```
Ligne XXX: Jeton inattendu ')' dans l'expression
```

**Cause:**
- Script généré avant le fix Export-ModuleMember (avant 02/10/2025)

**Solution:**
- Régénérer un nouveau script depuis l'interface web
- Les nouveaux scripts ont le fix appliqué

---

## Docker & API

### ❌ L'API ne démarre pas

**Vérification:**
```bash
# Statut des conteneurs
docker ps

# Logs API
docker logs postboot-generator-api --tail 50

# Logs Web
docker logs postboot-web --tail 50
```

**Solutions courantes:**

1. **Port déjà utilisé**
   ```bash
   # Windows: Trouver le processus sur le port 5000
   netstat -ano | findstr :5000

   # Changer le port dans docker-compose.yml
   ports:
     - "5001:5000"  # Au lieu de 5000:5000
   ```

2. **Rebuild nécessaire**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

### ❌ L'interface web affiche "Cannot connect to API"

**Vérifications:**

1. **API accessible?**
   ```bash
   curl http://localhost:5000/api/health
   # Doit retourner: {"status":"healthy"}
   ```

2. **Proxy/Firewall**
   - Vérifier que les ports 5000 et 8080 ne sont pas bloqués
   - Désactiver temporairement l'antivirus

3. **URL de l'API**
   - Développement: `http://localhost:5000`
   - Production: Vérifier `web/.env` pour `VITE_API_URL`

---

## Problèmes spécifiques aux applications

### Microsoft Office 365

**Note:** Office nécessite une licence Microsoft 365.

L'installation via Winget installe Office mais **ne l'active pas**.

**Activation:**
1. Ouvrir Word/Excel
2. Se connecter avec un compte Microsoft 365
3. Entrer la clé de produit si nécessaire

### SQL Server Management Studio (SSMS)

**Problème:** Installation très longue (5-10 minutes)

**Solution:** Patienter, c'est normal. Le script attend la fin de l'installation.

### Applications métier (eCarAdmin, EDI, etc.)

**Note:** Ces applications nécessitent:
- Accès au réseau interne Tenor (`http://85.90.48.117`)
- Configuration post-installation manuelle
- Parfois une base de données locale

---

## Obtenir de l'aide

### Collecte d'informations

Avant de demander de l'aide, préparer:

1. **Fichier log complet**
   ```powershell
   # Copier le log
   Get-Content $env:TEMP\PostBootSetup_*.log | Out-File rapport_erreur.txt
   ```

2. **Version du script**
   ```powershell
   # Afficher la version
   Get-Content .\PostBootSetup.ps1 | Select-String "Version|GeneratedDate" | Select-Object -First 5
   ```

3. **Environnement**
   ```powershell
   # Informations système
   Get-ComputerInfo | Select-Object WindowsVersion, OsArchitecture
   $PSVersionTable.PSVersion
   ```

### Contacts

- **Email Support**: [si@tenorsolutions.com](mailto:si@tenorsolutions.com)
- **GitHub Issues**: [Créer un ticket](https://github.com/BluuArtiis-FR/PostBoot/issues)
- **Documentation**: `\\tenor.local\data\Déploiement\SI\PostBootSetup\`

---

## Liens utiles

- [🏠 README Principal](../README.md)
- [🚀 Guide Utilisateur](USER_GUIDE.md)
- [💻 Guide Développeur](DEVELOPER.md)
- [🔌 Documentation API](API.md)

---

**© 2025 Tenor Data Solutions** - Guide de Dépannage PostBootSetup v5.0
