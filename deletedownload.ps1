# Supprime tous les fichiers et dossiers du répertoire Téléchargements
$downloadPath = "$env:USERPROFILE\Downloads"
Remove-Item -Path "$downloadPath\*" -Recurse -Force
Write-Output "Tous les fichiers téléchargés ont été supprimés."
