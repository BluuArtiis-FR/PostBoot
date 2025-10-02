import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ConfigProvider } from './context/ConfigContext';
import Header from './components/Header';
import Footer from './components/Footer';
import Home from './pages/Home';
import Installation from './pages/Installation';
import Optimizations from './pages/Optimizations';
import Diagnostic from './pages/Diagnostic';
import Generate from './pages/Generate';
import Success from './pages/Success';

function App() {
  return (
    <Router>
      <ConfigProvider>
        <div className="min-h-screen flex flex-col bg-gray-50">
          <Header />
          <main className="flex-1">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/installation" element={<Installation />} />
              <Route path="/optimizations" element={<Optimizations />} />
              <Route path="/diagnostic" element={<Diagnostic />} />
              <Route path="/generate" element={<Generate />} />
              <Route path="/success" element={<Success />} />
              {/* Legacy route for compatibility */}
              <Route path="/customize" element={<Installation />} />
            </Routes>
          </main>
          <Footer />
        </div>
      </ConfigProvider>
    </Router>
  );
}

export default App;
