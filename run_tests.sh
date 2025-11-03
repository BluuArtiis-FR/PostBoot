#!/bin/bash
# Test automatique de tous les scenarios PostBootSetup v5.0

API_URL="http://localhost:5000/api"
OUTPUT_DIR="./test_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Compteurs
TOTAL=0
PASS=0
FAIL=0

# Creer dossier resultats
mkdir -p "$OUTPUT_DIR"

echo -e "${CYAN}"
echo "========================================"
echo "  TESTS AUTOMATISES POSTBOOTSETUP v5.0"
echo "========================================"
echo -e "${NC}\n"

# Function: Test API Health
test_api_health() {
    echo -e "${YELLOW}[TEST] Verification sante API...${NC}"
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/health" 2>/dev/null)

    if [ "$response" == "200" ]; then
        echo -e "${GREEN}[OK] API operationnelle${NC}"
        return 0
    else
        echo -e "${RED}[ERREUR] API non accessible (code: $response)${NC}"
        return 1
    fi
}

# Function: Generate and validate script
test_scenario() {
    local test_name=$1
    local config_file=$2

    TOTAL=$((TOTAL + 1))
    echo -e "\n${CYAN}[$TOTAL] Test: $test_name${NC}"

    local script_path="$OUTPUT_DIR/${test_name}.ps1"

    # Generer le script
    http_code=$(curl -s -X POST "$API_URL/generate" \
        -H "Content-Type: application/json" \
        -d @"$config_file" \
        --output "$script_path" \
        -w "%{http_code}")

    if [ "$http_code" == "200" ] && [ -f "$script_path" ]; then
        file_size=$(stat -c%s "$script_path" 2>/dev/null || stat -f%z "$script_path" 2>/dev/null)
        echo -e "  ${GREEN}[OK] Script genere: $file_size octets${NC}"

        # Valider avec PowerShell
        pwsh -Command "\$errors = \$null; \$tokens = \$null; [System.Management.Automation.Language.Parser]::ParseFile('$script_path', [ref]\$tokens, [ref]\$errors) | Out-Null; if (\$errors.Count -gt 0) { exit 1 } else { exit 0 }" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}[OK] Syntaxe PowerShell valide${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "  ${RED}[X] Erreurs syntaxe PowerShell${NC}"
            FAIL=$((FAIL + 1))
        fi
    else
        echo -e "  ${RED}[X] Echec generation (HTTP $http_code)${NC}"
        FAIL=$((FAIL + 1))
    fi
}

# Verifier API
if ! test_api_health; then
    echo -e "\n${RED}Erreur: L'API doit etre demarree (docker-compose up -d)${NC}\n"
    exit 1
fi

echo -e "\n${CYAN}=== SCENARIOS DE TEST ===${NC}\n"

# Creer fichiers de configuration temporaires
mkdir -p "$OUTPUT_DIR/configs"

# TEST 1: Configuration minimale
cat > "$OUTPUT_DIR/configs/01_minimal.json" << 'EOF'
{
  "computerName": "TEST-MINIMAL",
  "profile_name": "Test Minimal",
  "apps": {
    "master": ["Chrome", "7zip", "Adobe Acrobat Reader", "VLC", "Teams", "Outlook", "Word", "Excel", "PowerPoint", "OneNote", "OneDrive"],
    "profile": []
  },
  "modules": ["debloat"]
}
EOF

test_scenario "01_Minimal_MasterOnly" "$OUTPUT_DIR/configs/01_minimal.json"

# TEST 2: Profil DEV .NET
cat > "$OUTPUT_DIR/configs/02_devnet.json" << 'EOF'
{
  "computerName": "TEST-DEV-NET",
  "profile_name": "DEV .NET",
  "apps": {
    "master": ["Chrome", "7zip", "Adobe Acrobat Reader", "VLC", "Teams", "Outlook", "Word", "Excel", "PowerPoint", "OneNote", "OneDrive"],
    "profile": ["Visual Studio 2022", "SQL Server 2022 Express", "SSMS", "Git", "Postman", "Python", "Node.js", "VS Code"]
  },
  "modules": ["debloat", "performance"],
  "performance": {
    "visualEffects": true,
    "pageFile": true,
    "startupPrograms": true,
    "network": true,
    "powerPlan": "High performance"
  }
}
EOF

