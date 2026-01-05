import React, { useState, useMemo, useRef, useEffect } from 'react';
import { Check, Search, ChevronDown, ChevronUp, Sparkles, Package, Plus, X } from 'lucide-react';

const AppItem = ({ app, isSelected, onToggle, variant = 'default', compact = false }) => {
  const appId = app.winget || app.url || app.name;

  return (
    <button
      onClick={() => onToggle(appId)}
      className={`
        flex items-center ${compact ? 'p-2' : 'p-3'} rounded-lg border transition-all duration-150 text-left w-full
        ${variant === 'suggestion' ? 'border-dashed' : ''}
        ${isSelected
          ? 'bg-blue-50 border-blue-300 ring-1 ring-blue-200'
          : 'bg-white border-gray-200 hover:border-gray-300 hover:bg-gray-50'
        }
      `}
    >
      <div className={`
        ${compact ? 'w-4 h-4' : 'w-5 h-5'} rounded border-2 mr-3 flex items-center justify-center flex-shrink-0 transition-colors
        ${isSelected ? 'bg-blue-500 border-blue-500' : 'border-gray-300'}
      `}>
        {isSelected && <Check className={`${compact ? 'w-2.5 h-2.5' : 'w-3 h-3'} text-white`} />}
      </div>

      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className={`font-medium text-gray-900 truncate ${compact ? 'text-sm' : ''}`}>{app.name}</span>
          {variant === 'suggestion' && (
            <Sparkles className="w-3.5 h-3.5 text-amber-500 flex-shrink-0" />
          )}
        </div>
        {!compact && app.description && (
          <p className="text-xs text-gray-500 truncate mt-0.5">{app.description}</p>
        )}
      </div>

      <div className="flex items-center gap-2 ml-2 flex-shrink-0">
        {app.category && (
          <span className={`${compact ? 'text-[10px]' : 'text-xs'} px-2 py-0.5 bg-gray-100 text-gray-600 rounded`}>
            {app.category}
          </span>
        )}
        {!compact && app.size && (
          <span className="text-xs text-gray-400">{app.size}</span>
        )}
      </div>
    </button>
  );
};

