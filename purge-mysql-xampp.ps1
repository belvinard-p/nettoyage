# Run this script as Administrator
Write-Host "=== Purging MySQL and XAMPP from this system ===" -ForegroundColor Yellow

# 1. Stop services if running
$services = "MySQL", "MySQL80", "Apache2.4", "xampp", "xamppapache", "mysqld"
foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Write-Host "Stopping service: $svc"
        Stop-Service -Name $svc -Force
        sc.exe delete $svc | Out-Null
    }
}

# 2. Uninstall MySQL & XAMPP via WMI if present
$apps = "MySQL", "XAMPP"
foreach ($app in $apps) {
    $product = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$app*" }
    foreach ($p in $product) {
        Write-Host "Uninstalling $($p.Name)"
        $p.Uninstall() | Out-Null
    }
}

# 3. Delete leftover directories
$paths = @(
    "C:\Program Files\MySQL",
    "C:\Program Files (x86)\MySQL",
    "C:\ProgramData\MySQL",
    "C:\Users\$env:USERNAME\AppData\Roaming\MySQL",
    "C:\xampp"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Deleting $path"
        Remove-Item -Recurse -Force -Path $path
    }
}

# 4. Clean registry traces (safe removal of MySQL/XAMPP keys)
$regPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Services\MySQL*",
    "HKLM:\SYSTEM\CurrentControlSet\Services\XAMPP*"
)

foreach ($regPath in $regPaths) {
    if (Test-Path $regPath) {
        Write-Host "Removing registry key: $regPath"
        Remove-Item -Recurse -Force -Path $regPath
    }
}

Write-Host "=== Purge Completed. Please Restart Your Computer ===" -ForegroundColor Green
