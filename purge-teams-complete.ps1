# ======================================================================
# Script : Purge-Teams.ps1
# Objectif : Supprimer complètement Microsoft Teams du système Windows 10
# Auteur : ChatGPT
# ======================================================================

Write-Host "=== PURGE COMPLETE DE MICROSOFT TEAMS ===" -ForegroundColor Cyan

# 1️⃣ Fermer tous les processus Teams
Write-Host "`nFermeture des processus Teams..." -ForegroundColor Yellow
Get-Process Teams -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# 2️⃣ Désinstaller Teams pour chaque utilisateur
Write-Host "`nDésinstallation de Teams pour chaque utilisateur..." -ForegroundColor Yellow
$users = Get-ChildItem 'C:\Users'
foreach ($user in $users) {
    $teamsPath = "C:\Users\$($user.Name)\AppData\Local\Microsoft\Teams\Update.exe"
    if (Test-Path $teamsPath) {
        Write-Host " - Suppression pour l'utilisateur $($user.Name)"
        & $teamsPath --uninstall --force --quiet
    }
}

# 3️⃣ Supprimer les dossiers Teams utilisateur
Write-Host "`nSuppression des dossiers Teams utilisateur..." -ForegroundColor Yellow
foreach ($user in $users) {
    $paths = @(
        "C:\Users\$($user.Name)\AppData\Local\Microsoft\Teams",
        "C:\Users\$($user.Name)\AppData\Roaming\Microsoft\Teams",
        "C:\Users\$($user.Name)\AppData\Roaming\Microsoft\Teams Installer",
        "C:\Users\$($user.Name)\AppData\Roaming\Microsoft\TeamsMeetingAddin"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) {
            Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# 4️⃣ Supprimer Teams Machine-Wide Installer
Write-Host "`nDésinstallation de Teams Machine-Wide Installer..." -ForegroundColor Yellow
$machineInstaller = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Teams Machine-Wide Installer*" }
if ($machineInstaller) {
    $machineInstaller.Uninstall()
}

# 5️⃣ Supprimer les dossiers globaux Teams
Write-Host "`nSuppression des dossiers Teams globaux..." -ForegroundColor Yellow
$globalPaths = @(
    "C:\ProgramData\Microsoft\Teams",
    "C:\Program Files (x86)\Teams Installer",
    "C:\Program Files (x86)\Microsoft\Teams",
    "C:\Program Files\Microsoft\Teams"
)
foreach ($gp in $globalPaths) {
    if (Test-Path $gp) {
        Remove-Item -Path $gp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 6️⃣ Nettoyer les clés de registre liées à Teams
Write-Host "`nNettoyage du registre..." -ForegroundColor Yellow
$registryKeys = @(
    "HKCU:\Software\Microsoft\Office\Teams",
    "HKLM:\Software\Microsoft\Teams",
    "HKLM:\Software\WOW6432Node\Microsoft\Teams",
    "HKCU:\Software\Microsoft\Teams"
)
foreach ($rk in $registryKeys) {
    if (Test-Path $rk) {
        Remove-Item -Path $rk -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# 7️⃣ Nettoyer le cache du Windows Installer pour Teams
Write-Host "`nNettoyage du cache du Windows Installer..." -ForegroundColor Yellow
Get-ChildItem "C:\Windows\Installer" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "Teams" } | Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "`n=== PURGE COMPLETE ===" -ForegroundColor Green
Write-Host "Microsoft Teams a été complètement supprimé du système."
