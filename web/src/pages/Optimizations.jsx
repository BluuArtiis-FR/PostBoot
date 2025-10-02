import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useConfig } from '../context/ConfigContext';
import { ArrowLeft, ArrowRight, Zap, Palette, Trash2, Info } from 'lucide-react';

const Optimizations = () => {
  const navigate = useNavigate();
  const { modules, userConfig, updateModule } = useConfig();
  const [showTooltip, setShowTooltip] = useState(null);

  if (!modules) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="spinner mx-auto mb-4"></div>
          <p className="text-gray-600">Chargement des modules...</p>
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

      {/* Bandeau Optimisations */}
      <div className="card bg-amber-50 border-amber-200 mb-8">
        <div className="flex items-start space-x-4">
          <div className="bg-amber-100 p-3 rounded-lg">
            <Zap className="w-8 h-8 text-amber-600" />
          </div>
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              Optimisations Windows
            </h1>
            <p className="text-gray-600">
              Configurez les optimisations de performance, le debloat et la personnalisation de l'interface.
            </p>
          </div>
        </div>
      </div>

      {/* Module Debloat (obligatoire) */}
      <div className="card mb-6">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-start space-x-3">
            <div className="bg-red-100 p-2 rounded-lg">
              <Trash2 className="w-5 h-5 text-red-600" />
            </div>
            <div>
              <h2 className="text-xl font-semibold text-gray-900">
                Debloat Windows
                <span className="ml-3 text-xs bg-red-100 text-red-700 px-2 py-1 rounded font-medium">
                  OBLIGATOIRE
                </span>
              </h2>
              <p className="text-sm text-gray-600 mt-1">
                Suppression des applications préinstallées inutiles et désactivation de la télémétrie
              </p>
            </div>
          </div>
        </div>

        <div className="bg-gray-50 border border-gray-200 rounded-lg p-4">
          <h3 className="font-medium text-gray-900 mb-3">Ce module va effectuer :</h3>
          <ul className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm text-gray-700">
            <li className="flex items-start">
              <span className="text-red-600 mr-2">•</span>
              <span>Suppression bloatware (Xbox, Candy Crush, etc.)</span>
            </li>
            <li className="flex items-start">
              <span className="text-red-600 mr-2">•</span>
              <span>Désactivation télémétrie Microsoft</span>
            </li>
            <li className="flex items-start">
              <span className="text-red-600 mr-2">•</span>
              <span>Désactivation Cortana et suggestions</span>
            </li>
            <li className="flex items-start">
              <span className="text-red-600 mr-2">•</span>
              <span>Optimisation confidentialité (tracking, publicités)</span>
            </li>
            <li className="flex items-start">
              <span className="text-red-600 mr-2">•</span>
              <span>Désactivation services inutiles (DiagTrack, RetailDemo...)</span>
            </li>
            <li className="flex items-start">
              <span className="text-red-600 mr-2">•</span>
              <span>Gain d'espace : 2-5 GB</span>
            </li>
          </ul>
        </div>
      </div>

      {/* Module Performance */}
      <div className="card mb-6">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-start space-x-3">
            <div className="bg-blue-100 p-2 rounded-lg">
              <Zap className="w-5 h-5 text-blue-600" />
            </div>
            <div className="flex-1">
              <h2 className="text-xl font-semibold text-gray-900">
                Optimisations Performance
              </h2>
              <p className="text-sm text-gray-600 mt-1">
                Améliorez les performances système et réduisez la latence
              </p>
            </div>
          </div>
          <label className="flex items-center cursor-pointer">
            <input
              type="checkbox"
              checked={userConfig.modules.performance.enabled}
              onChange={(e) => updateModule('performance', { enabled: e.target.checked })}
              className="checkbox"
            />
            <span className="ml-2 text-sm font-medium text-gray-700">Activer</span>
          </label>
        </div>

        {userConfig.modules.performance.enabled && (
          <div className="space-y-3 border-t pt-4">
            {Object.entries(modules.performance.options).map(([key, option]) => (
              <div
                key={key}
                className="border border-gray-200 rounded-lg p-4 hover:border-primary-300 transition-colors bg-white relative"
              >
                <label className="flex items-start space-x-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={userConfig.modules.performance[key] || false}
                    onChange={(e) => updateModule('performance', { [key]: e.target.checked })}
                    className="checkbox mt-1"
                  />
                  <div className="flex-1">
                    <div className="flex items-center space-x-2 mb-1">
                      <span className="font-semibold text-gray-900">{option.name}</span>
                      {option.recommended && (
                        <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded font-medium">
                          ⭐ Recommandé
                        </span>
                      )}
                      <button
                        onMouseEnter={() => setShowTooltip(key)}
                        onMouseLeave={() => setShowTooltip(null)}
                        className="text-gray-400 hover:text-gray-600 relative"
                      >
                        <Info className="w-4 h-4" />
                        {showTooltip === key && (
                          <div className="absolute left-0 top-6 w-64 bg-gray-900 text-white text-xs p-3 rounded shadow-lg z-10">
                            {option.description}
                          </div>
                        )}
                      </button>
                    </div>
                    <p className="text-sm text-gray-600">{option.description}</p>
                  </div>
                </label>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Module UI */}
      <div className="card mb-8">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-start space-x-3">
            <div className="bg-purple-100 p-2 rounded-lg">
              <Palette className="w-5 h-5 text-purple-600" />
            </div>
            <div className="flex-1">
              <h2 className="text-xl font-semibold text-gray-900">
                Personnalisation Interface
              </h2>
              <p className="text-sm text-gray-600 mt-1">
                Personnalisez l'apparence et le comportement de Windows
              </p>
            </div>
          </div>
          <label className="flex items-center cursor-pointer">
            <input
              type="checkbox"
              checked={userConfig.modules.ui.enabled}
              onChange={(e) => updateModule('ui', { enabled: e.target.checked })}
              className="checkbox"
            />
            <span className="ml-2 text-sm font-medium text-gray-700">Activer</span>
          </label>
        </div>

        {userConfig.modules.ui.enabled && (
          <div className="space-y-3 border-t pt-4">
            {Object.entries(modules.ui.options).map(([key, option]) => {
              // Skip les options spéciales (TaskbarPosition, ThemeColor)
              if (key === 'TaskbarPosition' || key === 'ThemeColor') return null;

              return (
                <div
                  key={key}
                  className="border border-gray-200 rounded-lg p-4 hover:border-primary-300 transition-colors bg-white relative"
                >
                  <label className="flex items-start space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={userConfig.modules.ui[key] || false}
                      onChange={(e) => updateModule('ui', { [key]: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center space-x-2 mb-1">
                        <span className="font-semibold text-gray-900">{option.name}</span>
                        <button
                          onMouseEnter={() => setShowTooltip(key)}
                          onMouseLeave={() => setShowTooltip(null)}
                          className="text-gray-400 hover:text-gray-600 relative"
                        >
                          <Info className="w-4 h-4" />
                          {showTooltip === key && (
                            <div className="absolute left-0 top-6 w-64 bg-gray-900 text-white text-xs p-3 rounded shadow-lg z-10">
                              {option.description}
                            </div>
                          )}
                        </button>
                      </div>
                      <p className="text-sm text-gray-600">{option.description}</p>
                    </div>
                  </label>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="flex items-center justify-between">
        <button
          onClick={() => navigate('/installation')}
          className="btn-secondary flex items-center"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Retour
        </button>
        <button
          onClick={() => navigate('/diagnostic')}
          className="btn-primary flex items-center"
        >
          Continuer
          <ArrowRight className="w-4 h-4 ml-2" />
        </button>
      </div>
    </div>
  );
};

export default Optimizations;
