# Validation du script généré
param(
    [string]$ScriptPath = ".\generated\test_fixed.ps1"
)

$errors = $null
$tokens = $null

Write-Host "`n=== VALIDATION DU SCRIPT GENERE ===" -ForegroundColor Cyan
Write-Host "Fichier: $ScriptPath`n" -ForegroundColor Gray

$ast = [System.Management.Automation.Language.Parser]::ParseFile($ScriptPath, [ref]$tokens, [ref]$errors)

if ($errors.Count -gt 0) {
    Write-Host "[X] ERREURS DETECTEES ($($errors.Count)):" -ForegroundColor Red
    $errors | ForEach-Object {
        Write-Host "  Ligne $($_.Extent.StartLineNumber): $($_.Message)" -ForegroundColor Yellow
    }
    exit 1
} else {
    Write-Host "[OK] Script PowerShell valide" -ForegroundColor Green

    $lines = (Get-Content $ScriptPath).Count
    $functions = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true).Count

    Write-Host "`nStatistiques:" -ForegroundColor Cyan
    Write-Host "  - Lignes: $lines" -ForegroundColor Gray
    Write-Host "  - Fonctions: $functions" -ForegroundColor Gray
    Write-Host "  - Tokens: $($tokens.Count)" -ForegroundColor Gray

    exit 0
}
