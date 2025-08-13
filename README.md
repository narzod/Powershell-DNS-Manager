# PowerShell DNS Manager

A simple, conventional PowerShell module for quickly checking and changing DNS settings from the command line. This tool provides an easy way to switch between different DNS providers (Google, Cloudflare, ad-blocking services) without the complexity of GUI network settings.

## Features

- **Quick DNS checking**: View current DNS settings for all or specific network interfaces
- **Easy DNS switching**: Change DNS servers with simple commands
- **DNS presets**: Built-in presets for popular providers (Google, Cloudflare, AdGuard, etc.)
- **Tab completion**: Auto-complete for both interface names and DNS preset names
- **DHCP restoration**: Easily revert to automatic DNS settings
- **Input validation**: Validates IP addresses and interface names before applying changes
- **Clean output**: Structured, pipeline-friendly results

## Installation

### Automated Installation (Recommended)

1. **Clone or download this repository**
2. **Run the installer as Administrator**:
   ```powershell
   .\Install-DnsManager.ps1
   ```
   
The installer will check for existing installations, validate the module, and install to the system-wide PowerShell module path for all users.

### Uninstall
```powershell
.\Install-DnsManager.ps1 -Uninstall
```

### Manual Installation
For manual installation, refer to the Installation Guide in the /docs directory.

## Usage

### Check Current DNS Settings
```powershell
# View DNS for all active interfaces
Get-Dns

# View DNS for specific interface (positional parameter)
Get-Dns "Wi-Fi"

# Or use the named parameter
Get-Dns -Interface "Ethernet"
```

### Change DNS Settings
```powershell
# Set Google DNS using preset
Set-Dns -Interface "Wi-Fi" -DnsPreset "Google"

# Set Cloudflare DNS using preset
Set-Dns "Ethernet" -DnsPreset "Cloudflare"

# Use manual IP addresses
Set-Dns -Interface "Wi-Fi" -DnsServer "8.8.8.8", "8.8.4.4"

# Set single DNS server
Set-Dns "Wi-Fi" -DnsServer "9.9.9.9"

# Revert to automatic/DHCP
Set-Dns "Ethernet" -Dhcp
```

### View Available DNS Presets
```powershell
# List all available DNS presets
Get-DnsPresets
```

### Tab Completion Support
Both interface names and DNS presets support tab completion:
```powershell
# Tab completion for interfaces
Set-Dns -Interface <TAB>

# Tab completion for DNS presets
Set-Dns -Interface "Wi-Fi" -DnsPreset <TAB>
```

## Popular DNS Providers

### Public DNS Services
| Provider | Primary DNS | Secondary DNS | Notes |
|----------|-------------|---------------|--------|
| **Google** | `8.8.8.8` | `8.8.4.4` | Fast, reliable, widely used |
| **Cloudflare** | `1.1.1.1` | `1.0.0.1` | Privacy-focused, very fast |
| **Quad9** | `9.9.9.9` | `149.112.112.112` | Security and privacy focused |
| **OpenDNS** | `208.67.222.222` | `208.67.220.220` | Content filtering options |

### Ad-Blocking DNS Services
| Provider | Primary DNS | Secondary DNS | Blocks |
|----------|-------------|---------------|---------|
| **AdGuard** | `94.140.14.14` | `94.140.15.15` | Ads, trackers, malware |
| **CleanBrowsing** | `185.228.168.9` | `185.228.169.9` | Ads, malware, adult content |
| **Quad9 Secured** | `9.9.9.9` | `149.112.112.112` | Malware, phishing |

### Family-Safe DNS
| Provider | Primary DNS | Secondary DNS | Features |
|----------|-------------|---------------|----------|
| **OpenDNS Family** | `208.67.222.123` | `208.67.220.123` | Blocks adult content |
| **CleanBrowsing Family** | `185.228.168.168` | `185.228.169.168` | Family-friendly filtering |

## Creating Custom Shortcuts

DnsManager provides the foundation commands for DNS management. You can easily create your own shortcuts and automation:

