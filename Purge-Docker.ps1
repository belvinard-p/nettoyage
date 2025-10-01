# Purge complète Docker : conteneurs, images, volumes, réseaux + dossiers résiduels
# A exécuter en Administrateur

Write-Host "Arrêt de Docker Desktop..." -ForegroundColor Cyan
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue

# Vérifier si la commande docker est dispo
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "Suppression des conteneurs..." -ForegroundColor Cyan
    $containers = docker ps -aq
    if ($containers) { docker rm -f $containers } else { Write-Host "Aucun conteneur trouvé" -ForegroundColor Yellow }

    Write-Host "Suppression des images..." -ForegroundColor Cyan
    $images = docker images -aq
    if ($images) { docker rmi -f $images } else { Write-Host "Aucune image trouvée" -ForegroundColor Yellow }

    Write-Host "Suppression des volumes..." -ForegroundColor Cyan
    $volumes = docker volume ls -q
    if ($volumes) { docker volume rm $volumes } else { Write-Host "Aucun volume trouvé" -ForegroundColor Yellow }

    Write-Host "Suppression des réseaux..." -ForegroundColor Cyan
    $networks = docker network ls -q | Where-Object {$_ -ne "bridge" -and $_ -ne "host" -and $_ -ne "none"}
    if ($networks) { docker network rm $networks } else { Write-Host "Aucun réseau personnalisé trouvé" -ForegroundColor Yellow }
} else {
    Write-Host "La commande docker n'est pas disponible (Docker Desktop est peut-être déjà désinstallé)" -ForegroundColor Yellow
}

Write-Host "Suppression des dossiers Docker résiduels..." -ForegroundColor Cyan

$dossiers = @(
  "C:\ProgramData\Docker",
  "C:\ProgramData\DockerDesktop",
  "$env:LOCALAPPDATA\Docker",
  "$env:APPDATA\Docker",
  "$env:APPDATA\Docker Desktop"
)

foreach ($d in $dossiers) {
    if (Test-Path $d) {
        try {
            Remove-Item -Path $d -Recurse -Force
            Write-Host "Supprimé : $d" -ForegroundColor Green
        } catch {
            Write-Host "Impossible de supprimer $d : $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Dossier absent : $d" -ForegroundColor Yellow
    }
}

Write-Host "Purge complète terminée." -ForegroundColor Cyan
