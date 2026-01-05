import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ConfigProvider } from './context/ConfigContext';
import Footer from './components/Footer';
import ConfigurationPage from './pages/ConfigurationPage';
import Success from './pages/Success';

function App() {
  return (
    <Router>
      <ConfigProvider>
        <div className="min-h-screen flex flex-col bg-gray-50">
          <main className="flex-1">
            <Routes>
              <Route path="/" element={<ConfigurationPage />} />
              <Route path="/success" element={<Success />} />
              {/* Redirection des anciennes routes vers la page principale */}
              <Route path="/home" element={<Navigate to="/" replace />} />
              <Route path="/installation" element={<Navigate to="/" replace />} />
              <Route path="/optimizations" element={<Navigate to="/" replace />} />
              <Route path="/diagnostic" element={<Navigate to="/" replace />} />
              <Route path="/generate" element={<Navigate to="/" replace />} />
              <Route path="/customize" element={<Navigate to="/" replace />} />
            </Routes>
          </main>
          <Footer />
        </div>
      </ConfigProvider>
    </Router>
  );
}

export default App;
