import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, ArrowRight, Activity, HardDrive, Cpu, CheckCircle, AlertTriangle } from 'lucide-react';

const Diagnostic = () => {
  const navigate = useNavigate();

  const diagnosticFeatures = [
    {
      icon: HardDrive,
      title: 'État Système',
      description: 'Vérification de l\'état de Windows, version OS, dernières mises à jour',
      color: 'blue'
    },
    {
      icon: Cpu,
      title: 'Matériel',
      description: 'Informations CPU, RAM, disques, température et utilisation',
      color: 'purple'
    },
    {
      icon: CheckCircle,
      title: 'Applications',
      description: 'Liste complète des applications installées via Winget',
      color: 'green'
    },
    {
      icon: AlertTriangle,
      title: 'Problèmes détectés',
      description: 'Détection de services désactivés, erreurs système, optimisations manquantes',
      color: 'amber'
    }
  ];

  const colorClasses = {
    blue: {
      bg: 'bg-blue-100',
      text: 'text-blue-600',
      border: 'border-blue-200'
    },
    purple: {
      bg: 'bg-purple-100',
      text: 'text-purple-600',
      border: 'border-purple-200'
    },
    green: {
      bg: 'bg-green-100',
      text: 'text-green-600',
      border: 'border-green-200'
    },
    amber: {
      bg: 'bg-amber-100',
      text: 'text-amber-600',
      border: 'border-amber-200'
    }
  };

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

      {/* Bandeau Diagnostic */}
      <div className="card bg-green-50 border-green-200 mb-8">
        <div className="flex items-start space-x-4">
          <div className="bg-green-100 p-3 rounded-lg">
            <Activity className="w-8 h-8 text-green-600" />
          </div>
          <div className="flex-1">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              Diagnostic Système
            </h1>
            <p className="text-gray-600">
              Générez un rapport complet de l'état de votre système Windows : matériel, applications, optimisations et problèmes détectés.
            </p>
          </div>
        </div>
      </div>

      {/* Fonctionnalités du diagnostic */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {diagnosticFeatures.map((feature, index) => {
          const Icon = feature.icon;
          const colors = colorClasses[feature.color];

          return (
            <div key={index} className={`card border-2 ${colors.border}`}>
              <div className="flex items-start space-x-4">
                <div className={`${colors.bg} p-3 rounded-lg`}>
                  <Icon className={`w-6 h-6 ${colors.text}`} />
                </div>
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-gray-900 mb-1">
                    {feature.title}
                  </h3>
                  <p className="text-sm text-gray-600">
                    {feature.description}
                  </p>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Ce que le script va faire */}
      <div className="card mb-8">
        <h3 className="font-semibold text-gray-900 mb-4">Le script de diagnostic va générer :</h3>
        <ul className="space-y-3 text-sm text-gray-700">
          <li className="flex items-start">
            <span className="text-green-600 mr-3">✓</span>
            <span>Un rapport HTML détaillé avec toutes les informations système</span>
          </li>
          <li className="flex items-start">
            <span className="text-green-600 mr-3">✓</span>
            <span>Liste des applications installées (Winget et programmes Windows)</span>
          </li>
          <li className="flex items-start">
            <span className="text-green-600 mr-3">✓</span>
            <span>État des optimisations Performance et UI appliquées</span>
          </li>
          <li className="flex items-start">
            <span className="text-green-600 mr-3">✓</span>
            <span>Détection des problèmes : services désactivés, erreurs événements, mise à jour Windows</span>
          </li>
          <li className="flex items-start">
            <span className="text-green-600 mr-3">✓</span>
            <span>Export au format HTML, JSON et CSV pour analyse</span>
          </li>
          <li className="flex items-start">
            <span className="text-green-600 mr-3">✓</span>
            <span>Recommandations d'améliorations basées sur l'analyse</span>
          </li>
        </ul>
      </div>

      {/* Note importante */}
      <div className="card bg-blue-50 border-blue-200 mb-8">
        <div className="flex items-start space-x-3">
          <Activity className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
          <div>
            <h4 className="font-semibold text-blue-900 mb-1">Note</h4>
            <p className="text-sm text-blue-800">
              Le script de diagnostic ne modifie rien sur le système. Il analyse uniquement l'état actuel et génère un rapport détaillé. L'exécution prend environ 2-5 minutes.
            </p>
          </div>
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center justify-between">
        <button
          onClick={() => navigate('/optimizations')}
          className="btn-secondary flex items-center"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Retour
        </button>
        <button
          onClick={() => navigate('/generate')}
          className="btn-primary flex items-center"
        >
          Continuer
          <ArrowRight className="w-4 h-4 ml-2" />
        </button>
      </div>
    </div>
  );
};

export default Diagnostic;
