#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script de test pour verifier la generation de scripts pour tous les profils.
"""

import sys
import os
import io

# Forcer UTF-8 pour stdout
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

# Ajouter le repertoire generator au path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'generator'))

from app import ScriptGenerator, transform_user_config_to_api_config

def test_profile(profile_id, profile_name, custom_apps=None):
    """Teste la generation d'un script pour un profil donne."""
    print(f"\n{'='*60}")
    print(f"Test: {profile_name} ({profile_id or 'CUSTOM'})")
    print('='*60)

    try:
        generator = ScriptGenerator()

        # Configuration utilisateur simulée
        user_config = {
            'profile': profile_id,
            'custom_name': profile_name,
            'master_apps': [],
            'profile_apps': custom_apps or [],
            'optional_apps': [],
            'modules': {
                'debloat': {'enabled': True},
                'performance': {
                    'enabled': True,
                    'PageFile': True,
                    'PowerPlan': True,
                    'StartupPrograms': True,
                    'Network': True,
                    'VisualEffects': True
                },
                'ui': {
                    'enabled': True,
                    'DarkMode': True,
                    'ShowFileExtensions': True,
                    'ShowFullPath': True,
                    'ShowHiddenFiles': False,
                    'ShowThisPC': True,
                    'ShowRecycleBin': True,
                    'RestartExplorer': True,
                    'TaskbarAlignLeft': True,
                    'Windows10ContextMenu': True,
                    'HideWidgets': True,
                    'HideTaskView': True,
                    'EnableEndTask': True
                }
            }
        }

        script_types = ['installation', 'optimizations']

        # Transformer la config
        api_config = transform_user_config_to_api_config(user_config, script_types)

        # Vérifier les apps
        master_count = len(api_config.get('apps', {}).get('master', []))
        profile_count = len(api_config.get('apps', {}).get('profile', []))
        modules = api_config.get('modules', [])

        print(f"  Apps master: {master_count}")
        print(f"  Apps profil: {profile_count}")
        print(f"  Modules: {', '.join(modules)}")

        # Générer le script
        resolved_profile_name = profile_id or profile_name or 'Custom'
        script_content = generator.generate_script(api_config, resolved_profile_name)

        # Vérifications
        script_size = len(script_content)
        has_metadata = '$Global:ScriptMetadata' in script_content
        has_config = '$Global:EmbeddedConfig' in script_content
        has_main = 'Main script execution' in script_content or 'function Install-' in script_content

        print(f"  Taille script: {script_size:,} caracteres")
        print(f"  Metadonnees: {'OK' if has_metadata else 'MANQUANT'}")
        print(f"  Config embarquee: {'OK' if has_config else 'MANQUANT'}")
        print(f"  Code principal: {'OK' if has_main else 'MANQUANT'}")

        if script_size > 1000 and has_metadata and has_config:
            print(f"\n  [OK] SUCCES: Script genere correctement")
            return True
        else:
            print(f"\n  [ECHEC] Script incomplet ou invalide")
            return False

    except Exception as e:
        print(f"\n  [ERREUR] {str(e)}")
        import traceback
        traceback.print_exc()
        return False

def main():
    print("="*60)
    print("TEST DE GENERATION DE SCRIPTS - TOUS PROFILS")
    print("="*60)

    results = {}

    # Test des profils predefinis
    profiles = [
        ('DEV_DOTNET', 'Developpeur .NET'),
        ('DEV_WINDEV', 'Developpeur WinDev'),
        ('TENOR', 'Projet & Support TENOR'),
        ('SI', 'Systeme d\'Information'),
    ]

    for profile_id, profile_name in profiles:
        results[profile_id] = test_profile(profile_id, profile_name)

    # Test du profil personnalise avec quelques apps
    custom_apps = ['Git.Git', 'Python.Python.3.12']  # Apps selectionnees manuellement
    results['CUSTOM'] = test_profile(None, 'Configuration personnalisee', custom_apps)

    # Resume
    print("\n" + "="*60)
    print("RESUME DES TESTS")
    print("="*60)

    success_count = sum(1 for r in results.values() if r)
    total_count = len(results)

    for profile, success in results.items():
        status = "[OK]" if success else "[ECHEC]"
        print(f"  {profile}: {status}")

    print(f"\nResultat: {success_count}/{total_count} profils OK")

    return 0 if success_count == total_count else 1

if __name__ == '__main__':
    sys.exit(main())
