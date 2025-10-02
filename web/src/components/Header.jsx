import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Monitor, HelpCircle } from 'lucide-react';

const Header = () => {
  const navigate = useNavigate();

  return (
    <header className="bg-white border-b border-gray-200 shadow-sm">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Logo et titre - cliquable */}
          <button
            onClick={() => navigate('/')}
            className="flex items-center space-x-3 hover:opacity-80 transition-opacity"
          >
            <div className="bg-primary-600 p-2 rounded-lg">
              <Monitor className="w-6 h-6 text-white" />
            </div>
            <div className="text-left">
              <h1 className="text-xl font-bold text-gray-900">
                PostBootSetup
                <span className="ml-2 text-sm font-normal text-gray-500">v5.0</span>
              </h1>
              <p className="text-sm text-gray-600">Générateur de scripts d'installation Windows</p>
            </div>
          </button>

          {/* Actions */}
          <div className="flex items-center space-x-4">
            <a
              href="https://github.com/BluuArtiis-FR/PostBoot/blob/main/AIDE.md"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center space-x-2 px-3 py-2 text-sm text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-lg transition-colors"
              title="Documentation et aide"
            >
              <HelpCircle className="w-4 h-4" />
              <span className="hidden sm:inline">Aide</span>
            </a>

            {/* Info Tenor */}
            <div className="hidden md:block text-right pl-4 border-l border-gray-200">
              <p className="text-sm font-medium text-gray-700">Tenor Data Solutions</p>
              <p className="text-xs text-gray-500">IT Department</p>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
