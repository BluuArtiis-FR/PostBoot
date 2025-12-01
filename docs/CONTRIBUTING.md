# 🤝 Guide de Contribution - PostBootSetup v5.0

> Comment contribuer au projet PostBootSetup

---

## 📋 Table des Matières

- [Code de conduite](#code-de-conduite)
- [Comment contribuer](#comment-contribuer)
- [Workflow Git](#workflow-git)
- [Conventions de code](#conventions-de-code)
- [Tests](#tests)
- [Documentation](#documentation)

---

## Code de conduite

### Principes

- 🤝 Respecter tous les contributeurs
- 💬 Communiquer de manière constructive
- 🎯 Se concentrer sur la qualité du code
- 📚 Documenter les changements

---

## Comment contribuer

### Types de contributions

#### 🐛 Signaler un bug

1. Vérifier que le bug n'est pas déjà signalé dans [Issues](https://github.com/TenorDataSolutions/PostBoot/issues)
2. Créer une nouvelle issue avec le template "Bug Report"
3. Fournir:
   - Description claire du problème
   - Étapes pour reproduire
   - Comportement attendu vs observé
   - Environnement (OS, version Docker, etc.)
   - Logs et captures d'écran si pertinent

#### ✨ Proposer une fonctionnalité

1. Créer une issue avec le template "Feature Request"
2. Décrire:
   - Besoin métier
   - Solution proposée
   - Alternatives envisagées
   - Impact sur l'existant

#### 🔧 Soumettre du code

1. Fork le projet
2. Créer une branche feature
3. Développer et tester
4. Soumettre une Pull Request

---

## Workflow Git

### 1. Fork et Clone

```bash
# Fork via GitHub UI
# Puis cloner votre fork
git clone https://github.com/VOTRE-USERNAME/PostBoot.git
cd PostBoot

# Ajouter l'upstream
git remote add upstream https://github.com/TenorDataSolutions/PostBoot.git
```

### 2. Créer une branche

```bash
# Mettre à jour master
git checkout master
git pull upstream master

# Créer une branche feature
git checkout -b feature/nom-fonctionnalite

# Ou pour un bugfix
git checkout -b fix/nom-bug
```

### 3. Développer

```bash
# Faire vos modifications
# Tester localement
docker-compose up -d

# Ajouter les fichiers modifiés
git add .

# Commit (voir conventions ci-dessous)
git commit -m "feat: ajout de la fonctionnalité X"
```

### 4. Push et Pull Request

```bash
# Push vers votre fork
git push origin feature/nom-fonctionnalite

# Créer une PR via GitHub UI
```

---

## Conventions de code

### Commits (Conventional Commits)

Format: `<type>(<scope>): <description>`

**Types:**
- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation uniquement
- `style`: Formatage (pas de changement de logique)
- `refactor`: Refactoring du code
- `perf`: Amélioration de performance
- `test`: Ajout ou modification de tests
- `chore`: Tâches de maintenance (build, CI, etc.)

**Exemples:**
```bash
feat(api): ajouter endpoint /api/validate
fix(generator): corriger Export-ModuleMember dans modules
docs(readme): mettre à jour guide d'installation
refactor(ui): simplifier composant AppSelector
test(api): ajouter tests pour endpoint /generate
chore(docker): mettre à jour image Python vers 3.12
```

**Scope optionnel:**
- `api` - Backend Flask
- `ui` / `web` - Frontend React
- `generator` - Logique de génération
- `modules` - Modules PowerShell
- `config` - Configuration
- `docs` - Documentation
- `docker` - Docker / Déploiement

### Code Python (Backend)

```python
# Style: PEP 8
# Formatter: black
# Linter: flake8

# Imports organisés
import os
import sys
from pathlib import Path

from flask import Flask, request
import logging

# Constantes en MAJUSCULES
MAX_APPS_PER_SCRIPT = 100
MODULES_DIR = Path(__file__).parent / "modules"

# Classes en PascalCase
class ScriptGenerator:
    """Générateur de scripts PowerShell."""

    def __init__(self):
        self.logger = logging.getLogger(__name__)

    def generate(self, config: dict) -> str:
        """Génère un script à partir de la config."""
        pass

# Fonctions en snake_case
def validate_config(config: dict) -> bool:
    """Valide la configuration utilisateur."""
    return True

# Docstrings pour toutes les fonctions publiques
def complex_function(param1: str, param2: int) -> dict:
    """
    Description de la fonction.

    Args:
        param1: Description du paramètre 1
        param2: Description du paramètre 2

    Returns:
        Description du retour

    Raises:
        ValueError: Si param2 < 0
    """
    pass
```

### Code JavaScript/React (Frontend)

```javascript
// Style: Airbnb JavaScript Style Guide
// Formatter: Prettier
// Linter: ESLint

// Imports organisés
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

// Components en PascalCase
const AppSelector = ({ apps, onSelect }) => {
  const [selectedApps, setSelectedApps] = useState([]);

  useEffect(() => {
    // Effect logic
  }, []);

  const handleSelect = (app) => {
    // Handler logic
  };

  return (
    <div className="app-selector">
      {/* JSX */}
    </div>
  );
};

// PropTypes obligatoires
AppSelector.propTypes = {
  apps: PropTypes.arrayOf(PropTypes.object).isRequired,
  onSelect: PropTypes.func.isRequired,
};

export default AppSelector;
```

### Code PowerShell (Modules)

```powershell
# Style: PowerShell Best Practices

# Fonctions en Verb-Noun (PascalCase)
function Invoke-WindowsDebloat {
    <#
    .SYNOPSIS
    Supprime les applications bloatware de Windows.

    .DESCRIPTION
    Cette fonction supprime les applications préinstallées inutiles
    et désactive la télémétrie Windows.

    .PARAMETER Silent
    Mode silencieux sans affichage

    .EXAMPLE
    Invoke-WindowsDebloat -Silent

    .NOTES
    Requiert des privilèges administrateur
    #>
    [CmdletBinding()]
    param(
        [switch]$Silent
    )

    # Variables en PascalCase
    $BloatwareApps = @(
        "Microsoft.XboxApp",
        "Microsoft.BingNews"
    )

    # Try/Catch pour gestion d'erreurs
    try {
        foreach ($App in $BloatwareApps) {
            Remove-BloatwareApp -AppName $App
        }
    }
    catch {
        Write-Error "Erreur: $_"
    }
}
```

---

## Tests

### Backend (Python)

```bash
# Installation dépendances de test
pip install pytest pytest-cov pytest-mock

# Lancer les tests
cd generator
pytest tests/

# Avec couverture
pytest --cov=app tests/

# Test spécifique
pytest tests/test_generator.py::test_validate_config
```

**Structure des tests:**
```
generator/
├── app.py
└── tests/
    ├── __init__.py
    ├── test_generator.py
    ├── test_api.py
    └── fixtures/
        └── config_example.json
```

**Exemple de test:**
```python
# tests/test_generator.py
import pytest
from app import ScriptGenerator

def test_validate_config_valid():
    """Test validation avec config valide."""
    generator = ScriptGenerator()
    config = {
        "apps": {"master": ["Chrome"], "profile": []},
        "modules": ["debloat"]
    }
    is_valid, error = generator.validate_config(config)
    assert is_valid is True
    assert error is None

def test_validate_config_missing_apps():
    """Test validation avec apps manquantes."""
    generator = ScriptGenerator()
    config = {"modules": ["debloat"]}
    is_valid, error = generator.validate_config(config)
    assert is_valid is False
    assert "apps" in error
```

### Frontend (React)

```bash
# Lancer les tests
cd web
npm run test

# Mode watch
npm run test:watch

# Avec couverture
npm run test:coverage
```

**Exemple de test:**
```javascript
// src/components/AppSelector.test.jsx
import { render, screen, fireEvent } from '@testing-library/react';
import AppSelector from './AppSelector';

describe('AppSelector', () => {
  const mockApps = [
    { name: 'Chrome', category: 'productivity' },
    { name: 'Git', category: 'dev' }
  ];

  it('renders all apps', () => {
    render(<AppSelector apps={mockApps} onSelect={jest.fn()} />);
    expect(screen.getByText('Chrome')).toBeInTheDocument();
    expect(screen.getByText('Git')).toBeInTheDocument();
  });

  it('calls onSelect when app is clicked', () => {
    const mockOnSelect = jest.fn();
    render(<AppSelector apps={mockApps} onSelect={mockOnSelect} />);

    fireEvent.click(screen.getByText('Chrome'));
    expect(mockOnSelect).toHaveBeenCalledWith(mockApps[0]);
  });
});
```

### Scripts PowerShell

```powershell
# Validation syntaxe
.\ValidateScript.ps1 -ScriptPath ".\generated\test.ps1"

# Tests manuels sur VM
# 1. Créer snapshot VM
# 2. Exécuter script
# 3. Vérifier résultats
# 4. Restaurer snapshot
```

---

## Documentation

### Documentation du code

- **Python**: Docstrings Google Style
- **JavaScript**: JSDoc
- **PowerShell**: Comment-based help

### Documentation utilisateur

- Mettre à jour `docs/USER_GUIDE.md` pour nouvelles fonctionnalités
- Ajouter captures d'écran si nécessaire
- Mettre à jour `CHANGELOG.md`

### Documentation API

- Mettre à jour `docs/API.md` pour nouveaux endpoints
- Fournir exemples d'utilisation
- Documenter codes d'erreur

---

## Checklist Pull Request

Avant de soumettre une PR, vérifier:

- [ ] Le code suit les conventions établies
- [ ] Les tests passent (`pytest` et `npm test`)
- [ ] La couverture de tests est maintenue/améliorée
- [ ] La documentation est mise à jour
- [ ] Le CHANGELOG.md est mis à jour
- [ ] Les commits suivent Conventional Commits
- [ ] Pas de secrets/credentials dans le code
- [ ] Le code a été testé localement avec Docker

---

## Review Process

### Timeline

- **Review initial**: 1-2 jours ouvrés
- **Itérations**: Selon complexité
- **Merge**: Après validation par 1 reviewer

### Critères d'acceptation

✅ **Approuvé si:**
- Code de qualité
- Tests passants
- Documentation à jour
- Pas de régression

❌ **Refusé si:**
- Erreurs de syntaxe
- Tests échouent
- Pas de documentation
- Régression détectée

---

## Questions?

- **Email**: si@tenorsolutions.com
- **GitHub Issues**: [Poser une question](https://github.com/TenorDataSolutions/PostBoot/issues/new)
- **Documentation**: [docs/](.)

---

## Liens utiles

- [🏠 Retour README](../README.md)
- [🚀 Guide Utilisateur](USER_GUIDE.md)
- [💻 Guide Développeur](DEVELOPER.md)
- [📝 Changelog](../CHANGELOG.md)

---

**Merci de contribuer à PostBootSetup!** 🎉

**© 2025 Tenor Data Solutions**
