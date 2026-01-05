import axios from 'axios';

// En production Docker, utiliser l'URL relative pour que nginx fasse le proxy
// En dev local, utiliser http://localhost:5000
const API_BASE_URL = import.meta.env.VITE_API_URL || '';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000, // 30 seconds
});

// Intercepteur pour logger les requêtes en développement
api.interceptors.request.use(
  (config) => {
    if (import.meta.env.DEV) {
      console.log(`[API Request] ${config.method.toUpperCase()} ${config.url}`);
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Intercepteur pour gérer les erreurs
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      console.error('[API Error]', error.response.status, error.response.data);
    } else if (error.request) {
      console.error('[API Error] No response received:', error.request);
    } else {
      console.error('[API Error] Request setup error:', error.message);
    }
    return Promise.reject(error);
  }
);

// ============================================
// API Methods
// ============================================

export const apiService = {
  // Health check
  async healthCheck() {
    const response = await api.get('/api/health');
    return response.data;
  },

  // Get all profiles
  async getProfiles() {
    const response = await api.get('/api/profiles');
    return response.data;
  },

  // Get all applications
  async getApps() {
    const response = await api.get('/api/apps');
    return response.data;
  },

  // Get all modules
  async getModules() {
    const response = await api.get('/api/modules');
    return response.data;
  },

  // Generate script
  async generateScript(config) {
    const response = await api.post('/api/generate', config, {
      responseType: 'blob',
    });
    return response;
  },

  // Generate executable (désactivé sur Linux Docker)
  async generateExecutable(config) {
    const response = await api.post('/api/generate/executable', config);
    return response.data;
  },

  // Download generated file
  async downloadScript(scriptId) {
    const response = await api.get(`/api/download/${scriptId}`, {
      responseType: 'blob',
    });
    return response;
  },
};

export default api;
