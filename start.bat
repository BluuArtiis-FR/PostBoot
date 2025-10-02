@echo off
REM Script de démarrage rapide PostBootSetup v5.0 pour Windows

echo ================================================================
echo    PostBootSetup v5.0 - Demarrage Docker Desktop
echo    Tenor Data Solutions
echo ================================================================
echo.

REM Vérifier Docker Desktop
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Docker Desktop n'est pas installe ou n'est pas dans le PATH
    echo.
    echo Telechargez Docker Desktop : https://www.docker.com/products/docker-desktop/
    echo.
    pause
    exit /b 1
)

where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Docker Compose n'est pas installe
    echo.
    echo Docker Compose est normalement inclus dans Docker Desktop
    echo Verifiez votre installation de Docker Desktop
    echo.
    pause
    exit /b 1
)

echo [OK] Docker detecte :
docker --version
echo [OK] Docker Compose detecte :
docker-compose --version
echo.

REM Créer les dossiers nécessaires
echo [INFO] Creation des dossiers...
if not exist "generated" mkdir generated
if not exist "logs" mkdir logs
echo [OK] Dossiers crees
echo.

REM Nettoyer les anciens containers
echo [INFO] Nettoyage des anciens containers...
docker-compose down -v 2>nul
echo [OK] Nettoyage termine
echo.

REM Construire et démarrer
echo [INFO] Construction des images Docker...
echo (Cela peut prendre plusieurs minutes la premiere fois...)
docker-compose build --no-cache

if %errorlevel% neq 0 (
    echo [ERREUR] Echec de la construction des images
    pause
    exit /b 1
)

echo.
echo [INFO] Demarrage des containers...
docker-compose up -d

if %errorlevel% neq 0 (
    echo [ERREUR] Echec du demarrage des containers
    pause
    exit /b 1
)

echo.
echo [INFO] Attente du demarrage des services (30 secondes)...
timeout /t 30 /nobreak >nul

REM Vérifier le statut
echo.
echo [INFO] Statut des containers :
docker-compose ps

echo.
echo [INFO] Verification de la sante de l'API...
curl -f http://localhost:5000/api/health >nul 2>nul
if %errorlevel% equ 0 (
    echo [OK] API operationnelle !
) else (
    echo [ATTENTION] L'API ne repond pas encore
    echo Verifiez les logs avec : docker-compose logs api
)

echo.
echo ================================================================
echo    DEMARRAGE TERMINE
echo ================================================================
echo.
echo [ACCES]
echo   Interface web : http://localhost
echo   API : http://localhost:5000
echo   Health check : http://localhost:5000/api/health
echo.
echo [COMMANDES UTILES]
echo   Voir les logs : docker-compose logs -f
echo   Arreter : docker-compose down
echo   Redemarrer : docker-compose restart
echo.
echo Documentation complete : README_v5.md
echo.
pause