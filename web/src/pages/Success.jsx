import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { CheckCircle2, Home, Download, Terminal, AlertTriangle } from 'lucide-react';

const Success = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const filename = location.state?.filename || 'PostBootSetup.ps1';

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-3xl mx-auto">
        {/* Success message */}
        <div className="text-center mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-green-100 rounded-full mb-4">
            <CheckCircle2 className="w-10 h-10 text-green-600" />
          </div>
          <h2 className="text-3xl font-bold text-gray-900 mb-2">
            Script généré avec succès !
          </h2>
          <p className="text-lg text-gray-600">
            Votre script <code className="bg-gray-100 px-2 py-1 rounded text-sm">{filename}</code> a été téléchargé
          </p>
        </div>

        {/* Instructions */}
        <div className="card mb-6">
          <h3 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
            <Terminal className="w-5 h-5 mr-2 text-primary-600" />
            Comment utiliser le script
          </h3>

          <ol className="space-y-4">
            <li className="flex items-start">
              <span className="flex items-center justify-center w-6 h-6 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mr-3 flex-shrink-0">
                1
              </span>
              <div>
                <p className="font-medium text-gray-900">Transférez le script sur le PC Windows cible</p>
                <p className="text-sm text-gray-600 mt-1">
                  Copiez le fichier .ps1 via USB, réseau ou email
                </p>
              </div>
            </li>

            <li className="flex items-start">
              <span className="flex items-center justify-center w-6 h-6 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mr-3 flex-shrink-0">
                2
              </span>
              <div>
                <p className="font-medium text-gray-900">Faites un clic droit sur le fichier</p>
                <p className="text-sm text-gray-600 mt-1">
                  Sélectionnez <strong>"Exécuter avec PowerShell"</strong>
                </p>
              </div>
            </li>

            <li className="flex items-start">
              <span className="flex items-center justify-center w-6 h-6 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mr-3 flex-shrink-0">
                3
              </span>
              <div>
                <p className="font-medium text-gray-900">Accordez les droits administrateur</p>
                <p className="text-sm text-gray-600 mt-1">
                  Cliquez sur "Oui" lorsque l'UAC vous le demande
                </p>
              </div>
            </li>

            <li className="flex items-start">
              <span className="flex items-center justify-center w-6 h-6 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mr-3 flex-shrink-0">
                4
              </span>
              <div>
                <p className="font-medium text-gray-900">Laissez le script s'exécuter</p>
                <p className="text-sm text-gray-600 mt-1">
                  Le processus peut prendre 10-30 minutes selon les applications
                </p>
              </div>
            </li>
          </ol>
        </div>

        {/* Avertissement */}
        <div className="card bg-amber-50 border-amber-200 mb-6">
          <div className="flex items-start space-x-3">
            <AlertTriangle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
            <div>
              <h4 className="font-semibold text-amber-900 mb-1">Important</h4>
              <ul className="text-sm text-amber-800 space-y-1">
                <li>• Le PC doit être connecté à Internet</li>
                <li>• Winget doit être installé (Windows 10 1809+ / Windows 11)</li>
                <li>• Un redémarrage peut être nécessaire après l'exécution</li>
                <li>• Les logs sont sauvegardés dans le même dossier que le script</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Commande alternative */}
        <div className="card mb-8">
          <h4 className="font-medium text-gray-900 mb-2">Exécution en ligne de commande</h4>
          <p className="text-sm text-gray-600 mb-3">
            Vous pouvez aussi exécuter le script depuis PowerShell (Administrateur) :
          </p>
          <pre className="bg-gray-900 text-gray-100 p-4 rounded-lg text-sm overflow-x-auto">
            <code>
              {`# Naviguer vers le dossier
cd "C:\\Chemin\\Vers\\Le\\Dossier"

# Autoriser l'exécution (si nécessaire)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Lancer le script
.\\${filename}`}
            </code>
          </pre>
        </div>

        {/* Actions */}
        <div className="flex items-center justify-center space-x-4">
          <button
            onClick={() => navigate('/')}
            className="btn-secondary flex items-center"
          >
            <Home className="w-4 h-4 mr-2" />
            Retour à l'accueil
          </button>
          <button
            onClick={() => navigate('/customize')}
            className="btn-primary flex items-center"
          >
            <Download className="w-4 h-4 mr-2" />
            Générer un autre script
          </button>
        </div>
      </div>
    </div>
  );
};

export default Success;
