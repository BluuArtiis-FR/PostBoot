import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { useConfig } from '../context/ConfigContext';
import ProfileSelector from '../components/ProfileSelector';
import AppSelector from '../components/AppSelector';
import OptionsAccordion from '../components/OptionsAccordion';
import {
  Download,
  Loader2,
  AlertCircle,
  Package,
  Zap,
  Check,
  ChevronDown,
  ChevronUp,
  Info,
} from 'lucide-react';
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || '';

const ScriptTypeSelector = ({ selected, onChange }) => {
  // Seulement Installation et Optimisations (Diagnostic retiré)
  const scriptTypes = [
    {
      id: 'installation',
      icon: Package,
      title: 'Installation',
      description: 'Applications',
      color: 'blue',
    },
    {
      id: 'optimizations',
      icon: Zap,
      title: 'Optimisations',
      description: 'Performance & UI',
      color: 'amber',
    },
  ];

  const colors = {
    blue: 'border-blue-500 bg-blue-50 text-blue-700',
    amber: 'border-amber-500 bg-amber-50 text-amber-700',
  };

  return (
    <div className="flex flex-wrap gap-2">
      {scriptTypes.map((type) => {
        const Icon = type.icon;
        const isSelected = selected.includes(type.id);
        return (
          <button
            key={type.id}
            onClick={() => {
              if (isSelected && selected.length === 1) return; // Au moins 1
              onChange(
                isSelected
                  ? selected.filter((id) => id !== type.id)
                  : [...selected, type.id]
              );
            }}
            className={`
              flex items-center gap-2 px-3 py-2 rounded-lg border-2 transition-all
              ${isSelected ? colors[type.color] : 'border-gray-200 bg-white hover:border-gray-300'}
            `}
          >
            <Icon className="w-4 h-4" />
            <span className="font-medium text-sm">{type.title}</span>
            {isSelected && <Check className="w-4 h-4" />}
          </button>
        );
      })}
    </div>
  );
};

