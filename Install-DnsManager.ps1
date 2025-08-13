#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Install or uninstall the DnsManager PowerShell module.

.DESCRIPTION
    Simple installer for the DnsManager module. Installs to system-wide location for all users.

.PARAMETER Uninstall
    Uninstall the module instead of installing it.

.EXAMPLE
    .\Install-DnsManager.ps1
    Installs the DnsManager module.

.EXAMPLE
    .\Install-DnsManager.ps1 -Uninstall
    Uninstalls the DnsManager module.
#>

param(
    [switch]$Uninstall
)

$ModuleName = "DnsManager"
$ScriptPath = Split-Path -Path $PSCommandPath -Parent
$SourcePath = Join-Path -Path $ScriptPath -ChildPath $ModuleName
$DestinationPath = Join-Path -Path $env:ProgramFiles -ChildPath "WindowsPowerShell\Modules\$ModuleName"

# --- UNINSTALL ---
if ($Uninstall) {
    Write-Host "Uninstalling $ModuleName..." -ForegroundColor Yellow
    
    # Remove from memory if loaded
    Get-Module -Name $ModuleName | Remove-Module -Force
    
    # Find and remove installed module
    $InstalledModule = Get-Module -Name $ModuleName -ListAvailable
    if ($InstalledModule) {
        foreach ($Module in $InstalledModule) {
            $ModulePath = Split-Path -Path $Module.Path -Parent
            Write-Host "Removing: $ModulePath" -ForegroundColor Gray
            Remove-Item -Path $ModulePath -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "? $ModuleName uninstalled successfully" -ForegroundColor Green
    } else {
        Write-Host "Module $ModuleName not found - nothing to uninstall" -ForegroundColor Yellow
    }
    return
}

# --- INSTALL ---
Write-Host "Installing $ModuleName..." -ForegroundColor Cyan

# Check if source module folder exists
if (-not (Test-Path -Path $SourcePath)) {
    Write-Error "Module folder '$SourcePath' not found. Ensure the $ModuleName folder is in the same directory as this script."
    exit 1
}

# Check if module manifest exists
$ManifestPath = Join-Path -Path $SourcePath -ChildPath "$ModuleName.psd1"
if (-not (Test-Path -Path $ManifestPath)) {
    Write-Error "Module manifest '$ManifestPath' not found."
    exit 1
}

# Test manifest
try {
    $Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop
    Write-Host "Module version: $($Manifest.Version)" -ForegroundColor Gray
} catch {
    Write-Error "Invalid module manifest: $($_.Exception.Message)"
    exit 1
}

# Check for existing installation
$ExistingModule = Get-Module -Name $ModuleName -ListAvailable | Select-Object -First 1
if ($ExistingModule) {
    Write-Host "Found existing installation (Version: $($ExistingModule.Version))" -ForegroundColor Yellow
    $Choice = Read-Host "Overwrite existing installation? [Y/N]"
    if ($Choice -notmatch '^[Yy]') {
        Write-Host "Installation cancelled" -ForegroundColor Yellow
        return
    }
    
    # Remove existing
    Write-Host "Removing existing installation..." -ForegroundColor Gray
    Get-Module -Name $ModuleName | Remove-Module -Force
    if (Test-Path -Path $DestinationPath) {
        Remove-Item -Path $DestinationPath -Recurse -Force
    }
}

# Create destination directory
Write-Host "Installing to: $DestinationPath" -ForegroundColor Gray
New-Item -Path $DestinationPath -ItemType Directory -Force | Out-Null

# Copy module files
Copy-Item -Path "$SourcePath\*" -Destination $DestinationPath -Recurse -Force

# Verify installation
try {
    Import-Module -Name $ModuleName -Force -ErrorAction Stop
    $InstalledModule = Get-Module -Name $ModuleName
    Write-Host "Installation successful!" -ForegroundColor Green
    Write-Host "  Version: $($InstalledModule.Version)" -ForegroundColor Gray
    Write-Host "  Location: $($InstalledModule.ModuleBase)" -ForegroundColor Gray
} catch {
    Write-Error "Installation failed: $($_.Exception.Message)"
    exit 1
}

# Usage information
Write-Host "`n--- Quick Start ---" -ForegroundColor Cyan
Write-Host "Check current DNS settings:"
Write-Host "  Get-Dns                           # All active interfaces"
Write-Host "  Get-Dns 'Wi-Fi'                   # Specific interface"
Write-Host ""
Write-Host "Change DNS servers:"
Write-Host "  Set-Dns 'Wi-Fi' -DnsPreset 'Google'     # Use preset"
Write-Host "  Set-Dns 'Wi-Fi' -DnsServer '1.1.1.1'    # Manual IP"
Write-Host "  Set-Dns 'Wi-Fi' -Dhcp                   # Back to automatic"
Write-Host ""
Write-Host "Available presets:"
Write-Host "  Get-DnsPresets                    # List all DNS providers"
Write-Host ""
Write-Host "Get help and examples:"
Write-Host "  Get-Help Get-Dns -Examples"
Write-Host "  Get-Help Set-Dns -Examples"
Write-Host "  Get-Command -Module DnsManager    # All available commands"
Write-Host ""
Write-Host "Create your own shortcuts by writing simple wrapper scripts"
Write-Host "To uninstall: .\Install-DnsManager.ps1 -Uninstall"
