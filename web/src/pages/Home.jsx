import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Package, Zap, Activity, ChevronRight } from 'lucide-react';

const Home = () => {
  const navigate = useNavigate();

  const spaces = [
    {
      id: 'installation',
      icon: Package,
      title: 'Installation',
      description: 'Choisissez un profil et sélectionnez les applications à installer',
      color: {
        bg: 'bg-blue-50',
        border: 'border-blue-200',
        iconBg: 'bg-blue-100',
        iconText: 'text-blue-600',
        hoverBorder: 'hover:border-blue-400'
      },
      features: [
        'Profils prédéfinis (DEV .NET, DEV WinDev, TENOR, SI)',
        'Mode personnalisé avec toutes les apps',
        '11 applications Master + apps par profil',
        'Installation automatique via Winget'
      ],
      path: '/installation'
    },
    {
      id: 'optimizations',
      icon: Zap,
      title: 'Optimisations',
      description: 'Optimisez les performances et personnalisez l\'interface Windows',
      color: {
        bg: 'bg-amber-50',
        border: 'border-amber-200',
        iconBg: 'bg-amber-100',
        iconText: 'text-amber-600',
        hoverBorder: 'hover:border-amber-400'
      },
      features: [
        'Debloat Windows (suppression bloatware)',
        'Optimisations performance (PageFile, PowerPlan...)',
        'Personnalisation UI (Dark mode, extensions...)',
        'Désactivation télémétrie et services inutiles'
      ],
      path: '/optimizations'
    },
    {
      id: 'diagnostic',
      icon: Activity,
      title: 'Diagnostic',
      description: 'Analysez l\'état du système et générez un rapport complet',
      color: {
        bg: 'bg-green-50',
        border: 'border-green-200',
        iconBg: 'bg-green-100',
        iconText: 'text-green-600',
        hoverBorder: 'hover:border-green-400'
      },
      features: [
        'État Windows et matériel',
        'Liste des applications installées',
        'Vérification des optimisations',
        'Détection de problèmes et rapport'
      ],
      path: '/diagnostic'
    }
  ];

  return (
    <div className="container mx-auto px-4 py-12">
      {/* Hero Section */}
      <div className="text-center mb-16">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          PostBootSetup v5.2
        </h1>
        <p className="text-xl text-gray-600 max-w-3xl mx-auto">
          Choisissez l'espace qui correspond à vos besoins. Vous pourrez générer un script combiné ou des scripts séparés à la fin.
        </p>
      </div>

      {/* 3 Espaces */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 mb-12">
        {spaces.map((space) => {
          const Icon = space.icon;
          return (
            <button
              key={space.id}
              onClick={() => navigate(space.path)}
              className={`card ${space.color.bg} ${space.color.border} ${space.color.hoverBorder} hover:shadow-lg transition-all duration-200 text-left group`}
            >
              {/* Header */}
              <div className="flex items-start justify-between mb-6">
                <div className={`${space.color.iconBg} p-4 rounded-xl`}>
                  <Icon className={`w-8 h-8 ${space.color.iconText}`} />
                </div>
                <ChevronRight className={`w-6 h-6 text-gray-400 ${space.color.iconText} opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all`} />
              </div>

              {/* Title */}
              <h2 className="text-2xl font-bold text-gray-900 mb-3">
                {space.title}
              </h2>

              {/* Description */}
              <p className="text-gray-600 mb-6">
                {space.description}
              </p>

              {/* Features */}
              <ul className="space-y-2">
                {space.features.map((feature, idx) => (
                  <li key={idx} className="flex items-start text-sm text-gray-700">
                    <span className={`${space.color.iconText} mr-2 flex-shrink-0`}>•</span>
                    <span>{feature}</span>
                  </li>
                ))}
              </ul>
            </button>
          );
        })}
      </div>

      {/* Info Section */}
      <div className="card bg-gray-50 max-w-4xl mx-auto">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">
          💡 Comment ça fonctionne ?
        </h3>
        <ol className="space-y-3 text-gray-700">
          <li className="flex items-start">
            <span className="font-semibold mr-2 text-primary-600">1.</span>
            <span>Parcourez les espaces qui vous intéressent (Installation, Optimisations, Diagnostic)</span>
          </li>
          <li className="flex items-start">
            <span className="font-semibold mr-2 text-primary-600">2.</span>
            <span>Configurez vos choix dans chaque espace (profils, optimisations, diagnostics)</span>
          </li>
          <li className="flex items-start">
            <span className="font-semibold mr-2 text-primary-600">3.</span>
            <span>À la fin, choisissez le type de script : <strong>Combiné</strong> (Installation + Optimisations), ou <strong>Séparé</strong> (Installation seule, Optimisations seules, Diagnostic seul)</span>
          </li>
          <li className="flex items-start">
            <span className="font-semibold mr-2 text-primary-600">4.</span>
            <span>Téléchargez et exécutez le(s) script(s) sur votre machine Windows cible</span>
          </li>
        </ol>
      </div>
    </div>
  );
};

export default Home;
