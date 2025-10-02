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
          {profiles.map((profile) => (
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
              {userConfig.profile ? 'INCLUS AUTOMATIQUEMENT' : 'REQUIS'}
            </span>
          </h2>
          {!userConfig.profile && (
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
            const isDisabled = userConfig.profile !== null;

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
          {userConfig.profile && apps.profiles[userConfig.profile]
            ? apps.profiles[userConfig.profile].apps.map((app) => {
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
              })
            : Object.entries(apps.profiles).flatMap(([profileId, profile]) =>
                profile.apps.map((app) => {
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
                        <div className="text-xs text-gray-500">
                          {app.size} • {profileId}
                        </div>
                      </div>
                    </label>
                  );
                })
              )}
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
