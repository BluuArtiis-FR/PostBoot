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
        Network: false,
        VisualEffects: false,
      },
      ui: {
        enabled: false,
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
        TaskbarAlignLeft: false,
        Windows10ContextMenu: false,
        HideWidgets: false,
        HideTaskView: false,
        EnableEndTask: false,
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

  // Sélectionner un profil
  const selectProfile = (profileId) => {
    if (!apps) return;

    // Mode Custom (profileId = null)
    if (profileId === null) {
      setUserConfig({
        profile: null,
        custom_name: 'Configuration personnalisée',
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
            Network: false,
            VisualEffects: false,
          },
          ui: {
            enabled: false,
            DarkMode: true,
            ShowFileExtensions: true,
            ShowFullPath: true,
            ShowHiddenFiles: false,
            ShowThisPC: true,
            ShowRecycleBin: true,
            RestartExplorer: true,
            TaskbarPosition: 'Bottom',
            ThemeColor: '0078D7',
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

    // Pré-sélectionner uniquement les apps avec preselected: true
    const preselectedMasterApps = allowMasterEdit
      ? apps.master.filter(app => app.preselected).map(app => app.winget || app.url)
      : apps.master.map(app => app.winget || app.url); // Dans un profil normal, toutes les master apps sont incluses

    const preselectedProfileApps = profileApps
      .filter(app => app.preselected)
      .map(app => app.winget || app.url);

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
          Network: false,
          VisualEffects: false,
        },
        ui: {
          enabled: false,
          DarkMode: true,
          ShowFileExtensions: true,
          ShowFullPath: true,
          ShowHiddenFiles: false,
          ShowThisPC: true,
          ShowRecycleBin: true,
          RestartExplorer: true,
          TaskbarPosition: 'Bottom',
          ThemeColor: '0078D7',
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
  };

  return <ConfigContext.Provider value={value}>{children}</ConfigContext.Provider>;
};
