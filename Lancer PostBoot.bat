@echo off
:: Lanceur pour PostBoot Setup avec interface WPF
:: Tenor Data Solutions

title PostBoot Setup Launcher

:: Vérifier les privilèges administrateur
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo ╔═══════════════════════════════════════════════════════════════╗
    echo ║  ERREUR: Privileges administrateur requis                     ║
    echo ╚═══════════════════════════════════════════════════════════════╝
    echo.
    echo Ce script necessite des privileges administrateur.
    echo Faites un clic droit et selectionnez "Executer en tant qu'administrateur"
    echo.
    pause
    exit /b 1
)

:: Lancer l'interface WPF
echo.
echo ╔═══════════════════════════════════════════════════════════════╗
echo ║  PostBoot Setup Launcher - Tenor Data Solutions              ║
echo ╚═══════════════════════════════════════════════════════════════╝
echo.
echo Lancement de l'interface graphique...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0launcher\PostBootLauncher.ps1"

exit /b 0
