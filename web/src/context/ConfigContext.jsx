import React, { createContext, useContext, useState, useEffect } from 'react';
import { apiService } from '../services/api';

const ConfigContext = createContext();

export const useConfig = () => {
  const context = useContext(ConfigContext);
  if (!context) {
    throw new Error('useConfig must be used within a ConfigProvider');
  }
  return context;
};

export const ConfigProvider = ({ children }) => {
  // État global
  const [profiles, setProfiles] = useState([]);
  const [apps, setApps] = useState(null);
  const [modules, setModules] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Configuration utilisateur
  // Par défaut: optimisations cochées (l'utilisateur décoche si besoin)
  const [userConfig, setUserConfig] = useState({
    profile: null,
    custom_name: '',
    master_apps: [],
    profile_apps: [],
    optional_apps: [],
    modules: {
      debloat: { enabled: true },
      performance: {
        enabled: true,
        PageFile: true,
        PowerPlan: true,
        StartupPrograms: true,
        Network: true,
        VisualEffects: true,
      },
      ui: {
        enabled: true,
        DarkMode: true,
        ShowFileExtensions: true,
        ShowFullPath: true,
        ShowHiddenFiles: false,
        ShowThisPC: true,
        ShowRecycleBin: true,
        RestartExplorer: true,
        TaskbarPosition: 'Bottom',
        ThemeColor: '0078D7',
        // Windows 11 tweaks
        TaskbarAlignLeft: true,
        Windows10ContextMenu: true,
        HideWidgets: true,
        HideTaskView: true,
        EnableEndTask: true,
      },
    },
  });

  // Charger les données au démarrage
  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        const [profilesData, appsData, modulesData] = await Promise.all([
          apiService.getProfiles(),
          apiService.getApps(),
          apiService.getModules(),
        ]);

        console.log('API Response - Profiles:', profilesData);
        console.log('API Response - Apps:', appsData);
        console.log('API Response - Modules:', modulesData);

        setProfiles(profilesData.profiles || []);
        setApps(appsData.apps || null);
        setModules(modulesData.modules || null);
        setError(null);
      } catch (err) {
        console.error('Error fetching data:', err);
        console.error('Error details:', {
          message: err.message,
          response: err.response,
          stack: err.stack
        });
        setError(`Impossible de charger les données depuis l'API: ${err.message}`);
        // Set defaults to prevent infinite loading
        setApps({ master: [], profiles: {}, optional: [] });
        setProfiles([]);
        setModules({});
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // Résoudre une référence d'app
  const resolveApp = (appRef) => {
    if (appRef.ref && apps?.common_apps?.[appRef.ref]) {
      return { ...apps.common_apps[appRef.ref], ...appRef, ref: undefined };
    }
    return appRef;
  };

  // Obtenir l'ID d'une app (winget, url ou name)
  const getAppId = (app) => {
    const resolved = resolveApp(app);
    return resolved.winget || resolved.url || resolved.name;
  };

  // Sélectionner un profil
  const selectProfile = (profileId) => {
    if (!apps) return;

    // Mode Custom (profileId = null ou 'CUSTOM')
    if (profileId === null || profileId === 'CUSTOM') {
      setUserConfig({
        profile: profileId,
        custom_name: 'Configuration personnalisée',
        master_apps: apps.master?.map(app => getAppId(app)) || [],
        profile_apps: [],
        optional_apps: [],
        modules: {
          debloat: { enabled: true },
          performance: {
            enabled: true,
            PageFile: true,
            PowerPlan: true,
            StartupPrograms: true,
            Network: true,
            VisualEffects: true,
          },
          ui: {
            enabled: true,
            DarkMode: true,
            ShowFileExtensions: true,
            ShowFullPath: true,
            ShowHiddenFiles: false,
            ShowThisPC: true,
            ShowRecycleBin: true,
            RestartExplorer: true,
            TaskbarPosition: 'Bottom',
            ThemeColor: '0078D7',
            TaskbarAlignLeft: true,
            Windows10ContextMenu: true,
            HideWidgets: true,
            HideTaskView: true,
            EnableEndTask: true,
          },
        },
      });
      return;
    }

    // Mode profil prédéfini
    const profile = profiles.find((p) => p.id === profileId);
    if (!profile) return;

    // Charger les apps du profil
    const profileApps = apps.profiles[profileId]?.apps || [];

    // Déterminer si le profil permet l'édition des apps master
    const allowMasterEdit = apps.profiles[profileId]?.allowMasterEdit || false;

    // Pré-sélectionner les apps master (toutes dans un profil prédéfini)
    const preselectedMasterApps = allowMasterEdit
      ? apps.master?.filter(app => app.preselected).map(app => getAppId(app)) || []
      : apps.master?.map(app => getAppId(app)) || [];

    // Pré-sélectionner les apps du profil avec preselected: true
    const preselectedProfileApps = profileApps
      .filter(app => app.preselected)
      .map(app => getAppId(app));

    setUserConfig((prev) => ({
      ...prev,
      profile: profileId,
      custom_name: profile.name,
      master_apps: preselectedMasterApps,
      profile_apps: preselectedProfileApps,
      optional_apps: [],
    }));
  };

  // Réinitialiser la configuration
  const resetConfig = () => {
    setUserConfig({
      profile: null,
      custom_name: '',
      master_apps: [],
      profile_apps: [],
      optional_apps: [],
      modules: {
        debloat: { enabled: true },
        performance: {
          enabled: true,
          PageFile: true,
          PowerPlan: true,
          StartupPrograms: true,
          Network: true,
          VisualEffects: true,
        },
        ui: {
          enabled: true,
          DarkMode: true,
          ShowFileExtensions: true,
          ShowFullPath: true,
          ShowHiddenFiles: false,
          ShowThisPC: true,
          ShowRecycleBin: true,
          RestartExplorer: true,
          TaskbarPosition: 'Bottom',
          ThemeColor: '0078D7',
          TaskbarAlignLeft: true,
          Windows10ContextMenu: true,
          HideWidgets: true,
          HideTaskView: true,
          EnableEndTask: true,
        },
      },
    });
  };

  // Mettre à jour une partie de la configuration
  const updateConfig = (updates) => {
    setUserConfig((prev) => ({
      ...prev,
      ...updates,
    }));
  };

  // Mettre à jour un module
  const updateModule = (moduleName, updates) => {
    setUserConfig((prev) => ({
      ...prev,
      modules: {
        ...prev.modules,
        [moduleName]: {
          ...prev.modules[moduleName],
          ...updates,
        },
      },
    }));
  };

  const value = {
    profiles,
    apps,
    modules,
    loading,
    error,
    userConfig,
    selectProfile,
    resetConfig,
    updateConfig,
    updateModule,
    resolveApp,
    getAppId,
  };

  return <ConfigContext.Provider value={value}>{children}</ConfigContext.Provider>;
};
