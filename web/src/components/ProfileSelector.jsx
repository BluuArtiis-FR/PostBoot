import React from 'react';
import { Code, Terminal, Briefcase, Server, Settings, Check, Package } from 'lucide-react';

const PROFILE_ICONS = {
  code: Code,
  terminal: Terminal,
  briefcase: Briefcase,
  server: Server,
  settings: Settings,
};

const PROFILE_COLORS = {
  blue: {
    bg: 'bg-blue-50',
    bgSelected: 'bg-blue-100',
    border: 'border-blue-200',
    borderSelected: 'border-blue-500',
    text: 'text-blue-600',
    ring: 'ring-blue-500',
  },
  purple: {
    bg: 'bg-purple-50',
    bgSelected: 'bg-purple-100',
    border: 'border-purple-200',
    borderSelected: 'border-purple-500',
    text: 'text-purple-600',
    ring: 'ring-purple-500',
  },
  orange: {
    bg: 'bg-orange-50',
    bgSelected: 'bg-orange-100',
    border: 'border-orange-200',
    borderSelected: 'border-orange-500',
    text: 'text-orange-600',
    ring: 'ring-orange-500',
  },
  green: {
    bg: 'bg-green-50',
    bgSelected: 'bg-green-100',
    border: 'border-green-200',
    borderSelected: 'border-green-500',
    text: 'text-green-600',
    ring: 'ring-green-500',
  },
  gray: {
    bg: 'bg-gray-50',
    bgSelected: 'bg-gray-100',
    border: 'border-gray-200',
    borderSelected: 'border-gray-500',
    text: 'text-gray-600',
    ring: 'ring-gray-500',
  },
};

const ProfileCard = ({ profile, isSelected, onSelect, appsCount }) => {
  const Icon = PROFILE_ICONS[profile.icon] || Code;
  const colors = PROFILE_COLORS[profile.color] || PROFILE_COLORS.blue;

  return (
    <button
      onClick={() => onSelect(profile.id)}
      className={`
        relative p-4 rounded-xl border-2 transition-all duration-200 text-left w-full
        ${isSelected
          ? `${colors.bgSelected} ${colors.borderSelected} ring-2 ${colors.ring} ring-opacity-50`
          : `${colors.bg} ${colors.border} hover:border-opacity-70`
        }
      `}
    >
      {isSelected && (
        <div className={`absolute top-2 right-2 w-6 h-6 rounded-full ${colors.text} bg-white flex items-center justify-center shadow-sm`}>
          <Check className="w-4 h-4" />
        </div>
      )}

      <div className="flex items-center space-x-3 mb-2">
        <div className={`p-2 rounded-lg ${isSelected ? 'bg-white' : colors.bg}`}>
          <Icon className={`w-5 h-5 ${colors.text}`} />
        </div>
        <h3 className="font-semibold text-gray-900">{profile.name}</h3>
      </div>

      <p className="text-sm text-gray-600 mb-3 line-clamp-2">{profile.description}</p>

      <div className="flex items-center text-xs text-gray-500">
        <Package className="w-3.5 h-3.5 mr-1" />
        <span>{appsCount} applications</span>
      </div>
    </button>
  );
};

const ProfileSelector = ({ profiles, selectedProfile, onSelect, apps }) => {
  // Calculer le nombre d'apps pour chaque profil
  const getAppsCount = (profileId) => {
    if (!apps || !apps.profiles) return 0;
    const profileApps = apps.profiles[profileId]?.apps || [];
    // Compter les apps preselected
    return profileApps.filter(app => app.preselected).length;
  };

  // Ajouter le profil CUSTOM s'il n'existe pas dans la liste
  const allProfiles = [...profiles];
  const hasCustom = allProfiles.some(p => p.id === 'CUSTOM');
  if (!hasCustom && apps?.profiles?.CUSTOM) {
    allProfiles.push({
      id: 'CUSTOM',
      name: apps.profiles.CUSTOM.name || 'Personnalisé',
      description: apps.profiles.CUSTOM.description || 'Configuration personnalisable',
      icon: apps.profiles.CUSTOM.icon || 'settings',
      color: apps.profiles.CUSTOM.color || 'gray',
    });
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-lg font-semibold text-gray-900">Choisissez votre profil</h2>
        {selectedProfile && (
          <span className="text-sm text-gray-500">
            Profil sélectionné : <span className="font-medium text-gray-700">{selectedProfile}</span>
          </span>
        )}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        {allProfiles.map((profile) => (
          <ProfileCard
            key={profile.id}
            profile={{
              ...profile,
              icon: apps?.profiles?.[profile.id]?.icon || profile.icon || 'code',
              color: apps?.profiles?.[profile.id]?.color || profile.color || 'blue',
            }}
            isSelected={selectedProfile === profile.id}
            onSelect={onSelect}
            appsCount={getAppsCount(profile.id)}
          />
        ))}
      </div>
    </div>
  );
};

export default ProfileSelector;
