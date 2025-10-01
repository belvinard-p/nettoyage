@echo off
echo === Arret des services Apache et MySQL ===
net stop Apache2.4 >nul 2>&1
net stop mysql >nul 2>&1
net stop mysqld >nul 2>&1

echo === Suppression des services Windows ===
sc delete Apache2.4 >nul 2>&1
sc delete mysql >nul 2>&1
sc delete mysqld >nul 2>&1

echo === Suppression du dossier XAMPP ===
rmdir /s /q "D:\xampps"

echo === Nettoyage eventuel du PATH (PHP XAMPP) ===
REM Ce nettoyage doit être fait manuellement via les variables d'environnement,
REM car il n'y a pas de commande simple pour enlever une entrée du PATH.

echo === Purge XAMPP terminee ===
pause
