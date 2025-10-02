// Configuration par défaut (fallback si les fichiers JSON ne sont pas accessibles)
const defaultConfig = {
    company: {
        name: "Tenor Data Solutions",
        domain: "tenorsolutions.local",
        email: "it@tenorsolutions.com"
    },
    master: [
        { name: "Microsoft Office 365", size: "3 GB", category: "Bureautique" },
        { name: "Microsoft Teams", size: "150 MB", category: "Communication" },
        { name: "Notepad++", size: "8 MB", category: "Editeur" },
        { name: "Greenshot", size: "3 MB", category: "Capture" },
        { name: "VPN Stormshield", size: "40 MB", category: "VPN" },
        { name: "Microsoft PowerToys", size: "25 MB", category: "Utilitaires" }
    ],
    profiles: {
        DEV: {
            name: "Développeur",
            description: "Outils de développement",
            apps: [
                { name: "Visual Studio Code", size: "85 MB" },
                { name: "Git", size: "45 MB" },
                { name: "SQL Server Management Studio", size: "600 MB" },
                { name: "DBeaver", size: "110 MB" },
                { name: "Postman", size: "180 MB" }
            ]
        },
        SUPPORT: {
            name: "Projet & Support",
            description: "Outils de support client",
            apps: [
                { name: "eCarAdmin", size: "50 MB" },
                { name: "EDI Translator", size: "30 MB" },
                { name: "TeamViewer", size: "45 MB" },
                { name: "Java JRE", size: "70 MB" }
            ]
        },
        SI: {
            name: "Système d'Information",
            description: "Outils d'administration",
            apps: [
                { name: "Wireshark", size: "65 MB" },
                { name: "Nmap", size: "25 MB" },
                { name: "Docker Desktop", size: "500 MB" },
                { name: "PowerShell Core", size: "100 MB" },
                { name: "Python", size: "25 MB" }
            ]
        }
    }
};

let appConfig = defaultConfig;
let settingsConfig = {
    enterprise: {
        signature: {
            company: "Tenor Data Solutions",
            website: "www.tenorsolutions.com"
        }
    }
};

// Fonction pour charger la configuration depuis les fichiers JSON
async function loadConfiguration() {
    try {
        // Essayer de charger apps.json
        const appsResponse = await fetch('../config/apps.json');
        if (appsResponse.ok) {
            appConfig = await appsResponse.json();
            console.log('Configuration apps.json chargée');
        }
    } catch (error) {
        console.log('Utilisation de la configuration par défaut pour les apps:', error);
    }

    try {
        // Essayer de charger settings.json
        const settingsResponse = await fetch('../config/settings.json');
        if (settingsResponse.ok) {
            settingsConfig = await settingsResponse.json();
            console.log('Configuration settings.json chargée');
        }
    } catch (error) {
        console.log('Utilisation de la configuration par défaut pour les settings:', error);
    }

    // Mettre à jour l'interface avec la configuration chargée
    updateInterface();
}

// Mettre à jour l'interface avec la configuration
function updateInterface() {
    // Mettre à jour le titre et les informations de l'entreprise
    if (appConfig.company) {
        const companyName = appConfig.company.name || 'Tenor Data Solutions';
        document.querySelector('.header h1').textContent = `PostBootSetup v${appConfig.version || '4.0'}`;
        document.querySelector('.header p').textContent = `${companyName} - Installation automatisée`;

        // Mettre à jour l'email de support
        const supportEmail = appConfig.company.email || 'it@tenorsolutions.com';
        document.querySelector('.summary p').textContent = `📧 Support : ${supportEmail}`;
    }
}

let selectedProfile = null;
let startTime = null;

// Sélection de profil
document.addEventListener('DOMContentLoaded', async function() {
    await loadConfiguration();

    document.querySelectorAll('.profile').forEach(profile => {
        profile.addEventListener('click', () => {
            // Retirer la sélection précédente
            document.querySelectorAll('.profile').forEach(p => p.classList.remove('selected'));

            // Sélectionner le nouveau
            profile.classList.add('selected');
            selectedProfile = profile.dataset.profile;

            // Afficher les applications
            showApps(selectedProfile);

            // Activer le bouton
            document.getElementById('startBtn').disabled = false;
        });
    });
});

function showApps(profileKey) {
    const profile = appConfig.profiles[profileKey];
    const preview = document.getElementById('appsPreview');
    const grid = document.getElementById('appsGrid');

    if (!profile) {
        console.error('Profil non trouvé:', profileKey);
        return;
    }

    grid.innerHTML = '';

    // Applications master
    appConfig.master.forEach(app => {
        const item = document.createElement('div');
        item.className = 'app-item';
        item.innerHTML = `<h4>${app.name}</h4><span>Master (${app.size})</span>`;
        grid.appendChild(item);
    });

    // Applications du profil
    profile.apps.forEach(app => {
        const item = document.createElement('div');
        item.className = 'app-item';
        item.innerHTML = `<h4>${app.name}</h4><span>${profile.name} (${app.size})</span>`;
        grid.appendChild(item);
    });

    preview.classList.add('show');
}

function startInstallation() {
    if (!selectedProfile) return;

    startTime = Date.now();

    // Masquer les contrôles
    document.getElementById('profiles').style.display = 'none';
    document.getElementById('appsPreview').style.display = 'none';
    document.querySelector('.controls').style.display = 'none';

    // Afficher la progression
    document.getElementById('progress').classList.add('show');

    // Simuler l'installation
    simulateInstallation();
}

function simulateInstallation() {
    const profile = appConfig.profiles[selectedProfile];
    const allApps = [...appConfig.master, ...profile.apps];
    let currentIndex = 0;
    let successCount = 0;
    let failedCount = 0;

    function installNext() {
        if (currentIndex >= allApps.length) {
            // Terminer
            const duration = Math.round((Date.now() - startTime) / 1000);
            showSummary(successCount, failedCount, duration);
            return;
        }

        const app = allApps[currentIndex];
        const progress = ((currentIndex + 1) / allApps.length) * 100;

        document.getElementById('progressFill').style.width = `${progress}%`;
        document.getElementById('currentApp').textContent = `Installation de ${app.name}...`;

        // Simuler temps d'installation
        setTimeout(() => {
            const success = Math.random() > 0.1; // 90% de succès
            const status = success ? '✅' : '❌';
            const logEntry = `${status} ${app.name} ${success ? 'installé' : 'échec'}`;

            addLog(logEntry);

            if (success) successCount++;
            else failedCount++;

            currentIndex++;
            installNext();
        }, Math.random() * 2000 + 500);
    }

    installNext();
}

function addLog(message) {
    const log = document.getElementById('log');
    const entry = document.createElement('div');
    entry.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
    log.appendChild(entry);
    log.scrollTop = log.scrollHeight;
}

function showSummary(success, failed, duration) {
    document.getElementById('progress').style.display = 'none';

    const summary = document.getElementById('summary');
    document.getElementById('successCount').textContent = success;
    document.getElementById('failedCount').textContent = failed;
    document.getElementById('duration').textContent = `${Math.floor(duration/60)}:${(duration%60).toString().padStart(2, '0')}`;

    summary.classList.add('show');
}