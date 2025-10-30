# Vérifie si git est installé
Write-Host "Vérification de Git..."
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "Git trouvé. Arrêt des processus en cours..."
    Get-Process git* -ErrorAction SilentlyContinue | Stop-Process -Force
} else {
    Write-Host "Git n'est pas trouvé dans PATH, mais on continue le nettoyage."
}

# Désinstallation avec winget (si installé via winget)
Write-Host "Tentative de désinstallation via winget..."
try {
    winget uninstall --id Git.Git -e --silent
} catch {
    Write-Host "Winget non disponible ou Git pas installé via winget."
}

# Désinstallation via le programme installé (si existant)
Write-Host "Tentative de désinstallation via WMI..."
$gitApp = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "Git*" }
if ($gitApp) {
    $gitApp.Uninstall() | Out-Null
    Write-Host "Git désinstallé via WMI."
} else {
    Write-Host "Aucune entrée Git trouvée via WMI."
}

# Suppression des dossiers Git
Write-Host "Suppression des dossiers Git..."
$paths = @(
    "$env:ProgramFiles\Git",
    "$env:ProgramFiles(x86)\Git",
    "$env:USERPROFILE\.gitconfig",
    "$env:USERPROFILE\.git-credentials",
    "$env:USERPROFILE\.ssh",
    "$env:APPDATA\Git",
    "$env:LOCALAPPDATA\Programs\Git"
)

foreach ($p in $paths) {
    if (Test-Path $p) {
        Remove-Item -Recurse -Force $p
        Write-Host "Supprimé: $p"
    }
}

# Nettoyage des variables d'environnement PATH
Write-Host "Nettoyage du PATH..."
$path = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = ($path.Split(";") | Where-Object {$_ -notmatch "Git"} ) -join ";"
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

$pathUser = [Environment]::GetEnvironmentVariable("Path", "User")
$newPathUser = ($pathUser.Split(";") | Where-Object {$_ -notmatch "Git"} ) -join ";"
[Environment]::SetEnvironmentVariable("Path", $newPathUser, "User")

Write-Host "✅ Git a été purgé complètement. Redémarre ton terminal ou ton PC pour appliquer les changements."
