import React, { useState } from 'react';
import { ChevronDown, ChevronUp, Shield, Zap, Palette, Check } from 'lucide-react';

const MODULE_CONFIG = {
  debloat: {
    name: 'Nettoyage Windows',
    description: 'Supprime les applications préinstallées et bloatwares',
    icon: Shield,
    color: 'red',
    options: [
      { key: 'enabled', label: 'Activer le nettoyage', description: 'Supprime les apps inutiles de Windows' },
    ]
  },
  performance: {
    name: 'Optimisations Performance',
    description: 'Configure Windows pour de meilleures performances',
    icon: Zap,
    color: 'amber',
    options: [
      { key: 'enabled', label: 'Activer les optimisations', description: 'Active toutes les optimisations de performance' },
      { key: 'PageFile', label: 'Fichier d\'échange', description: 'Optimise la gestion de la mémoire virtuelle' },
      { key: 'PowerPlan', label: 'Plan d\'alimentation', description: 'Active le mode haute performance' },
      { key: 'StartupPrograms', label: 'Programmes au démarrage', description: 'Désactive les programmes inutiles au démarrage' },
      { key: 'Network', label: 'Réseau', description: 'Optimise les paramètres réseau' },
      { key: 'VisualEffects', label: 'Effets visuels', description: 'Réduit les animations pour plus de fluidité' },
    ]
  },
  ui: {
    name: 'Interface utilisateur',
    description: 'Personnalise l\'apparence et le comportement de Windows',
    icon: Palette,
    color: 'blue',
    options: [
      { key: 'enabled', label: 'Activer les personnalisations', description: 'Active toutes les options UI' },
      { key: 'DarkMode', label: 'Mode sombre', description: 'Active le thème sombre de Windows' },
      { key: 'ShowFileExtensions', label: 'Extensions de fichiers', description: 'Affiche les extensions dans l\'explorateur' },
      { key: 'ShowFullPath', label: 'Chemin complet', description: 'Affiche le chemin complet dans la barre de titre' },
      { key: 'ShowHiddenFiles', label: 'Fichiers cachés', description: 'Affiche les fichiers et dossiers cachés' },
      { key: 'ShowThisPC', label: 'Ce PC sur le bureau', description: 'Ajoute l\'icône Ce PC sur le bureau' },
      { key: 'ShowRecycleBin', label: 'Corbeille sur le bureau', description: 'Affiche la corbeille sur le bureau' },
      { key: 'TaskbarAlignLeft', label: 'Barre des tâches à gauche', description: 'Aligne les icônes de la barre à gauche (Win 11)' },
      { key: 'Windows10ContextMenu', label: 'Menu contextuel classique', description: 'Restaure l\'ancien menu clic-droit (Win 11)' },
      { key: 'HideWidgets', label: 'Masquer les widgets', description: 'Cache le bouton widgets de la barre des tâches' },
      { key: 'HideTaskView', label: 'Masquer la vue des tâches', description: 'Cache le bouton vue des tâches' },
      { key: 'EnableEndTask', label: 'Fin de tâche dans la barre', description: 'Ajoute "Fin de tâche" au clic-droit de la barre' },
      { key: 'RestartExplorer', label: 'Redémarrer Explorer', description: 'Redémarre l\'explorateur pour appliquer les changements' },
    ]
  }
};

const COLORS = {
  red: {
    bg: 'bg-red-50',
    border: 'border-red-200',
    icon: 'text-red-500',
    toggle: 'bg-red-500',
  },
  amber: {
    bg: 'bg-amber-50',
    border: 'border-amber-200',
    icon: 'text-amber-500',
    toggle: 'bg-amber-500',
  },
  blue: {
    bg: 'bg-blue-50',
    border: 'border-blue-200',
    icon: 'text-blue-500',
    toggle: 'bg-blue-500',
  },
};

const Toggle = ({ checked, onChange, color = 'blue' }) => (
  <button
    type="button"
    onClick={() => onChange(!checked)}
    className={`
      relative inline-flex h-6 w-11 items-center rounded-full transition-colors
      ${checked ? COLORS[color]?.toggle || 'bg-blue-500' : 'bg-gray-200'}
    `}
  >
    <span
      className={`
        inline-block h-4 w-4 transform rounded-full bg-white transition-transform shadow-sm
        ${checked ? 'translate-x-6' : 'translate-x-1'}
      `}
    />
  </button>
);

