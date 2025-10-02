import React from 'react';
import { Code, Headphones, Server, ChevronRight, CodeSquare, Package } from 'lucide-react';

const PROFILE_ICONS = {
  DEV_DOTNET: Code,
  DEV_WINDEV: CodeSquare,
  TENOR: Headphones,
  SI: Server,
};

const PROFILE_COLORS = {
  DEV_DOTNET: {
    bg: 'bg-blue-100',
    hover: 'group-hover:bg-blue-200',
    text: 'text-blue-600',
    badge: 'bg-blue-100 text-blue-700',
    border: 'hover:border-blue-300'
  },
  DEV_WINDEV: {
    bg: 'bg-purple-100',
    hover: 'group-hover:bg-purple-200',
    text: 'text-purple-600',
    badge: 'bg-purple-100 text-purple-700',
    border: 'hover:border-purple-300'
  },
  TENOR: {
    bg: 'bg-orange-100',
    hover: 'group-hover:bg-orange-200',
    text: 'text-orange-600',
    badge: 'bg-orange-100 text-orange-700',
    border: 'hover:border-orange-300'
  },
  SI: {
    bg: 'bg-green-100',
    hover: 'group-hover:bg-green-200',
    text: 'text-green-600',
    badge: 'bg-green-100 text-green-700',
    border: 'hover:border-green-300'
  }
};

const ProfileCard = ({ profile, onSelect }) => {
  const Icon = PROFILE_ICONS[profile.id] || Code;
  const colors = PROFILE_COLORS[profile.id] || PROFILE_COLORS.DEV_DOTNET;

  return (
    <button
      onClick={() => onSelect(profile.id)}
      className={`card hover:shadow-md ${colors.border} transition-all duration-200 text-left w-full group`}
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-start space-x-4 flex-1">
          <div className={`${colors.bg} ${colors.hover} p-3 rounded-lg transition-colors`}>
            <Icon className={`w-6 h-6 ${colors.text}`} />
          </div>
          <div className="flex-1">
            <h3 className="text-lg font-semibold text-gray-900 mb-1">{profile.name}</h3>
            <p className="text-sm text-gray-600">{profile.description}</p>
          </div>
        </div>
        <ChevronRight className={`w-5 h-5 text-gray-400 ${colors.text} opacity-0 group-hover:opacity-100 group-hover:translate-x-1 transition-all flex-shrink-0 ml-2`} />
      </div>

      <div className="flex items-center justify-between pt-3 border-t border-gray-100">
        <div className="flex items-center space-x-4">
          <div className="flex items-center text-sm text-gray-600">
            <Package className="w-4 h-4 mr-1.5" />
            <span className="font-medium">{profile.apps_count}</span>
            <span className="ml-1">apps</span>
          </div>
        </div>
        <span className={`text-xs font-medium px-2.5 py-1 rounded-full ${colors.badge}`}>
          {profile.id}
        </span>
      </div>
    </button>
  );
};

export default ProfileCard;
