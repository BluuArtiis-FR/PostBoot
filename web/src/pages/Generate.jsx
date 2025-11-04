import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useConfig } from '../context/ConfigContext';
import { ArrowLeft, Download, Package, Zap, Activity, CheckCircle, Info } from 'lucide-react';
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

const Generate = () => {
  const navigate = useNavigate();
  const { userConfig } = useConfig();
  const [selectedScripts, setSelectedScripts] = useState(['installation', 'optimizations']);
  const [generating, setGenerating] = useState(false);
  const [error, setError] = useState(null);

  const scriptOptions = [
    {
      id: 'installation',
      icon: Package,
      title: 'Installation',
      description: 'Installation des applications sélectionnées via Winget',
      color: 'blue',
      enabled: true
    },
    {
      id: 'optimizations',
      icon: Zap,
      title: 'Optimisations',
      description: 'Debloat, Performance et Personnalisation UI',
      color: 'amber',
      enabled: true
    },
    {
      id: 'diagnostic',
      icon: Activity,
      title: 'Diagnostic',
      description: 'Rapport complet de l\'état du système',
      color: 'green',
      enabled: true
    }
  ];

  const colorClasses = {
    blue: {
      bg: 'bg-blue-50',
      border: 'border-blue-200',
      selectedBorder: 'border-blue-500',
      selectedBg: 'bg-blue-100',
      iconBg: 'bg-blue-100',
      iconText: 'text-blue-600',
      checkBg: 'bg-blue-600'
    },
    amber: {
      bg: 'bg-amber-50',
      border: 'border-amber-200',
      selectedBorder: 'border-amber-500',
      selectedBg: 'bg-amber-100',
      iconBg: 'bg-amber-100',
      iconText: 'text-amber-600',
      checkBg: 'bg-amber-600'
    },
    green: {
      bg: 'bg-green-50',
      border: 'border-green-200',
      selectedBorder: 'border-green-500',
      selectedBg: 'bg-green-100',
      iconBg: 'bg-green-100',
      iconText: 'text-green-600',
      checkBg: 'bg-green-600'
    }
  };

  const toggleScript = (scriptId) => {
    if (selectedScripts.includes(scriptId)) {
      // Don't allow deselecting if it's the only one
      if (selectedScripts.length === 1) {
        setError('Vous devez sélectionner au moins un type de script');
        return;
      }
      setSelectedScripts(selectedScripts.filter(id => id !== scriptId));
    } else {
      setSelectedScripts([...selectedScripts, scriptId]);
    }
    setError(null);
  };

  const handleGenerate = async () => {
    if (selectedScripts.length === 0) {
      setError('Vous devez sélectionner au moins un type de script');
      return;
    }

    setGenerating(true);
    setError(null);

    try {
      const response = await axios.post(`${API_URL}/api/generate`, {
        config: userConfig,
        scriptTypes: selectedScripts,
        embedWpf: userConfig.embed_wpf || false
      }, {
        responseType: 'blob'
      });

      // Determine filename based on selected scripts
      let filename = 'PostBootSetup';
      if (selectedScripts.length === 1) {
        const scriptNames = {
          installation: 'Installation',
          optimizations: 'Optimizations',
          diagnostic: 'Diagnostic'
        };
        filename = `PostBootSetup_${scriptNames[selectedScripts[0]]}`;
      } else if (selectedScripts.length === 3) {
        filename = 'PostBootSetup_Complete';
      } else {
        filename = `PostBootSetup_${selectedScripts.map(s => s.charAt(0).toUpperCase() + s.slice(1)).join('_')}`;
      }

      // Ajouter suffixe WPF si activé
      if (userConfig.embed_wpf) {
        filename += '_WPF';
      }

      filename += '.ps1';

      // Create download link
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', filename);
      document.body.appendChild(link);
      link.click();
      link.remove();

      // Navigate to success page
      navigate('/success', { state: { filename } });
    } catch (err) {
      console.error('Erreur génération:', err);
      setError('Erreur lors de la génération du script. Veuillez réessayer.');
    } finally {
      setGenerating(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <button
          onClick={() => navigate(-1)}
          className="flex items-center text-gray-600 hover:text-gray-900 transition-colors"
        >
          <ArrowLeft className="w-5 h-5 mr-2" />
          Retour
        </button>
      </div>

      {/* Title */}
      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">
          Génération du script
        </h1>
        <p className="text-gray-600">
          Choisissez les modules à inclure dans votre script PowerShell
        </p>
      </div>

      {/* Script options */}
      <div className="max-w-4xl mx-auto mb-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          {scriptOptions.map((option) => {
            const Icon = option.icon;
            const colors = colorClasses[option.color];
            const isSelected = selectedScripts.includes(option.id);

            return (
              <button
                key={option.id}
                onClick={() => toggleScript(option.id)}
                disabled={!option.enabled}
                className={`
                  card border-2 transition-all duration-200 text-left relative
                  ${isSelected ? colors.selectedBorder + ' ' + colors.selectedBg : colors.border + ' hover:border-gray-400'}
                  ${!option.enabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer hover:shadow-md'}
                `}
              >
                {/* Checkbox indicator */}
                {isSelected && (
                  <div className={`absolute top-3 right-3 w-6 h-6 ${colors.checkBg} rounded-full flex items-center justify-center`}>
                    <CheckCircle className="w-4 h-4 text-white" />
                  </div>
                )}

                <div className="flex flex-col items-center text-center space-y-3">
                  <div className={`${colors.iconBg} p-3 rounded-lg`}>
                    <Icon className={`w-8 h-8 ${colors.iconText}`} />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900 mb-1">
                      {option.title}
                    </h3>
                    <p className="text-sm text-gray-600">
                      {option.description}
                    </p>
                  </div>
                </div>
              </button>
            );
          })}
        </div>

        {/* Info sur le script généré */}
        <div className="card bg-blue-50 border-blue-200">
          <div className="flex items-start space-x-3">
            <Info className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
            <div className="flex-1">
              <h4 className="font-semibold text-blue-900 mb-2">Script généré</h4>
              <p className="text-sm text-blue-800 mb-2">
                {selectedScripts.length === 1 ? (
                  `Un script PowerShell contenant uniquement le module ${scriptOptions.find(s => s.id === selectedScripts[0])?.title} sera généré.`
                ) : selectedScripts.length === 3 ? (
                  'Un script PowerShell complet incluant Installation, Optimisations et Diagnostic sera généré.'
                ) : (
                  `Un script PowerShell incluant ${selectedScripts.length} modules sera généré : ${selectedScripts.map(id => scriptOptions.find(s => s.id === id)?.title).join(', ')}.`
                )}
              </p>
              <p className="text-xs text-blue-700">
                Le script sera téléchargé et pourra être exécuté sur n'importe quel PC Windows avec PowerShell.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Error message */}
      {error && (
        <div className="max-w-4xl mx-auto mb-6">
          <div className="card bg-red-50 border-red-200">
            <p className="text-sm text-red-700">{error}</p>
          </div>
        </div>
      )}

      {/* Actions */}
      <div className="max-w-4xl mx-auto flex items-center justify-between">
        <button
          onClick={() => navigate(-1)}
          className="btn-secondary flex items-center"
          disabled={generating}
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Retour
        </button>
        <button
          onClick={handleGenerate}
          disabled={generating || selectedScripts.length === 0}
          className="btn-primary flex items-center disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {generating ? (
            <>
              <div className="spinner-sm mr-2"></div>
              Génération en cours...
            </>
          ) : (
            <>
              <Download className="w-4 h-4 mr-2" />
              Générer le script
            </>
          )}
        </button>
      </div>
    </div>
  );
};

export default Generate;