const Checkbox = ({ checked, onChange, label, description, disabled = false }) => (
  <label className={`flex items-start gap-3 p-2 rounded-lg hover:bg-gray-50 cursor-pointer ${disabled ? 'opacity-50' : ''}`}>
    <div className="pt-0.5">
      <div
        onClick={(e) => {
          if (!disabled) {
            e.preventDefault();
            onChange(!checked);
          }
        }}
        className={`
          w-5 h-5 rounded border-2 flex items-center justify-center transition-colors cursor-pointer
          ${checked ? 'bg-blue-500 border-blue-500' : 'border-gray-300 bg-white'}
          ${disabled ? 'cursor-not-allowed' : ''}
        `}
      >
        {checked && <Check className="w-3 h-3 text-white" />}
      </div>
    </div>
    <div className="flex-1">
      <span className="text-sm font-medium text-gray-700">{label}</span>
      {description && (
        <p className="text-xs text-gray-500 mt-0.5">{description}</p>
      )}
    </div>
  </label>
);

const ModuleAccordion = ({ moduleKey, config, values, onChange }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const moduleConfig = MODULE_CONFIG[moduleKey];
  if (!moduleConfig) return null;

  const Icon = moduleConfig.icon;
  const colors = COLORS[moduleConfig.color] || COLORS.blue;
  const isEnabled = values?.enabled !== false;

  // Compter les options activées
  const enabledCount = moduleConfig.options
    .filter(opt => opt.key !== 'enabled')
    .filter(opt => values?.[opt.key] !== false).length;
  const totalOptions = moduleConfig.options.filter(opt => opt.key !== 'enabled').length;

  return (
    <div className={`border rounded-xl overflow-hidden ${isEnabled ? colors.border : 'border-gray-200'}`}>
      {/* Header */}
      <div
        className={`flex items-center justify-between p-4 cursor-pointer transition-colors ${isEnabled ? colors.bg : 'bg-gray-50'}`}
        onClick={() => setIsExpanded(!isExpanded)}
      >
        <div className="flex items-center gap-3">
          <div className={`p-2 rounded-lg ${isEnabled ? 'bg-white' : 'bg-gray-100'}`}>
            <Icon className={`w-5 h-5 ${isEnabled ? colors.icon : 'text-gray-400'}`} />
          </div>
          <div>
            <h3 className="font-medium text-gray-900">{moduleConfig.name}</h3>
            <p className="text-sm text-gray-500">{moduleConfig.description}</p>
          </div>
        </div>

        <div className="flex items-center gap-4">
          {isEnabled && totalOptions > 0 && (
            <span className="text-sm text-gray-500">
              {enabledCount}/{totalOptions} options
            </span>
          )}
          <Toggle
            checked={isEnabled}
            onChange={(val) => onChange({ ...values, enabled: val })}
            color={moduleConfig.color}
          />
          <div className="p-1">
            {isExpanded ? (
              <ChevronUp className="w-5 h-5 text-gray-400" />
            ) : (
              <ChevronDown className="w-5 h-5 text-gray-400" />
            )}
          </div>
        </div>
      </div>

      {/* Options */}
      {isExpanded && (
        <div className="p-4 border-t border-gray-100 bg-white">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-1">
            {moduleConfig.options
              .filter(opt => opt.key !== 'enabled')
              .map(option => (
                <Checkbox
                  key={option.key}
                  checked={values?.[option.key] !== false}
                  onChange={(val) => onChange({ ...values, [option.key]: val })}
                  label={option.label}
                  description={option.description}
                  disabled={!isEnabled}
                />
              ))}
          </div>
        </div>
      )}
    </div>
  );
};

const OptionsAccordion = ({ modules, values, onChange }) => {
  // Compter les modules activés
  const enabledModules = Object.entries(values || {})
    .filter(([key, val]) => val?.enabled !== false)
    .length;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-gray-900">Options d'optimisation</h2>
          <p className="text-sm text-gray-500">
            {enabledModules} module{enabledModules > 1 ? 's' : ''} activé{enabledModules > 1 ? 's' : ''}
          </p>
        </div>
      </div>

      <div className="space-y-3">
        {Object.keys(MODULE_CONFIG).map(moduleKey => (
          <ModuleAccordion
            key={moduleKey}
            moduleKey={moduleKey}
            config={modules?.[moduleKey]}
            values={values?.[moduleKey]}
            onChange={(newValues) => onChange(moduleKey, newValues)}
          />
        ))}
      </div>
    </div>
  );
};

export default OptionsAccordion;
