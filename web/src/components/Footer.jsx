import React from 'react';
import { Github, Mail } from 'lucide-react';

const Footer = () => {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="bg-white border-t border-gray-200 mt-auto">
      <div className="container mx-auto px-4 py-6">
        <div className="flex flex-col md:flex-row items-center justify-between space-y-4 md:space-y-0">
          <div className="text-sm text-gray-600">
            © {currentYear} <span className="font-semibold">Tenor Data Solutions</span>. Tous droits réservés.
          </div>

          <div className="flex items-center space-x-6">
            <a
              href="https://github.com/tenor-solutions"
              target="_blank"
              rel="noopener noreferrer"
              className="text-gray-600 hover:text-primary-600 transition-colors"
            >
              <Github className="w-5 h-5" />
            </a>
            <a
              href="mailto:si@tenorsolutions.com"
              className="text-gray-600 hover:text-primary-600 transition-colors"
            >
              <Mail className="w-5 h-5" />
            </a>
          </div>

          <div className="text-xs text-gray-500">
            Version 5.0.0 - Build {import.meta.env.VITE_BUILD_ID || 'dev'}
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
