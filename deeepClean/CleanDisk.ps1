# =============================
#  DEEP WINDOWS 10 CLEANUP SCRIPT
# =============================
Write-Host "`n🧹 Starting deep cleanup on C: drive...`n"

# --- 1. Windows Temp folder ---
Write-Host "→ Cleaning Windows Temp folder..."
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# --- 2. User Temp folders ---
Write-Host "→ Cleaning user Temp folders..."
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TMP\*" -Recurse -Force -ErrorAction SilentlyContinue

# --- 3. Empty Recycle Bin ---
Write-Host "→ Emptying Recycle Bin..."
$shell = New-Object -ComObject Shell.Application
$recycleBin = $shell.Namespace(0xA)
$recycleBin.Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }

# --- 4. Windows Update cache ---
Write-Host "→ Cleaning Windows Update cache..."
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service -Name wuauserv -ErrorAction SilentlyContinue

# --- 5. Delivery Optimization cache ---
Write-Host "→ Clearing Delivery Optimization cache..."
Remove-Item "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue

# --- 6. Windows logs & Prefetch ---
Write-Host "→ Removing old log and Prefetch files..."
Remove-Item "C:\Windows\Logs\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue

# --- 7. Old crash dumps and error reports ---
Write-Host "→ Deleting crash dumps and error reports..."
Remove-Item "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue

# --- 8. Browser caches (Edge + Chrome + Firefox if exists) ---
Write-Host "→ Clearing browser caches..."
$edgeCache = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
$chromeCache = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
$firefoxCache = "$env:APPDATA\Mozilla\Firefox\Profiles"
Remove-Item $edgeCache -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $chromeCache -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$firefoxCache\*\cache2" -Recurse -Force -ErrorAction SilentlyContinue

# --- 9. User Downloads older than 30 days (optional, comment out to keep files) ---
Write-Host "→ Removing files older than 30 days from Downloads..."
$downloadFolder = "$env:USERPROFILE\Downloads"
Get-ChildItem $downloadFolder -Recurse -ErrorAction SilentlyContinue |
    Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item -Force -ErrorAction SilentlyContinue

# --- 10. Disable and delete hibernation file (frees 3–10 GB) ---
Write-Host "→ Disabling Hibernation..."
powercfg -h off | Out-Null

# --- 11. Component Store cleanup ---
Write-Host "→ Cleaning up Windows Component Store (can take a few minutes)..."
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null

# --- 12. Old system restore points (keep latest only) ---
Write-Host "→ Deleting old restore points..."
vssadmin delete shadows /for=C: /oldest /quiet | Out-Null

# --- 13. Clear temp installers and cache files ---
Write-Host "→ Removing leftover installers..."
Remove-Item "C:\Users\*\AppData\Local\Temp\*.tmp" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Installer\$PatchCache$" -Recurse -Force -ErrorAction SilentlyContinue

# --- 14. Report space before & after ---
# --- 14. Report space before & after ---
Write-Host "`n✅ Cleanup complete! Checking disk space..." -ForegroundColor Green
$drive = Get-PSDrive -Name C
$freeGB = [math]::Round($drive.Free / 1GB, 2)
$totalGB = [math]::Round($drive.Used + $drive.Free) / 1GB
$totalGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 2)
Write-Host ("Free space on C: {0} GB out of {1} GB" -f $freeGB, $totalGB) -ForegroundColor Cyan

Write-Host "`n💡 Tip: Run this script monthly to keep your system optimized." -ForegroundColor Yellow
Write-Host "   You can also open 'cleanmgr' for additional safe Windows cleanup options.`n" -ForegroundColor Yellow
