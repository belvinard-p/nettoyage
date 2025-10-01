# Supprimer les dossiers résiduels Docker sur Windows
# A exécuter en Administrateur

Write-Host "Suppression des dossiers Docker résiduels..." -ForegroundColor Cyan

# Liste des dossiers à supprimer
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

Write-Host "Nettoyage terminé." -ForegroundColor Cyan
