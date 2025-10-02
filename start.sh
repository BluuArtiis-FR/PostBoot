#!/bin/bash
# Script de démarrage rapide PostBootSetup v5.0

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   PostBootSetup v5.0 - Démarrage Docker                   ║"
echo "║   Tenor Data Solutions                                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Vérifier Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    echo "   Installez Docker : https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé"
    echo "   Installez Docker Compose : https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker détecté : $(docker --version)"
echo "✓ Docker Compose détecté : $(docker-compose --version)"
echo ""

# Créer les dossiers nécessaires
echo "📁 Création des dossiers..."
mkdir -p generated logs
echo "✓ Dossiers créés"
echo ""

# Nettoyer les anciens containers si présents
echo "🧹 Nettoyage des anciens containers..."
docker-compose down -v 2>/dev/null || true
echo "✓ Nettoyage terminé"
echo ""

# Construire et démarrer
echo "🔨 Construction des images Docker..."
docker-compose build --no-cache

echo ""
echo "🚀 Démarrage des containers..."
docker-compose up -d

echo ""
echo "⏳ Attente du démarrage des services (30 secondes)..."
sleep 30

# Vérifier le statut
echo ""
echo "📊 Statut des containers :"
docker-compose ps

echo ""
echo "🏥 Vérification de la santé de l'API..."
if curl -f http://localhost:5000/api/health &> /dev/null; then
    echo "✓ API opérationnelle"
else
    echo "⚠ L'API ne répond pas encore, vérifiez les logs avec : docker-compose logs api"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🎉 DÉMARRAGE TERMINÉ                                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📍 Accès :"
echo "   • Interface web : http://localhost"
echo "   • API : http://localhost:5000"
echo "   • Health check : http://localhost:5000/api/health"
echo ""
echo "📖 Commandes utiles :"
echo "   • Voir les logs : docker-compose logs -f"
echo "   • Arrêter : docker-compose down"
echo "   • Redémarrer : docker-compose restart"
echo ""
echo "📚 Documentation complète : README_v5.md"
echo ""
