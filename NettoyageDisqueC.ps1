# Script de Nettoyage du Disque Dur C: sous Windows 10/11
# Auteur: Assistant OpenAI
# Description: Nettoie les fichiers temporaires, la corbeille et les caches de manière sécurisée.

Write-Host "=========================================" -ForegroundColor Green
Write-Host "  NETTOYAGE EN PROFONDEUR DU DISQUE C:   " -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

# 1. Afficher l'espace libre actuel
$disk = Get-PSDrive -Name C
Write-Host "Espace libre actuel sur C: $([math]::Round($disk.Free / 1GB, 2)) Go" -ForegroundColor Cyan
Write-Host ""

# 2. Nettoyage de disque Windows (Cleanmgr)
Write-Host "1. Lancement du Nettoyage de Disque Windows..." -ForegroundColor Yellow
Cleanmgr /sageset:1 | Out-Null
# Cela ouvre la fenêtre de configuration. Les cases cochées ci-dessous sont pré-sélectionnées.
# Cette commande lance le nettoyage avec les paramètres par défaut + fichiers système.
Start-Process -Wait -WindowStyle Hidden -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1"

# 3. Nettoyer les dossiers TEMP de l'utilisateur et du système
Write-Host "2. Nettoyage des dossiers TEMP..." -ForegroundColor Yellow
Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   Dossiers TEMP nettoyés." -ForegroundColor Green

# 4. Vider la Corbeille
Write-Host "3. Vider la Corbeille..." -ForegroundColor Yellow
$confirm = Read-Host "   Êtes-vous sûr ? (O/N)"
if ($confirm -eq 'O' -or $confirm -eq 'o') {
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "   Corbeille vidée." -ForegroundColor Green
} else {
    Write-Host "   Opération annulée." -ForegroundColor Red
}

# 5. Nettoyer les caches des navigateurs (Chrome, Firefox, Edge)
Write-Host "4. Nettoyage des caches des navigateurs..." -ForegroundColor Yellow
$paths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*.default-release\cache2"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Remove-Item $path\* -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   Nettoyé: $path" -ForegroundColor Green
    }
}

# 6. Nettoyer le cache du magasin Windows (WinSxS) - Nettoyage officiel
Write-Host "5. Nettoyage du composant Windows (WinSxS) via DISM..." -ForegroundColor Yellow
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# 7. Afficher l'espace libre final
Write-Host ""
Write-Host "=== NETTOYAGE TERMINE ===" -ForegroundColor Green
$disk = Get-PSDrive -Name C
Write-Host "Espace libre maintenant sur C: $([math]::Round($disk.Free / 1GB, 2)) Go" -ForegroundColor Cyan
Write-Host ""

# 8. Invite à redémarrer
$reboot = Read-Host "Un redémarrage est recommandé pour terminer certaines opérations. Redémarrer maintenant ? (O/N)"
if ($reboot -eq 'O' -or $reboot -eq 'o') {
    Restart-Computer -Force
}