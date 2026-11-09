$ErrorActionPreference = 'Stop'

$php = Get-Command php -ErrorAction SilentlyContinue
if (-not $php) {
    throw "PHP was not found. Install PHP 8+ and add php.exe to PATH."
}

$smtpUser = Read-Host "Gmail address to send FinWise reset and verification codes"
if ($smtpUser -notmatch '^[^@\s]+@[^@\s]+\.[^@\s]+$') {
    throw "Enter a valid Gmail address."
}

function ConvertFrom-SecureInput([System.Security.SecureString]$Value) {
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToGlobalAllocUnicode($Value)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringUni($pointer)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeGlobalAllocUnicode($pointer)
    }
}

$smtpPassword = ConvertFrom-SecureInput (Read-Host "Gmail App Password (input is hidden)" -AsSecureString)
if ([string]::IsNullOrWhiteSpace($smtpPassword)) {
    throw "An SMTP App Password is required to send real emails."
}

$env:SMTP_HOST = 'smtp.gmail.com'
$env:SMTP_PORT = '587'
$env:SMTP_ENCRYPTION = 'tls'
$env:SMTP_USER = $smtpUser
$env:SMTP_PASS = $smtpPassword -replace '\s', ''
$env:SMTP_FROM_EMAIL = $smtpUser
$env:SMTP_FROM_NAME = 'FinWise Campus Banking'
$env:SMTP_SIMULATE = 'false'
Remove-Variable smtpPassword

if (-not $env:DB_HOST) { $env:DB_HOST = Read-Host "MySQL host [127.0.0.1]"; if (-not $env:DB_HOST) { $env:DB_HOST = '127.0.0.1' } }
if (-not $env:DB_PORT) { $env:DB_PORT = Read-Host "MySQL port [3306]"; if (-not $env:DB_PORT) { $env:DB_PORT = '3306' } }
if (-not $env:DB_NAME) { $env:DB_NAME = Read-Host "Database name [finwise_db]"; if (-not $env:DB_NAME) { $env:DB_NAME = 'finwise_db' } }
if (-not $env:DB_USER) { $env:DB_USER = Read-Host "MySQL username [root]"; if (-not $env:DB_USER) { $env:DB_USER = 'root' } }
if ($null -eq $env:DB_PASS) {
    $dbPassword = ConvertFrom-SecureInput (Read-Host "MySQL password (input is hidden; leave blank if none)" -AsSecureString)
    $env:DB_PASS = $dbPassword
    Remove-Variable dbPassword
}

$projectRoot = Split-Path -Parent $PSScriptRoot
Write-Host "FinWise API: http://localhost:8000/backend/api/" -ForegroundColor Cyan
Write-Host "Android emulator API: http://10.0.2.2:8000/backend/api/" -ForegroundColor Cyan
Write-Host "Keep this window open while using the app. Press Ctrl+C to stop the server." -ForegroundColor Yellow

try {
    & $php.Source -S '0.0.0.0:8000' -t $projectRoot
} finally {
    Remove-Item Env:SMTP_PASS -ErrorAction SilentlyContinue
    Remove-Item Env:DB_PASS -ErrorAction SilentlyContinue
}