const ConfigurationPage = () => {
  const navigate = useNavigate();
  const {
    profiles,
    apps,
    modules,
    loading,
    error: loadError,
    userConfig,
    selectProfile,
    updateConfig,
    updateModule,
  } = useConfig();

  const [showAdvancedOptions, setShowAdvancedOptions] = useState(false);
  const [scriptTypes, setScriptTypes] = useState(['installation', 'optimizations']);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState(null);

  // Gérer la sélection/désélection des apps
  const handleToggleApp = (appId) => {
    const allSelectedApps = [
      ...(userConfig.master_apps || []),
      ...(userConfig.profile_apps || []),
      ...(userConfig.optional_apps || []),
    ];

    if (allSelectedApps.includes(appId)) {
      // Retirer l'app
      updateConfig({
        master_apps: (userConfig.master_apps || []).filter((id) => id !== appId),
        profile_apps: (userConfig.profile_apps || []).filter((id) => id !== appId),
        optional_apps: (userConfig.optional_apps || []).filter((id) => id !== appId),
      });
    } else {
      // Ajouter l'app (dans optional_apps par défaut pour les ajouts manuels)
      updateConfig({
        optional_apps: [...(userConfig.optional_apps || []), appId],
      });
    }
  };

  // Liste de toutes les apps sélectionnées
  const allSelectedApps = useMemo(() => {
    return [
      ...(userConfig.master_apps || []),
      ...(userConfig.profile_apps || []),
      ...(userConfig.optional_apps || []),
    ];
  }, [userConfig.master_apps, userConfig.profile_apps, userConfig.optional_apps]);

  // Calculer le résumé
  const summary = useMemo(() => {
    const appsCount = allSelectedApps.length;
    const modulesEnabled = Object.values(userConfig.modules || {}).filter(
      (m) => m?.enabled !== false
    ).length;
    return { appsCount, modulesEnabled };
  }, [allSelectedApps, userConfig.modules]);

  // Générer le script
  const handleGenerate = async () => {
    if (!userConfig.profile && allSelectedApps.length === 0) {
      setError('Veuillez sélectionner un profil ou des applications');
      return;
    }

    if (scriptTypes.length === 0) {
      setError('Veuillez sélectionner au moins un type de script');
      return;
    }

    setGenerating(true);
    setError(null);

    try {
      const response = await axios.post(
        `${API_URL}/api/generate`,
        {
          config: userConfig,
          scriptTypes: scriptTypes,
        },
        {
          responseType: 'blob',
        }
      );

      const profileName = userConfig.profile
        ? userConfig.profile.toLowerCase()
        : 'custom';
      const filename = `postboot-${profileName}.ps1`;

      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();
      link.remove();

      navigate('/success', { state: { filename } });
    } catch (err) {
      console.error('Erreur génération:', err);
      let errorMessage = 'Erreur lors de la génération du script.';

      if (err.response) {
        try {
          const blob = err.response.data;
          const text = await blob.text();
          const errorData = JSON.parse(text);
          errorMessage = errorData.error || errorMessage;
        } catch (parseError) {
          console.error('Erreur parsing:', parseError);
        }
      }

      setError(errorMessage);
    } finally {
      setGenerating(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <Loader2 className="w-12 h-12 text-blue-500 animate-spin mx-auto mb-4" />
          <p className="text-gray-600">Chargement de la configuration...</p>
        </div>
      </div>
    );
  }

  if (loadError) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="bg-red-50 border border-red-200 rounded-xl p-6 max-w-md text-center">
          <AlertCircle className="w-12 h-12 text-red-500 mx-auto mb-4" />
          <h2 className="text-lg font-semibold text-red-800 mb-2">Erreur de chargement</h2>
          <p className="text-red-600">{loadError}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header sticky avec résumé */}
      <div className="sticky top-0 z-10 bg-white border-b border-gray-200 shadow-sm">
        <div className="container mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-xl font-bold text-gray-900">PostBootSetup</h1>
              <p className="text-sm text-gray-500">
                {userConfig.profile ? (
                  <>
                    Profil : <span className="font-medium">{userConfig.profile}</span>
                  </>
                ) : (
                  'Sélectionnez un profil pour commencer'
                )}
              </p>
            </div>

            <div className="flex items-center gap-4">
              {/* Résumé rapide */}
              <div className="hidden sm:flex items-center gap-4 text-sm text-gray-600">
                <span className="flex items-center gap-1">
                  <Package className="w-4 h-4" />
                  {summary.appsCount} apps
                </span>
                <span className="flex items-center gap-1">
                  <Zap className="w-4 h-4" />
                  {summary.modulesEnabled} modules
                </span>
              </div>

              {/* Bouton Générer */}
              <button
                onClick={handleGenerate}
                disabled={generating || !userConfig.profile}
                className="btn-primary flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {generating ? (
                  <>
                    <Loader2 className="w-4 h-4 animate-spin" />
                    Génération...
                  </>
                ) : (
                  <>
                    <Download className="w-4 h-4" />
                    Générer
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Contenu principal */}
      <div className="container mx-auto px-4 py-8 space-y-8">
        {/* Erreur */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-xl p-4 flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-red-700 font-medium">Erreur</p>
              <p className="text-red-600 text-sm">{error}</p>
            </div>
          </div>
        )}

        {/* Section 1: Profil */}
        <section className="bg-white rounded-xl border border-gray-200 p-6">
          <ProfileSelector
            profiles={profiles}
            selectedProfile={userConfig.profile}
            onSelect={selectProfile}
            apps={apps}
          />
        </section>

        {/* Section 2: Applications (visible si profil sélectionné) */}
        {userConfig.profile && (
          <section className="bg-white rounded-xl border border-gray-200 p-6">
            <AppSelector
              profile={userConfig.profile}
              apps={apps}
              selectedApps={allSelectedApps}
              onToggleApp={handleToggleApp}
            />
          </section>
        )}

        {/* Section 3: Options d'optimisation */}
        {userConfig.profile && (
          <section className="bg-white rounded-xl border border-gray-200 p-6">
            <OptionsAccordion
              modules={modules}
              values={userConfig.modules}
              onChange={(moduleKey, newValues) => updateModule(moduleKey, newValues)}
            />
          </section>
        )}

        {/* Section 4: Options avancées (dépliable) */}
        {userConfig.profile && (
          <section className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <button
              onClick={() => setShowAdvancedOptions(!showAdvancedOptions)}
              className="w-full flex items-center justify-between p-6 hover:bg-gray-50 transition-colors"
            >
              <div>
                <h2 className="text-lg font-semibold text-gray-900">Options avancées</h2>
                <p className="text-sm text-gray-500">Types de script et paramètres de génération</p>
              </div>
              {showAdvancedOptions ? (
                <ChevronUp className="w-5 h-5 text-gray-400" />
              ) : (
                <ChevronDown className="w-5 h-5 text-gray-400" />
              )}
            </button>

            {showAdvancedOptions && (
              <div className="px-6 pb-6 space-y-4 border-t border-gray-100 pt-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Types de script à générer
                  </label>
                  <ScriptTypeSelector selected={scriptTypes} onChange={setScriptTypes} />
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 flex items-start gap-3">
                  <Info className="w-5 h-5 text-blue-500 flex-shrink-0 mt-0.5" />
                  <div className="text-sm text-blue-700">
                    <p className="font-medium mb-1">Script généré</p>
                    <p>
                      {scriptTypes.length === 2
                        ? 'Script complet avec Installation et Optimisations.'
                        : `Script incluant : ${scriptTypes
                            .map((t) =>
                              t === 'installation' ? 'Installation' : 'Optimisations'
                            )
                            .join(', ')}.`}
                    </p>
                  </div>
                </div>
              </div>
            )}
          </section>
        )}

        {/* Bouton Générer (mobile/bas de page) */}
        {userConfig.profile && (
          <div className="sm:hidden fixed bottom-0 left-0 right-0 p-4 bg-white border-t border-gray-200">
            <button
              onClick={handleGenerate}
              disabled={generating}
              className="btn-primary w-full flex items-center justify-center gap-2"
            >
              {generating ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  Génération en cours...
                </>
              ) : (
                <>
                  <Download className="w-4 h-4" />
                  Générer le script ({summary.appsCount} apps)
                </>
              )}
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default ConfigurationPage;
