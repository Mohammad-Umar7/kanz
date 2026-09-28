<#
.SYNOPSIS
    Run the Kanz API on this computer (Windows PowerShell).

.DESCRIPTION
    Creates backend/.venv on first run, installs requirements.txt whenever it changes,
    creates backend/.env from .env.example if it is missing, prints the URLs to use from
    the Android emulator and from a phone on the same Wi-Fi, then starts uvicorn.

.PARAMETER Reload
    Restart automatically when code or prompts change (development only).

.PARAMETER Port
    Port to listen on. Default 8000.

.EXAMPLE
    ./run.ps1
.EXAMPLE
    ./run.ps1 -Reload -Port 8100
#>
[CmdletBinding()]
param(
    [switch]$Reload,
    [int]$Port = 8000
)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

# --- Virtual environment -------------------------------------------------------------
$python = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $python)) {
    Write-Host 'Creating the virtual environment in backend/.venv ...'
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3.11 -m venv .venv
    } else {
        & python -m venv .venv
    }
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path $python)) {
        throw 'Could not create the virtual environment. Install Python 3.11 and try again.'
    }
}

# --- Requirements (reinstalled only when requirements.txt changes) --------------------
$stamp = Join-Path $PSScriptRoot '.venv\.requirements.sha256'
$wanted = (Get-FileHash -Algorithm SHA256 -Path 'requirements.txt').Hash
$installed = if (Test-Path $stamp) { (Get-Content -Path $stamp -Raw).Trim() } else { '' }
if ($installed -ne $wanted) {
    Write-Host 'Installing requirements ...'
    & $python -m pip install --disable-pip-version-check --quiet -r requirements.txt
    if ($LASTEXITCODE -ne 0) { throw 'pip install failed; see the messages above.' }
    Set-Content -Path $stamp -Value $wanted -Encoding ascii
}

# --- Secrets --------------------------------------------------------------------------
if (-not (Test-Path '.env')) {
    Copy-Item -Path '.env.example' -Destination '.env'
    Write-Warning 'Created backend/.env from .env.example. Put your GEMINI_API_KEY in it, then restart.'
}

# --- Where to point the app -------------------------------------------------------------
$lan = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notmatch '^(127\.|169\.254\.)' -and $_.AddressState -eq 'Preferred' } |
    Sort-Object -Property InterfaceAlias)

Write-Host ''
Write-Host "Kanz API on port $Port"
Write-Host ("  {0,-20} http://127.0.0.1:{1}/docs" -f 'This computer', $Port)
Write-Host ("  {0,-20} http://10.0.2.2:{1}" -f 'Android emulator', $Port)
foreach ($address in $lan) {
    Write-Host ("  {0,-20} http://{1}:{2}   ({3})" -f 'Phone on same Wi-Fi', $address.IPAddress, $Port, $address.InterfaceAlias)
}
Write-Host '  If the phone cannot connect, allow Python through Windows Defender Firewall on private networks.'
Write-Host ''

# --- Serve ------------------------------------------------------------------------------
$uvicornArgs = @('-m', 'uvicorn', 'app.main:app', '--host', '0.0.0.0', '--port', "$Port")
if ($Reload) {
    $uvicornArgs += @('--reload', '--reload-dir', 'app', '--reload-dir', 'prompts')
}
& $python @uvicornArgs
exit $LASTEXITCODE