### Simple Wrapper Scripts
**GoogleDNS.ps1**:
```powershell
param([string]$Interface = "Wi-Fi")
Set-Dns -Interface $Interface -DnsPreset "Google"
Write-Host "Switched $Interface to Google DNS"
```

**ResetDNS.ps1**:
```powershell
param([string]$Interface = "Wi-Fi")
Set-Dns -Interface $Interface -Dhcp
Write-Host "Reset $Interface to automatic DNS"
```

### PowerShell Profile Aliases
Add to your PowerShell profile (`$PROFILE`):
```powershell
function Set-FastDns { param([string]$Interface = "Wi-Fi"); Set-Dns $Interface -DnsPreset "Cloudflare" }
function Reset-DnsToAuto { param([string]$Interface = "Wi-Fi"); Set-Dns $Interface -Dhcp }
```

This approach lets you create shortcuts tailored to your specific needs while keeping the core module simple and stable.

## Advanced Usage

### Batch Operations
```powershell
# Apply same DNS to multiple interfaces
@("Wi-Fi", "Ethernet") | ForEach-Object {
    Set-Dns -Interface $_ -DnsPreset "Cloudflare"
}

# Check all interfaces and export to file
Get-Dns | Export-Csv -Path "dns-settings.csv" -NoTypeInformation
```

### Getting Help
```powershell
# Detailed help with examples
Get-Help Get-Dns -Examples
Get-Help Set-Dns -Examples

# List all module commands
Get-Command -Module DnsManager
```

## How This Tool Follows PowerShell Best Practices

This DNS Manager demonstrates PowerShell development conventions and showcases the platform's built-in capabilities:

### **Native PowerShell Integration**
- **Leverages existing cmdlets**: Uses `Get-NetAdapter`, `Get-DnsClientServerAddress`, and `Set-DnsClientServerAddress` rather than reinventing functionality
- **Pipeline compatibility**: Returns structured objects that work seamlessly with PowerShell's pipeline
- **Parameter validation**: Uses PowerShell's built-in parameter binding and validation systems

### **PowerShell Module Conventions**
- **Comment-based help**: Comprehensive `.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`, and `.PARAMETER` documentation
- **Proper verb naming**: Follows PowerShell approved verbs (`Get-Dns`, `Set-Dns`)
- **Parameter sets**: Uses `DefaultParameterSetName` to create mutually exclusive parameter groups
- **CmdletBinding**: Enables advanced function features like `-Verbose` and `-WhatIf` support

### **User-Focused Design Patterns**
- **Intelligent defaults**: Shows all active interfaces by default
- **Flexible parameters**: Interface parameter can be positional or named with `-Interface`
- **Clear error messages**: Provides specific, actionable feedback when operations fail
- **Input validation**: Validates IP addresses before attempting DNS changes

## Requirements

- **Operating System**: Windows 10/11 or Windows Server 2016+
- **PowerShell**: Windows PowerShell 5.1 or PowerShell 7+
- **Privileges**: Administrator rights required for DNS changes (must run PowerShell as Administrator)
- **Network**: Active network interfaces

## Troubleshooting

### Common Issues

**"Interface not found"**
- Run `Get-NetAdapter` to see available interface names
- Interface names are case-sensitive and must match exactly

**"Access Denied"**
- Run PowerShell as Administrator before using DNS-changing commands
- DNS changes require administrative privileges

**"Invalid IP address"**
- Verify DNS server addresses are valid IPv4 addresses
- Check for typos in IP addresses

### Getting Interface Names
```powershell
# List all network interfaces
Get-NetAdapter | Select-Object Name, Status, LinkSpeed

# List only active interfaces
Get-NetAdapter | Where-Object Status -eq "Up"
```

## Contributing

This project showcases PowerShell's capabilities for system administration. Contributions that maintain the simplicity and demonstrate additional PowerShell best practices are welcome.

## License

This project is released under the MIT License. Feel free to modify and distribute as needed.
