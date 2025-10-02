#!/bin/bash
# Script de test de l'API PostBootSetup v5.0

set -e

API_URL="http://localhost:5000"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   PostBootSetup v5.0 - Tests API                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Fonction utilitaire pour les tests
test_endpoint() {
    local name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"

    echo "🧪 Test: $name"
    echo "   Endpoint: $method $endpoint"

    if [ "$method" == "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$API_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$API_URL$endpoint")
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -eq 200 ]; then
        echo "   ✓ Succès (HTTP $http_code)"
        echo "$body" | jq . 2>/dev/null || echo "$body"
    else
        echo "   ✗ Échec (HTTP $http_code)"
        echo "$body"
    fi

    echo ""
}

# Test 1: Health Check
test_endpoint "Health Check" "GET" "/api/health"

# Test 2: Liste des profils
test_endpoint "Liste des profils" "GET" "/api/profiles"

# Test 3: Liste des applications
test_endpoint "Liste des applications" "GET" "/api/apps"

# Test 4: Liste des modules
test_endpoint "Liste des modules" "GET" "/api/modules"

# Test 5: Génération d'un script
echo "🧪 Test: Génération d'un script PowerShell"
echo "   Endpoint: POST /api/generate/script"

if [ -f "test_config_example.json" ]; then
    response=$(curl -s -w "\n%{http_code}" -X POST \
        -H "Content-Type: application/json" \
        -d @test_config_example.json \
        "$API_URL/api/generate/script")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" -eq 200 ]; then
        echo "   ✓ Succès (HTTP $http_code)"

        # Extraire les informations du script généré
        script_id=$(echo "$body" | jq -r '.script_id')
        filename=$(echo "$body" | jq -r '.filename')
        download_url=$(echo "$body" | jq -r '.download_url')

        echo "   Script ID: $script_id"
        echo "   Filename: $filename"
        echo "   Download URL: $download_url"

        # Test 6: Téléchargement du script
        echo ""
        echo "🧪 Test: Téléchargement du script généré"
        echo "   Endpoint: GET $download_url"

        curl -s -o "generated_test_script.ps1" "$API_URL$download_url"

        if [ -f "generated_test_script.ps1" ]; then
            file_size=$(wc -c < "generated_test_script.ps1")
            echo "   ✓ Script téléchargé avec succès ($file_size octets)"
            echo "   Fichier sauvegardé: generated_test_script.ps1"

            # Afficher les premières lignes du script
            echo ""
            echo "   📄 Aperçu du script généré:"
            echo "   ────────────────────────────────────────────────────"
            head -n 20 "generated_test_script.ps1" | sed 's/^/   │ /'
            echo "   ────────────────────────────────────────────────────"
        else
            echo "   ✗ Échec du téléchargement"
        fi
    else
        echo "   ✗ Échec (HTTP $http_code)"
        echo "$body"
    fi
else
    echo "   ⚠ Fichier test_config_example.json introuvable"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Tests terminés                                           ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Résumé des services :"
docker-compose ps

echo ""
echo "📝 Pour voir les logs détaillés :"
echo "   docker-compose logs -f api"
echo ""