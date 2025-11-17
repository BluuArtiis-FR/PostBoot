import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useConfig } from '../context/ConfigContext';
import { ArrowLeft, ArrowRight, Zap, Palette, Trash2, Info, ChevronDown, ChevronUp, AlertTriangle } from 'lucide-react';

const Optimizations = () => {
  const navigate = useNavigate();
  const { modules, userConfig, updateModule } = useConfig();
  const [showTooltip, setShowTooltip] = useState(null);
  const [expandedDebloat, setExpandedDebloat] = useState(false);

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
      <div className="card mb-6 border-2 border-red-200">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-start space-x-3 flex-1">
            <div className="bg-red-100 p-2 rounded-lg">
              <Trash2 className="w-6 h-6 text-red-600" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <h2 className="text-xl font-semibold text-gray-900">
                  Debloat Windows
                </h2>
                <span className="text-xs bg-red-100 text-red-700 px-3 py-1 rounded-full font-semibold">
                  OBLIGATOIRE
                </span>
              </div>
              <p className="text-sm text-gray-600">
                Suppression des applications préinstallées inutiles et optimisation de la confidentialité
              </p>
            </div>
          </div>
          <button
            onClick={() => setExpandedDebloat(!expandedDebloat)}
            className="ml-4 text-gray-500 hover:text-gray-700 p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            {expandedDebloat ? <ChevronUp className="w-5 h-5" /> : <ChevronDown className="w-5 h-5" />}
          </button>
        </div>

        <div className="bg-gradient-to-br from-red-50 to-orange-50 border border-red-200 rounded-lg p-4 mb-4">
          <div className="flex items-start space-x-3">
            <AlertTriangle className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
            <div>
              <h3 className="font-semibold text-gray-900 mb-1">🛡️ Optimisations principales</h3>
              <ul className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm text-gray-700">
                <li className="flex items-start">
                  <span className="text-red-600 mr-2 font-bold">✓</span>
                  <span><strong>53 apps bloatware</strong> supprimées (Xbox, Candy Crush, TikTok...)</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-600 mr-2 font-bold">✓</span>
                  <span><strong>Télémétrie Microsoft</strong> désactivée (tracking, diagnostics)</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-600 mr-2 font-bold">✓</span>
                  <span><strong>Fonctionnalités IA</strong> bloquées (Copilot, Recall, Click to Do)</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-600 mr-2 font-bold">✓</span>
                  <span><strong>Télémétrie tierce</strong> (Adobe, Chrome, VS Code, Nvidia)</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-600 mr-2 font-bold">✓</span>
                  <span><strong>Services inutiles</strong> (DiagTrack, RetailDemo, WAP Push...)</span>
                </li>
                <li className="flex items-start">
                  <span className="text-red-600 mr-2 font-bold">✓</span>
                  <span><strong>Gain d'espace</strong> : 2-5 GB libérés</span>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {expandedDebloat && (
          <div className="space-y-4 border-t pt-4">
            {/* Section Apps Microsoft */}
            <div className="bg-white border border-gray-200 rounded-lg p-4">
              <h4 className="font-semibold text-gray-900 mb-3 flex items-center">
                <span className="bg-blue-100 text-blue-700 px-2 py-1 rounded text-xs mr-2">MICROSOFT</span>
                Applications préinstallées supprimées (32 apps)
              </h4>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2 text-sm text-gray-600">
                <span>• Bing (News, Sports, Weather...)</span>
                <span>• Applications 3D (Builder, Viewer)</span>
                <span>• Xbox (Game Bar, DVR, TCUI...)</span>
                <span>• Communication (People, Messaging)</span>
                <span>• Office Hub, OneNote, Sway</span>
                <span>• Clipchamp, Teams Consumer</span>
                <span>• Cortana, Quick Assist</span>
                <span>• Maps, Alarms, Camera...</span>
              </div>
            </div>

            {/* Section Apps tierces */}
            <div className="bg-white border border-gray-200 rounded-lg p-4">
              <h4 className="font-semibold text-gray-900 mb-3 flex items-center">
                <span className="bg-purple-100 text-purple-700 px-2 py-1 rounded text-xs mr-2">TIERCES</span>
                Applications bloatware tierces (38 apps)
              </h4>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2 text-sm text-gray-600">
                <span>• TikTok, Instagram, Facebook</span>
                <span>• LinkedIn, Twitter</span>
                <span>• Spotify, Netflix, Prime Video</span>
                <span>• Candy Crush (Saga, Friends...)</span>
                <span>• Bubble Witch, Hidden City</span>
                <span>• Adobe Photoshop Express</span>
                <span>• Duolingo, Flipboard...</span>
              </div>
            </div>

            {/* Section IA */}
            <div className="bg-white border border-orange-200 rounded-lg p-4">
              <h4 className="font-semibold text-gray-900 mb-3 flex items-center">
                <span className="bg-orange-100 text-orange-700 px-2 py-1 rounded text-xs mr-2">IA WIN11 24H2+</span>
                Fonctionnalités IA invasives désactivées
              </h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm text-gray-700">
                <div className="flex items-start">
                  <span className="text-orange-600 mr-2">🤖</span>
                  <span><strong>Windows Recall</strong> - Enregistrement écran IA désactivé</span>
                </div>
                <div className="flex items-start">
                  <span className="text-orange-600 mr-2">🤖</span>
                  <span><strong>Click to Do</strong> - Analyse IA texte/image bloquée</span>
                </div>
                <div className="flex items-start">
                  <span className="text-orange-600 mr-2">🤖</span>
                  <span><strong>Edge AI</strong> - Suggestions IA Edge désactivées</span>
                </div>
                <div className="flex items-start">
                  <span className="text-orange-600 mr-2">🤖</span>
                  <span><strong>Copilot</strong> - Assistant IA Windows désactivé</span>
                </div>
              </div>
            </div>

            {/* Section Confidentialité */}
            <div className="bg-white border border-green-200 rounded-lg p-4">
              <h4 className="font-semibold text-gray-900 mb-3 flex items-center">
                <span className="bg-green-100 text-green-700 px-2 py-1 rounded text-xs mr-2">VIE PRIVÉE</span>
                Télémétrie et tracking désactivés
              </h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm text-gray-700">
                <span>• Activity History (historique activités)</span>
                <span>• App Launch Tracking (suivi apps)</span>
                <span>• Bing Search dans Windows Search</span>
                <span>• Windows Spotlight (écran verrouillage)</span>
                <span>• Publicités (Paramètres, menu Démarrer)</span>
                <span>• ID publicitaire personnalisé</span>
                <span>• Télémétrie Adobe/Chrome/VS Code</span>
                <span>• Télémétrie Nvidia GeForce Experience</span>
              </div>
            </div>

            {/* Apps préservées */}
            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
              <h4 className="font-semibold text-blue-900 mb-2 flex items-center">
                <span className="text-blue-600 mr-2">ℹ️</span>
                Applications préservées (usage entreprise)
              </h4>
              <p className="text-sm text-blue-700">
                <strong>Microsoft Store</strong> (requis pour mises à jour), <strong>OneDrive</strong> (stockage cloud),
                <strong> Microsoft Edge</strong> (navigateur système), <strong>Windows Terminal</strong> (développeurs)
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Module Performance */}
      <div className="card mb-6 border-2 border-blue-200">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-start space-x-3 flex-1">
            <div className="bg-blue-100 p-2 rounded-lg">
              <Zap className="w-6 h-6 text-blue-600" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <h2 className="text-xl font-semibold text-gray-900">
                  Optimisations Performance
                </h2>
                <span className="text-xs bg-green-100 text-green-700 px-3 py-1 rounded-full font-semibold">
                  ⭐ RECOMMANDÉ
                </span>
              </div>
              <p className="text-sm text-gray-600">
                Améliorez les performances système et réduisez la latence réseau
              </p>
            </div>
          </div>
          <label className="flex items-center cursor-pointer ml-4">
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
          <div className="border-t pt-4">
            {/* Layout en 2 colonnes sur desktop */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-3 mb-3">
              {/* Option 1: Effets visuels */}
              <div className="border border-gray-200 rounded-lg p-4 hover:border-blue-300 transition-colors bg-white">
              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={userConfig.modules.performance.VisualEffects || false}
                  onChange={(e) => updateModule('performance', { VisualEffects: e.target.checked })}
                  className="checkbox mt-1"
                />
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="font-semibold text-gray-900">Désactiver effets visuels</span>
                    <span className="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded">Performance graphique</span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">
                    Améliore les performances graphiques en désactivant animations et transparence
                  </p>
                  <div className="bg-gray-50 rounded p-3 text-xs text-gray-600 space-y-1">
                    <p>• <strong>Animations système</strong> : Désactive les effets de transition</p>
                    <p>• <strong>Transparence</strong> : Désactive Acrylic/Blur (économie GPU)</p>
                    <p>• <strong>Impact</strong> : Interface plus réactive, -10-20% usage GPU</p>
                  </div>
                </div>
              </label>
              </div>

              {/* Option 2: Programmes démarrage */}
              <div className="border-2 border-green-200 rounded-lg p-4 hover:border-green-300 transition-colors bg-green-50">
              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={userConfig.modules.performance.StartupPrograms || false}
                  onChange={(e) => updateModule('performance', { StartupPrograms: e.target.checked })}
                  className="checkbox mt-1"
                />
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="font-semibold text-gray-900">Désactiver programmes au démarrage</span>
                    <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded font-semibold">
                      ⭐ RECOMMANDÉ
                    </span>
                  </div>
                  <p className="text-sm text-gray-700 mb-2">
                    Accélère significativement le temps de boot Windows
                  </p>
                  <div className="bg-white rounded p-3 text-xs text-gray-600 space-y-1">
                    <p>• <strong>Xbox Game Bar/DVR</strong> : Désactive complètement (non-gamers)</p>
                    <p>• <strong>Fast Startup</strong> : Désactivé (meilleur pour SSD, dual-boot)</p>
                    <p>• <strong>Hibernation</strong> : Supprimée (libère 4-8 GB)</p>
                    <p>• <strong>Impact</strong> : Boot 30-50% plus rapide</p>
                  </div>
                </div>
              </label>
              </div>

              {/* Option 3: Réseau */}
              <div className="border border-gray-200 rounded-lg p-4 hover:border-blue-300 transition-colors bg-white">
              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={userConfig.modules.performance.Network || false}
                  onChange={(e) => updateModule('performance', { Network: e.target.checked })}
                  className="checkbox mt-1"
                />
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="font-semibold text-gray-900">Optimiser paramètres réseau</span>
                    <span className="text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded">Latence réduite</span>
                  </div>
                  <p className="text-sm text-gray-600 mb-2">
                    Améliore latence et débit réseau (gaming, streaming, navigation)
                  </p>
                  <div className="bg-gray-50 rounded p-3 text-xs text-gray-600 space-y-1">
                    <p>• <strong>Optimisation haut débit</strong> : Adapte Windows aux connexions rapides (fibre, câble)</p>
                    <p>• <strong>Network Throttling</strong> : Désactive limitation Windows (multimédias)</p>
                    <p>• <strong>Impact</strong> : -5-15ms latence, +10-20% débit</p>
                  </div>
                </div>
              </label>
              </div>

              {/* Option 4: Power Plan */}
              <div className="border-2 border-green-200 rounded-lg p-4 hover:border-green-300 transition-colors bg-green-50">
              <label className="flex items-start space-x-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={userConfig.modules.performance.PowerPlan || false}
                  onChange={(e) => updateModule('performance', { PowerPlan: e.target.checked })}
                  className="checkbox mt-1"
                />
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <span className="font-semibold text-gray-900">Plan d'alimentation haute performance</span>
                    <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded font-semibold">
                      ⭐ RECOMMANDÉ
                    </span>
                  </div>
                  <p className="text-sm text-gray-700 mb-2">
                    Active les performances maximales du CPU (plan Ultimate Performance)
                  </p>
                  <div className="bg-white rounded p-3 text-xs text-gray-600 space-y-1">
                    <p>• <strong>Ultimate Performance</strong> : Plan caché Windows 10/11</p>
                    <p>• <strong>CPU</strong> : Fréquences max en permanence (no throttling)</p>
                    <p>• <strong>Latence</strong> : Réduit micro-latences système</p>
                    <p>• <strong>⚠️ Attention</strong> : Consommation électrique +15-30%</p>
                  </div>
                </div>
              </label>
              </div>
            </div>

            {/* Résumé performances - Pleine largeur */}
            <div className="bg-gradient-to-br from-blue-50 to-cyan-50 border border-blue-200 rounded-lg p-4">
              <div className="flex items-start space-x-3">
                <Zap className="w-5 h-5 text-blue-600 mt-0.5 flex-shrink-0" />
                <div>
                  <h4 className="font-semibold text-gray-900 mb-2">⚡ Gains de performance attendus</h4>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-2 text-sm text-gray-700">
                    <span>• Temps de boot : <strong>-30-50%</strong></span>
                    <span>• Espace disque libéré : <strong>4-8 GB</strong></span>
                    <span>• Latence réseau : <strong>-5-15ms</strong></span>
                    <span>• Réactivité interface : <strong>+20-40%</strong></span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Module UI */}
      <div className="card mb-8 border-2 border-purple-200">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-start space-x-3 flex-1">
            <div className="bg-purple-100 p-2 rounded-lg">
              <Palette className="w-6 h-6 text-purple-600" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <h2 className="text-xl font-semibold text-gray-900">
                  Personnalisation Interface
                </h2>
                <span className="text-xs bg-purple-100 text-purple-700 px-3 py-1 rounded-full font-semibold">
                  OPTIONNEL
                </span>
              </div>
              <p className="text-sm text-gray-600">
                Personnalisez l'apparence et le comportement de Windows (Explorateur, Bureau, Barre des tâches)
              </p>
            </div>
          </div>
          <label className="flex items-center cursor-pointer ml-4">
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
          <div className="border-t pt-4">
            {/* Layout en 2 colonnes sur desktop */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
              {/* Colonne 1: Explorateur */}
              <div className="bg-purple-50 border border-purple-200 rounded-lg p-3">
                <h3 className="font-semibold text-purple-900 mb-3 flex items-center">
                  <span className="bg-purple-200 text-purple-800 px-2 py-1 rounded text-xs mr-2">EXPLORATEUR</span>
                  Paramètres de l'explorateur
                </h3>

                <div className="space-y-3">
                {/* Afficher extensions */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <label className="flex items-start space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={userConfig.modules.ui.ShowFileExtensions || false}
                      onChange={(e) => updateModule('ui', { ShowFileExtensions: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-gray-900">Afficher extensions fichiers</span>
                        <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded">🔒 Sécurité</span>
                      </div>
                      <p className="text-sm text-gray-600">
                        Affiche les extensions (.exe, .pdf, .docx...) pour éviter les fichiers malveillants déguisés
                      </p>
                    </div>
                  </label>
                </div>

                {/* Afficher fichiers cachés */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <label className="flex items-start space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={userConfig.modules.ui.ShowHiddenFiles || false}
                      onChange={(e) => updateModule('ui', { ShowHiddenFiles: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-gray-900">Afficher fichiers cachés</span>
                        <span className="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded">⚙️ Avancé</span>
                      </div>
                      <p className="text-sm text-gray-600">
                        Affiche les fichiers et dossiers cachés par Windows (paramètres système, configuration...)
                      </p>
                    </div>
                  </label>
                </div>

                {/* Afficher chemin complet */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <label className="flex items-start space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={userConfig.modules.ui.ShowFullPath || false}
                      onChange={(e) => updateModule('ui', { ShowFullPath: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-gray-900">Afficher chemin complet</span>
                        <span className="text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded">📂 Productivité</span>
                      </div>
                      <p className="text-sm text-gray-600">
                        Affiche le chemin complet dans la barre d'adresse (ex: C:\Users\Nom\Documents)
                      </p>
                    </div>
                  </label>
                </div>
                </div>
              </div>

              {/* Colonne 2: Bureau */}
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-3">
                <h3 className="font-semibold text-blue-900 mb-3 flex items-center">
                  <span className="bg-blue-200 text-blue-800 px-2 py-1 rounded text-xs mr-2">BUREAU</span>
                  Apparence du bureau
                </h3>

                <div className="space-y-3">
                {/* Mode sombre */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <label className="flex items-start space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={userConfig.modules.ui.DarkMode || false}
                      onChange={(e) => updateModule('ui', { DarkMode: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-gray-900">Mode sombre</span>
                        <span className="text-xs bg-gray-800 text-white px-2 py-0.5 rounded">🌙 Confort</span>
                      </div>
                      <p className="text-sm text-gray-600">
                        Active le thème sombre pour le système et les applications (réduit fatigue oculaire)
                      </p>
                    </div>
                  </label>
                </div>

                {/* Icône Ce PC */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <label className="flex items-start space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={userConfig.modules.ui.ShowThisPC || false}
                      onChange={(e) => updateModule('ui', { ShowThisPC: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-gray-900">Icône Ce PC</span>
                        <span className="text-xs bg-blue-100 text-blue-600 px-2 py-0.5 rounded">💻 Accès rapide</span>
                      </div>
                      <p className="text-sm text-gray-600">
                        Affiche l'icône "Ce PC" sur le bureau pour accès rapide aux disques
                      </p>
                    </div>
                  </label>
                </div>

                {/* Icône Corbeille */}
                <div className="bg-white border border-gray-200 rounded-lg p-4">
                  <label className="flex items-start space-x-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={userConfig.modules.ui.ShowRecycleBin || false}
                      onChange={(e) => updateModule('ui', { ShowRecycleBin: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <span className="font-semibold text-gray-900">Icône Corbeille</span>
                        <span className="text-xs bg-green-100 text-green-600 px-2 py-0.5 rounded">🗑️ Classique</span>
                      </div>
                      <p className="text-sm text-gray-600">
                        Affiche l'icône Corbeille sur le bureau (récupération fichiers supprimés)
                      </p>
                    </div>
                  </label>
                </div>
                </div>
              </div>
            </div>
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