const AppSelector = ({
  profile,
  apps,
  selectedApps = [],
  onToggleApp,
}) => {
  const [searchQuery, setSearchQuery] = useState('');
  const [showSearch, setShowSearch] = useState(false);
  const [showCatalog, setShowCatalog] = useState(false);
  const [expandedCategories, setExpandedCategories] = useState({});
  const searchInputRef = useRef(null);

  // Focus sur le champ de recherche quand on l'ouvre
  useEffect(() => {
    if (showSearch && searchInputRef.current) {
      searchInputRef.current.focus();
    }
  }, [showSearch]);

  // Résoudre les références d'apps
  const resolveApp = (appRef) => {
    if (appRef.ref && apps.common_apps?.[appRef.ref]) {
      return { ...apps.common_apps[appRef.ref], ...appRef, ref: undefined };
    }
    return appRef;
  };

  // Apps du profil sélectionné
  const profileApps = useMemo(() => {
    if (!profile || !apps?.profiles?.[profile]) return [];
    return (apps.profiles[profile].apps || []).map(resolveApp);
  }, [profile, apps]);

  // Suggestions pour ce profil
  const suggestions = useMemo(() => {
    if (!profile || !apps?.profiles?.[profile]?.suggestions) return [];

    const suggestionIds = apps.profiles[profile].suggestions;
    const result = [];

    suggestionIds.forEach(id => {
      if (apps.common_apps?.[id]) {
        result.push(apps.common_apps[id]);
      }
    });

    suggestionIds.forEach(id => {
      const optApp = apps.optional?.find(a => (a.winget || a.url || a.name) === id);
      if (optApp && !result.find(r => (r.winget || r.url || r.name) === id)) {
        result.push(optApp);
      }
    });

    return result;
  }, [profile, apps]);

  // Toutes les apps disponibles
  const allAvailableApps = useMemo(() => {
    const result = [];
    const seen = new Set();

    if (apps?.common_apps) {
      Object.values(apps.common_apps).forEach(app => {
        const id = app.winget || app.url || app.name;
        if (!seen.has(id)) {
          seen.add(id);
          result.push(app);
        }
      });
    }

    if (apps?.profiles) {
      Object.values(apps.profiles).forEach(p => {
        (p.apps || []).forEach(appRef => {
          const app = resolveApp(appRef);
          const id = app.winget || app.url || app.name;
          if (!seen.has(id)) {
            seen.add(id);
            result.push(app);
          }
        });
      });
    }

    if (apps?.optional) {
      apps.optional.forEach(app => {
        const id = app.winget || app.url || app.name;
        if (!seen.has(id)) {
          seen.add(id);
          result.push(app);
        }
      });
    }

    return result;
  }, [apps]);

  // Filtrer par recherche
  const searchResults = useMemo(() => {
    if (!searchQuery.trim()) return [];
    const query = searchQuery.toLowerCase();
    return allAvailableApps.filter(app =>
      app.name?.toLowerCase().includes(query) ||
      app.description?.toLowerCase().includes(query) ||
      app.winget?.toLowerCase().includes(query)
    ).slice(0, 10); // Limiter à 10 résultats
  }, [allAvailableApps, searchQuery]);

  // Grouper par catégorie pour le catalogue
  const catalogByCategory = useMemo(() => {
    const groups = {};
    allAvailableApps.forEach(app => {
      const cat = app.category || 'Autres';
      if (!groups[cat]) groups[cat] = [];
      groups[cat].push(app);
    });
    return groups;
  }, [allAvailableApps]);

  const toggleCategory = (category) => {
    setExpandedCategories(prev => ({
      ...prev,
      [category]: !prev[category]
    }));
  };

  const isAppSelected = (app) => {
    const appId = app.winget || app.url || app.name;
    return selectedApps.includes(appId);
  };

  const openSearch = () => {
    setShowSearch(true);
    setSearchQuery('');
  };

  const closeSearch = () => {
    setShowSearch(false);
    setSearchQuery('');
  };

  // Compter les apps sélectionnées
  const totalSelectedCount = selectedApps.length;

  if (!profile) {
    return (
      <div className="bg-gray-50 rounded-xl p-8 text-center">
        <Package className="w-12 h-12 text-gray-300 mx-auto mb-3" />
        <p className="text-gray-500">Sélectionnez un profil pour voir les applications</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header avec bouton Ajouter */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-lg font-semibold text-gray-900">Applications</h2>
          <p className="text-sm text-gray-500">
            {totalSelectedCount} application{totalSelectedCount > 1 ? 's' : ''} sélectionnée{totalSelectedCount > 1 ? 's' : ''}
          </p>
        </div>
        <button
          onClick={openSearch}
          className="btn-primary flex items-center gap-2 text-sm"
        >
          <Plus className="w-4 h-4" />
          Ajouter une app
        </button>
      </div>

      {/* Barre de recherche (quand ouverte) */}
      {showSearch && (
        <div className="bg-white border border-gray-200 rounded-xl p-4 shadow-lg">
          <div className="flex items-center gap-3 mb-3">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                ref={searchInputRef}
                type="text"
                placeholder="Rechercher une application (ex: Chrome, Git, Docker...)"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2.5 border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm"
              />
            </div>
            <button
              onClick={closeSearch}
              className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
            >
              <X className="w-5 h-5 text-gray-500" />
            </button>
          </div>

          {/* Résultats de recherche directs */}
          {searchQuery.trim() && (
            <div className="space-y-2 max-h-80 overflow-y-auto">
              {searchResults.length > 0 ? (
                searchResults.map((app, idx) => (
                  <AppItem
                    key={app.winget || app.url || app.name || idx}
                    app={app}
                    isSelected={isAppSelected(app)}
                    onToggle={(appId) => {
                      onToggleApp(appId);
                    }}
                    compact
                  />
                ))
              ) : (
                <p className="text-sm text-gray-500 text-center py-4">
                  Aucune application trouvée pour "{searchQuery}"
                </p>
              )}
            </div>
          )}

          {/* Message initial */}
          {!searchQuery.trim() && (
            <p className="text-sm text-gray-500 text-center py-4">
              Tapez pour rechercher parmi {allAvailableApps.length} applications disponibles
            </p>
          )}
        </div>
      )}

      {/* Apps du profil */}
      <div className="space-y-3">
        <h3 className="text-sm font-medium text-gray-700 flex items-center gap-2">
          <Package className="w-4 h-4" />
          Applications du profil
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
          {profileApps.map((app, idx) => (
            <AppItem
              key={app.winget || app.url || app.name || idx}
              app={app}
              isSelected={isAppSelected(app)}
              onToggle={onToggleApp}
            />
          ))}
        </div>
      </div>

      {/* Suggestions */}
      {suggestions.length > 0 && (
        <div className="space-y-3">
          <h3 className="text-sm font-medium text-gray-700 flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-amber-500" />
            Suggestions pour vous
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
            {suggestions.map((app, idx) => (
              <AppItem
                key={app.winget || app.url || app.name || idx}
                app={app}
                isSelected={isAppSelected(app)}
                onToggle={onToggleApp}
                variant="suggestion"
              />
            ))}
          </div>
        </div>
      )}

      {/* Lien vers catalogue complet */}
      <div className="pt-2">
        <button
          onClick={() => setShowCatalog(!showCatalog)}
          className="text-sm text-gray-500 hover:text-gray-700 flex items-center gap-1"
        >
          {showCatalog ? (
            <>
              <ChevronUp className="w-4 h-4" />
              Masquer le catalogue complet
            </>
          ) : (
            <>
              <ChevronDown className="w-4 h-4" />
              Parcourir le catalogue complet ({allAvailableApps.length} apps)
            </>
          )}
        </button>
      </div>

      {/* Catalogue par catégorie */}
      {showCatalog && (
        <div className="space-y-2 pt-2">
          {Object.entries(catalogByCategory).sort(([a], [b]) => a.localeCompare(b)).map(([category, categoryApps]) => (
            <div key={category} className="border border-gray-200 rounded-lg overflow-hidden">
              <button
                onClick={() => toggleCategory(category)}
                className="w-full flex items-center justify-between p-3 bg-gray-50 hover:bg-gray-100 transition-colors"
              >
                <span className="font-medium text-gray-700">{category}</span>
                <div className="flex items-center gap-2">
                  <span className="text-sm text-gray-500">{categoryApps.length}</span>
                  {expandedCategories[category] ? (
                    <ChevronUp className="w-4 h-4 text-gray-400" />
                  ) : (
                    <ChevronDown className="w-4 h-4 text-gray-400" />
                  )}
                </div>
              </button>
              {expandedCategories[category] && (
                <div className="p-2 space-y-2">
                  {categoryApps.map((app, idx) => (
                    <AppItem
                      key={app.winget || app.url || app.name || idx}
                      app={app}
                      isSelected={isAppSelected(app)}
                      onToggle={onToggleApp}
                      compact
                    />
                  ))}
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default AppSelector;