test_scenario "02_Profile_DEV_NET" "$OUTPUT_DIR/configs/02_devnet.json"

# TEST 3: Tous les modules
cat > "$OUTPUT_DIR/configs/03_full.json" << 'EOF'
{
  "computerName": "TEST-FULL",
  "profile_name": "Configuration Complete",
  "apps": {
    "master": ["Chrome", "7zip", "Adobe Acrobat Reader", "VLC", "Teams", "Outlook", "Word", "Excel", "PowerPoint", "OneNote", "OneDrive"],
    "profile": ["Git", "VS Code", "Python", "Node.js"]
  },
  "modules": ["debloat", "performance", "ui"],
  "performance": {
    "visualEffects": true,
    "pageFile": true,
    "powerPlan": "High performance"
  },
  "ui": {
    "taskbarPosition": "Bottom",
    "darkMode": true,
    "ShowFileExtensions": true,
    "ShowHiddenFiles": false
  }
}
EOF

test_scenario "03_AllModules_Full" "$OUTPUT_DIR/configs/03_full.json"

# TEST 4: Profil SI
cat > "$OUTPUT_DIR/configs/04_si.json" << 'EOF'
{
  "computerName": "TEST-SI",
  "profile_name": "SI",
  "apps": {
    "master": ["Chrome", "7zip", "Adobe Acrobat Reader", "VLC", "Teams", "Outlook", "Word", "Excel", "PowerPoint", "OneNote", "OneDrive"],
    "profile": ["Git", "SSMS", "DBeaver", "Wireshark", "Nmap", "Burp Suite", "PuTTY", "WinSCP"]
  },
  "modules": ["debloat", "performance", "ui"],
  "performance": {
    "visualEffects": false,
    "powerPlan": "High performance"
  },
  "ui": {
    "darkMode": true,
    "ShowFileExtensions": true
  }
}
EOF

test_scenario "04_Profile_SI" "$OUTPUT_DIR/configs/04_si.json"

# TEST 5: Performance seul
cat > "$OUTPUT_DIR/configs/05_perf.json" << 'EOF'
{
  "computerName": "TEST-PERF",
  "profile_name": "Performance Only",
  "apps": {
    "master": ["Chrome", "7zip", "Adobe Acrobat Reader", "VLC", "Teams", "Outlook", "Word", "Excel", "PowerPoint", "OneNote", "OneDrive"],
    "profile": []
  },
  "modules": ["debloat", "performance"],
  "performance": {
    "visualEffects": true,
    "pageFile": true,
    "startupPrograms": true,
    "network": true,
    "powerPlan": "Balanced"
  }
}
EOF

test_scenario "05_PerformanceOnly" "$OUTPUT_DIR/configs/05_perf.json"

# TEST 6: UI seul
cat > "$OUTPUT_DIR/configs/06_ui.json" << 'EOF'
{
  "computerName": "TEST-UI",
  "profile_name": "UI Only",
  "apps": {
    "master": ["Chrome", "7zip", "Adobe Acrobat Reader", "VLC", "Teams", "Outlook", "Word", "Excel", "PowerPoint", "OneNote", "OneDrive"],
    "profile": []
  },
  "modules": ["debloat", "ui"],
  "ui": {
    "taskbarPosition": "Top",
    "darkMode": false,
    "ShowFileExtensions": false,
    "ShowHiddenFiles": false
  }
}
EOF

test_scenario "06_UIOnly" "$OUTPUT_DIR/configs/06_ui.json"

# Resultats finaux
echo -e "\n${CYAN}========================================${NC}"
echo -e "${CYAN}  RESULTATS FINAUX${NC}"
echo -e "${CYAN}========================================${NC}"
echo -e "Total tests:     $TOTAL"
echo -e "${GREEN}Reussis:         $PASS${NC}"
echo -e "${RED}Echoues:         $FAIL${NC}"

if [ $TOTAL -gt 0 ]; then
    SUCCESS_RATE=$((PASS * 100 / TOTAL))
    echo -e "Taux de reussite: ${SUCCESS_RATE}%"
fi

echo -e "\n${CYAN}Scripts generes: $OUTPUT_DIR/${NC}"
echo -e "${CYAN}========================================${NC}\n"

# Exit code
if [ $FAIL -eq 0 ]; then
    exit 0
else
    exit 1
fi
