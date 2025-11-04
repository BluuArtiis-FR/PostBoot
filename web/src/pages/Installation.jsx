import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useConfig } from '../context/ConfigContext';
import {
  Package,
  ArrowLeft,
  ArrowRight
} from 'lucide-react';

const Installation = () => {
  const navigate = useNavigate();
  const { apps, profiles, userConfig, updateConfig, selectProfile } = useConfig();
  const [error, setError] = useState(null);

  // Gérer la sélection d'applications
  const toggleApp = (appId, category) => {
    const categoryKey = `${category}_apps`;
    const currentApps = userConfig[categoryKey] || [];

    const newApps = currentApps.includes(appId)
      ? currentApps.filter(id => id !== appId)
      : [...currentApps, appId];

    updateConfig({ [categoryKey]: newApps });
  };

  // Tout sélectionner/désélectionner
  const selectAllInCategory = (category) => {
    const categoryKey = `${category}_apps`;
    let allApps = [];

    if (category === 'master') {
      allApps = apps.master.map(app => app.winget || app.url);
    } else if (category === 'profile') {
      if (userConfig.profile && apps.profiles[userConfig.profile]) {
        allApps = apps.profiles[userConfig.profile].apps.map(app => app.winget || app.url);
      } else {
        // Mode custom: toutes les apps de tous les profils
        Object.values(apps.profiles).forEach(profile => {
          allApps.push(...profile.apps.map(app => app.winget || app.url));
        });
      }
    } else if (category === 'optional') {
      allApps = apps.optional.map(app => app.winget);
    }

    updateConfig({ [categoryKey]: allApps });
  };

  const deselectAllInCategory = (category) => {
    const categoryKey = `${category}_apps`;
    updateConfig({ [categoryKey]: [] });
  };

  // Calculer la taille totale
  const calculateTotalSize = () => {
    if (!apps) return 0;
    let totalMB = 0;

    // Apps Master
    apps.master.forEach(app => {
      if (userConfig.profile || userConfig.master_apps.includes(app.winget || app.url)) {
        const size = parseFloat(app.size);
        const unit = app.size.toUpperCase();
        totalMB += unit.includes('GB') ? size * 1024 : size;
      }
    });

    // Apps Profil
    if (userConfig.profile && apps.profiles[userConfig.profile]) {
      apps.profiles[userConfig.profile].apps.forEach(app => {
        if (userConfig.profile_apps.includes(app.winget || app.url)) {
          const size = parseFloat(app.size);
          const unit = app.size.toUpperCase();
          totalMB += unit.includes('GB') ? size * 1024 : size;
        }
      });
    } else {
      // Mode custom
      Object.values(apps.profiles).forEach(profile => {
        profile.apps.forEach(app => {
          if (userConfig.profile_apps.includes(app.winget || app.url)) {
            const size = parseFloat(app.size);
            const unit = app.size.toUpperCase();
            totalMB += unit.includes('GB') ? size * 1024 : size;
          }
        });
      });
    }

    // Apps Optionnelles
    apps.optional.forEach(app => {
      if (userConfig.optional_apps.includes(app.winget)) {
        const size = parseFloat(app.size);
        const unit = app.size.toUpperCase();
        totalMB += unit.includes('GB') ? size * 1024 : size;
      }
    });

    return totalMB >= 1024 ? (totalMB / 1024).toFixed(1) + ' GB' : totalMB.toFixed(0) + ' MB';
  };

  // Compter le nombre total d'apps sélectionnées
  const getTotalAppsCount = () => {
    let count = 0;
    if (userConfig.profile) {
      count += apps.master.length; // Master apps toujours inclus dans un profil
    } else {
      count += userConfig.master_apps.length;
    }
    count += userConfig.profile_apps.length;
    count += userConfig.optional_apps.length;
    return count;
  };

  // Continuer vers la page des optimisations
  const handleContinue = () => {
    const totalApps = getTotalAppsCount();
    if (totalApps === 0) {
      setError('Vous devez sélectionner au moins une application');
      return;
    }
    navigate('/optimizations');
  };

  if (!apps) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="spinner mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement des applications...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <button
          onClick={() => navigate('/')}
          className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Retour à l'accueil
        </button>
      </div>

      {/* Sélecteur de Profil */}
      <div className="card mb-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Sélection du profil</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {/* Profil Custom */}
          <button
            onClick={() => selectProfile(null)}
            className={`p-4 border-2 rounded-lg text-left transition-all ${
              userConfig.profile === null
                ? 'border-blue-500 bg-blue-50'
                : 'border-gray-200 hover:border-gray-300 bg-white'
            }`}
          >
            <div className="font-semibold text-gray-900 mb-1">Personnalisé</div>
            <p className="text-sm text-gray-600">Choisissez vos applications</p>
          </button>

          {/* Profils prédéfinis */}
          {profiles.filter(p => p.id !== 'CUSTOM').map((profile) => (
            <button
              key={profile.id}
              onClick={() => selectProfile(profile.id)}
              className={`p-4 border-2 rounded-lg text-left transition-all ${
                userConfig.profile === profile.id
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-gray-200 hover:border-gray-300 bg-white'
              }`}
            >
              <div className="font-semibold text-gray-900 mb-1">{profile.name}</div>
              <p className="text-sm text-gray-600">{profile.description}</p>
            </button>
          ))}
        </div>
      </div>

      {/* Bandeau Profil */}
      <div className="card bg-blue-50 border-blue-200 mb-8">
        <div className="flex items-start justify-between">
          <div className="flex items-start space-x-4">
            <div className="bg-blue-100 p-3 rounded-lg">
              <Package className="w-8 h-8 text-blue-600" />
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900 mb-1">
                {userConfig.custom_name || 'Installation'}
              </h1>
              <p className="text-sm text-gray-600">
                Sélectionnez les applications à installer
              </p>
            </div>
          </div>
          <div className="text-right">
            <div className="text-2xl font-bold text-blue-600">
              {getTotalAppsCount()}
            </div>
            <div className="text-sm text-gray-600">applications</div>
            <div className="text-sm font-medium text-gray-700 mt-1">
              {calculateTotalSize()}
            </div>
          </div>
        </div>
      </div>

      {/* Error message */}
      {error && (
        <div className="card bg-red-50 border-red-200 mb-6">
          <p className="text-sm text-red-700">{error}</p>
        </div>
      )}

      {/* Master Apps */}
      <div className="card mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900">
            Applications Master
            <span className="ml-3 text-xs bg-red-100 text-red-700 px-2 py-1 rounded font-medium">
              {userConfig.profile && !apps.profiles[userConfig.profile]?.allowMasterEdit
                ? 'INCLUS AUTOMATIQUEMENT'
                : 'REQUIS'}
            </span>
          </h2>
          {(!userConfig.profile || apps.profiles[userConfig.profile]?.allowMasterEdit) && (
            <div className="flex space-x-2">
              <button
                onClick={() => selectAllInCategory('master')}
                className="btn-secondary text-sm"
              >
                Tout sélectionner
              </button>
              <button
                onClick={() => deselectAllInCategory('master')}
                className="btn-secondary text-sm"
              >
                Tout désélectionner
              </button>
            </div>
          )}
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {apps.master.map((app) => {
            const appId = app.winget || app.url;
            const isChecked = userConfig.profile || userConfig.master_apps.includes(appId);
            const allowMasterEdit = userConfig.profile ? apps.profiles[userConfig.profile]?.allowMasterEdit : true;
            const isDisabled = userConfig.profile !== null && !allowMasterEdit;

            return (
              <label
                key={appId}
                className={`flex items-start space-x-3 p-3 border rounded-lg transition-colors ${
                  isDisabled ? 'bg-gray-50 border-gray-200 cursor-not-allowed' : 'cursor-pointer hover:border-primary-300 bg-white'
                }`}
              >
                <input
                  type="checkbox"
                  checked={isChecked}
                  onChange={() => toggleApp(appId, 'master')}
                  disabled={isDisabled}
                  className="checkbox mt-1"
                />
                <div className="flex-1">
                  <div className="font-semibold text-gray-900">{app.name}</div>
                  <div className="text-xs text-gray-500">{app.size}</div>
                </div>
              </label>
            );
          })}
        </div>
      </div>

      {/* Profile Apps */}
      <div className="card mb-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900">
            {userConfig.profile ? `Applications ${userConfig.custom_name}` : 'Applications des profils'}
          </h2>
          <div className="flex space-x-2">
            <button
              onClick={() => selectAllInCategory('profile')}
              className="btn-secondary text-sm"
            >
              Tout sélectionner
            </button>
            <button
              onClick={() => deselectAllInCategory('profile')}
              className="btn-secondary text-sm"
            >
              Tout désélectionner
            </button>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {(() => {
            const condition1 = userConfig.profile !== null;
            const condition2 = userConfig.profile !== 'CUSTOM';
            const condition3 = apps.profiles[userConfig.profile]?.apps;
            const condition4 = Array.isArray(apps.profiles[userConfig.profile]?.apps);
            const finalCondition = condition1 && condition2 && condition3 && condition4;

            console.log('[DEBUG] Condition check:', {
              'profile !== null': condition1,
              'profile !== CUSTOM': condition2,
              'has apps': condition3,
              'is array': condition4,
              'FINAL': finalCondition
            });

            if (finalCondition) {
              console.log('[DEBUG] DISPLAYING PROFILE APPS ONLY');
              return apps.profiles[userConfig.profile].apps.map((app) => {
                const appId = app.winget || app.url;
                return (
                  <label
                    key={appId}
                    className="flex items-start space-x-3 p-3 border rounded-lg cursor-pointer hover:border-primary-300 bg-white transition-colors"
                  >
                    <input
                      type="checkbox"
                      checked={userConfig.profile_apps.includes(appId)}
                      onChange={() => toggleApp(appId, 'profile')}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="font-semibold text-gray-900">{app.name}</div>
                      <div className="text-xs text-gray-500">{app.size}</div>
                    </div>
                  </label>
                );
              });
            } else {
              console.log('[DEBUG] DISPLAYING ALL APPS (CUSTOM MODE)');
              // Collecter toutes les apps et dédupliquer par appId (sans afficher les profils)
              const allAppsMap = new Map();
              Object.entries(apps.profiles)
                .filter(([profileId]) => profileId !== 'CUSTOM')
                .forEach(([profileId, profile]) => {
                  profile.apps.forEach((app) => {
                    const appId = app.winget || app.url;
                    if (!allAppsMap.has(appId)) {
                      // Première occurrence de cette app, on la garde
                      allAppsMap.set(appId, app);
                    }
                    // Si l'app existe déjà, on ne fait rien (pas de doublon)
                  });
                });

              // Afficher les apps dédupliquées (sans indication de profil)
              return Array.from(allAppsMap.values()).map((app) => {
                const appId = app.winget || app.url;
                return (
                  <label
                    key={appId}
                    className="flex items-start space-x-3 p-3 border rounded-lg cursor-pointer hover:border-primary-300 bg-white transition-colors"
                  >
                    <input
                      type="checkbox"
                      checked={userConfig.profile_apps.includes(appId)}
                      onChange={() => toggleApp(appId, 'profile')}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="font-semibold text-gray-900">{app.name}</div>
                      <div className="text-xs text-gray-500">{app.size}</div>
                    </div>
                  </label>
                );
              });
            }
          })()}
        </div>
      </div>

      {/* Optional Apps */}
      <div className="card mb-8">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-semibold text-gray-900">Applications optionnelles</h2>
          <div className="flex space-x-2">
            <button
              onClick={() => selectAllInCategory('optional')}
              className="btn-secondary text-sm"
            >
              Tout sélectionner
            </button>
            <button
              onClick={() => deselectAllInCategory('optional')}
              className="btn-secondary text-sm"
            >
              Tout désélectionner
            </button>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-3">
          {apps.optional.map((app) => (
            <label
              key={app.winget}
              className="flex items-start space-x-3 p-3 border rounded-lg cursor-pointer hover:border-primary-300 bg-white transition-colors"
            >
              <input
                type="checkbox"
                checked={userConfig.optional_apps.includes(app.winget)}
                onChange={() => toggleApp(app.winget, 'optional')}
                className="checkbox mt-1"
              />
              <div className="flex-1">
                <div className="font-semibold text-gray-900">{app.name}</div>
                <div className="text-xs text-gray-500">{app.size}</div>
              </div>
            </label>
          ))}
        </div>
      </div>

      {/* Option WPF */}
      <div className="card mb-8 bg-gradient-to-r from-blue-50 to-indigo-50 border-blue-200">
        <div className="flex items-start space-x-4">
          <div className="flex-shrink-0">
            <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center">
              <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
              </svg>
            </div>
          </div>
          <div className="flex-1">
            <label className="flex items-start cursor-pointer">
              <input
                type="checkbox"
                checked={userConfig.embed_wpf}
                onChange={(e) => updateConfig({ embed_wpf: e.target.checked })}
                className="checkbox mt-1 mr-3"
              />
              <div>
                <div className="font-semibold text-gray-900 mb-1">
                  Interface WPF intégrée (Recommandé)
                </div>
                <div className="text-sm text-gray-600">
                  Le script généré inclura une interface graphique moderne avec suivi en temps réel de la progression,
                  logs colorés et sauvegarde automatique. Un seul fichier .ps1 à exécuter sur le poste client.
                </div>
                <div className="mt-2 text-xs text-blue-700 bg-blue-100 inline-block px-2 py-1 rounded">
                  ✓ Tout-en-un • ✓ Suivi visuel • ✓ Aucune dépendance externe
                </div>
              </div>
            </label>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center justify-between">
        <button
          onClick={() => navigate('/')}
          className="btn-secondary flex items-center"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Retour
        </button>
        <button
          onClick={handleContinue}
          className="btn-primary flex items-center"
        >
          Continuer
          <ArrowRight className="w-4 h-4 ml-2" />
        </button>
      </div>
    </div>
  );
};

export default Installation;
