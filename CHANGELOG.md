# Changelog

Toutes les modifications notables de PostBootSetup seront documentées dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

---

## [5.2.0] - 2025-11-26

### ✨ Ajouté

#### Applications et Installation
- **PWA Edge natives** : Installation VAULT et DOCS via `msedge.exe --install-app=URL` avec favicons automatiques
- **VPN Stormshield 2 VPN** : Import automatique AddressBook (Lyon + Paris) via `sslvpn-cli.exe import-addressbook`
- **WinSCP** : Remplacement de FileZilla dans tous les profils
- **MSI Auto-Detection** : Détection automatique `.msi` et utilisation `msiexec.exe` avec arguments appropriés

#### Optimisations Windows 11 25H2
- **Nettoyage Build 26xxx** : Suppression épinglages menu Démarrer et barre tâches par défaut
- **CloudStore cleanup** : Nettoyage base de données StartMenuExperienceHost
- **PinnedList cleanup** : Suppression registre épinglages obsolètes
- **Information utilisateur** : Message explicite que Windows 11 25H2 bloque l'épinglage programmatique

#### Corrections et Améliorations
- **Validation fichiers** : Magic bytes check pour détecter HTML vs EXE/MSI
- **Avast arguments** : Correction `/qn` au lieu de `/silent` pour installation MSI
- **Stormshield CLI path** : Chemin corrigé v5.1.2+ (`Modules\ssl-vpn\Services\`)
- **Web Apps nommées** : VAULT (Tenor Password) et DOCS (Tenor Documentation)

### 🔄 Modifié

- **README.md** : Mise à jour complète v5.2 avec toutes les nouvelles fonctionnalités
- **GitHub URLs** : Migration `BluuArtiis-FR` → `TenorDataSolutions`
- **Master apps** : Ajout 7-Zip, VAULT et DOCS aux 13 applications obligatoires
- **Customize-UI module** : Simplification `Set-CustomPinnedApps` (cleanup-only sur Win11 25H2)

### 🗑️ Supprimé

- **Fichiers de test** : Suppression de tous les scripts de test et diagnostic temporaires
- **Favicon handling manuel** : Supprimé au profit du système PWA natif Edge

---

## [5.0.0] - 2025-10-02

### 🎉 Refonte Majeure - Architecture 3 Espaces

Version majeure avec refonte complète de l'interface et de l'architecture.

### ✨ Ajouté

#### Interface Web Moderne
- **Architecture 3 espaces** : Installation, Optimisations, Diagnostic
- **Page d'accueil** avec 3 cartes principales pour naviguer entre les espaces
- **Sélecteur de profil** visuel avec 4 profils prédéfinis + mode personnalisé
- **Compteur en temps réel** du nombre d'applications et taille totale
- **Boutons "Tout sélectionner/désélectionner"** par catégorie
- **Navigation fluide** entre les espaces avec boutons Retour/Continuer
- **Page Generate** pour sélectionner les modules à inclure dans le script

#### Profils et Applications
- **Profil TENOR** (renommé depuis "Projet & Support & Commerce")
- **Profil SI amélioré** : Git, SSMS, DBeaver, Burp Suite Community Edition
- **Profil DEV .NET enrichi** : Python 3.12, Node.js
- **Profil DEV WinDev** : eCarAdmin, EDI Translator, Gestion Temps
- **7-Zip déplacé** des apps optionnelles vers Master (obligatoire)

#### Fonctionnalités Techniques
- **Variables d'environnement** pour l'URL de l'API (support dev/prod)
- **Docker Compose production** (`docker-compose.prod.yml`)
- **Build arguments** pour passer l'URL API au build frontend
- **Transformation automatique** de la config utilisateur vers format API
- **Génération modulaire** : scripts séparés ou combinés

#### Design et UX
- **Badges de couleur** par profil (Bleu, Violet, Orange, Vert)
- **Interface responsive** avec grilles adaptatives (1/2/3 colonnes)
- **Tooltips informatifs** sur les options d'optimisation
- **Validation** avant génération (minimum 1 app requise)
- **Indicateurs visuels** : profil sélectionné, apps Master désactivées

### 🔄 Modifié

- **README.md** complètement réécrit pour v5.0
- **Flux de navigation** : Home → Installation → Optimizations → Diagnostic → Generate
- **API endpoint** `/api/generate` pour supporter les modules sélectionnés
- **.gitignore** mis à jour (web/dist/, .env, fichiers backup)
- **Dockerfile web** avec support des build arguments

### 🐛 Corrigé

- **Erreur "Configuration 'apps' manquante"** lors de la génération
- **URL API hardcodée** remplacée par variable d'environnement
- **Apps Master non cochées** dans les profils prédéfinis
- **Navigation cassée** entre les pages

### 🗑️ Supprimé

- Fichiers backup (`.bak`)
- Ancien système de tabs dans Optimizations
- Configuration hardcodée de l'URL API

---

## [4.0.0] - 2024-XX-XX

### Ajouté
- Version initiale avec interface web basique
- 3 profils : DEV, SUPPORT, SI
- Script PowerShell principal
- Configuration via fichiers JSON

---

## Notes de Migration

### v4.0 → v5.0

**Breaking Changes:**
- L'interface a été complètement refaite
- Les profils ont été renommés/restructurés
- Le flux de génération passe maintenant par 4 étapes

**Migration:**
1. Mettre à jour `apps.json` avec les nouveaux profils
2. Configurer `.env` avec `VITE_API_URL` pour la production
3. Utiliser `docker-compose.prod.yml` pour le déploiement
4. Configurer le reverse proxy pour `postboot.tenorsolutions.com`

---

## Roadmap

### v5.1 (Prévu)
- [ ] Module Diagnostic fonctionnel
- [ ] Export JSON de la configuration
- [ ] Historique des scripts générés
- [ ] Templates de profils personnalisés

### v5.2 (Futur)
- [ ] Authentification utilisateur
- [ ] Sauvegarde des configurations
- [ ] API REST complète
- [ ] Tests unitaires et E2E

---

*Format : [Majeur.Mineur.Patch]*
- **Majeur** : Changements incompatibles avec les versions précédentes
- **Mineur** : Nouvelles fonctionnalités rétrocompatibles
- **Patch** : Corrections de bugs rétrocompatibles
