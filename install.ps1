# Installer for blackbox-ml-game on Windows (PowerShell).
# Usage: irm https://raw.githubusercontent.com/0xDevansh/whackamodel-cli/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$repo = '0xDevansh/whackamodel-cli'
$name = 'blackbox-ml-game'   # asset name in bin/
$cmd = 'whackamodel'         # installed command name
$arch = if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64' -or $env:PROCESSOR_ARCHITEW6432 -eq 'ARM64') { 'aarch64' } else { 'x86_64' }
$asset = "$name-windows-$arch.exe"
$dir = if ($env:INSTALL_DIR) { $env:INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'whackamodel\bin' }
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$dest = Join-Path $dir "$cmd.exe"
Write-Host "Downloading $asset ..."
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/$repo/main/bin/$asset" -OutFile $dest
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $dir) {
  [Environment]::SetEnvironmentVariable('Path', "$userPath;$dir", 'User')
  Write-Host "Added $dir to your PATH. Open a new terminal."
}
Write-Host "Installed: $dest"
Write-Host "Run: $cmd list"
