# 
# DnsManager.psm1
#
# This file contains the functions for the DnsManager PowerShell module.

<#
.SYNOPSIS
    Retrieves and displays the DNS presets from the module manifest.

.DESCRIPTION
    This command-line tool fetches a list of predefined DNS server configurations,
    such as Google or Cloudflare, from the DnsManager module's manifest file.

.EXAMPLE
    Get-DnsPresets
    Displays a table of all available DNS presets with their primary
    and secondary server addresses.
#>
function Get-DnsPresets {
    [CmdletBinding()]
    param()

    # Get the module object to access the manifest's private data
    $module = Get-Module -Name DnsManager

    if ($null -eq $module) {
        Write-Error "DnsManager module is not loaded."
        return
    }

    $presets = $module.PrivateData.PSData.DnsPresets

    if ($null -eq $presets) {
        Write-Warning "No DNS presets found in the module manifest."
        return
    }

    # Create a custom object for each preset to format the output
    $presets.Keys | ForEach-Object {
        $presetName = $_
        $presetData = $presets[$presetName]
        [PSCustomObject]@{
            Name = $presetName
            Primary = $presetData.Primary
            Secondary = $presetData.Secondary
        }
    } | Format-Table -AutoSize
}

# This is a private helper function and will not be exported.
# It's used by Set-Dns to resolve a preset name to its IP addresses.
function Get-DnsPreset {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$PresetName
    )

    $module = Get-Module -Name DnsManager
    if ($null -eq $module) {
        Write-Error "DnsManager module is not loaded."
        return
    }
    
    $presets = $module.PrivateData.PSData.DnsPresets
    
    if ($presets.ContainsKey($PresetName)) {
        return $presets[$PresetName]
    } else {
        Write-Error "Preset '$PresetName' not found."
        return $null
    }
}

# This is a private helper function and will not be exported.
# It's used by the ArgumentCompleter for tab completion.
function Get-PresetNames {
    param(
        [string]$wordToComplete = ''
    )
    
    $module = Get-Module -Name DnsManager
    if ($null -eq $module) {
        # If the module isn't loaded, return an empty array to prevent errors.
        return @()
    }
    
    # Get preset names and filter based on what user has typed
    $presetNames = $module.PrivateData.PSData.DnsPresets.Keys
    
    # Filter results based on what the user has typed so far
    if ($wordToComplete) {
        $presetNames | Where-Object { $_ -like "$wordToComplete*" }
    } else {
        $presetNames
    }
}

<#
.SYNOPSIS
    Gets DNS settings for network interfaces.

.DESCRIPTION
    This tool retrieves the current DNS server addresses for one or more network
    interfaces on your computer. By default, it lists all active interfaces.

.EXAMPLE
    Get-Dns
    Displays the DNS servers for all active network interfaces.

.EXAMPLE
    Get-Dns -Interface 'Ethernet'
    Displays the DNS servers for the 'Ethernet' interface only.

.PARAMETER Interface
    Specifies the name of the network interface for which to retrieve DNS information.
#>
function Get-Dns {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # Get available network interfaces
            try {
                $interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty Name
                
                # Filter based on what user has typed
                $results = if ($wordToComplete) {
                    $interfaces | Where-Object { $_ -like "$wordToComplete*" }
                } else {
                    $interfaces
                }
                
                # Return as CompletionResult objects
                return $results | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        "'$_'",           # CompletionText (quoted to handle spaces)
                        $_,               # ListItemText  
                        'ParameterValue', # ResultType
                        "Network Interface: $_"  # ToolTip
                    )
                }
            } catch {
                # If Get-NetAdapter fails, return empty array
                return @()
            }
        })]
        [string]$Interface
    )

    # Use Get-NetAdapter to find interfaces, filtering if a name is specified
    $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }

    if ($PSBoundParameters.ContainsKey('Interface')) {
        $adapters = $adapters | Where-Object { $_.Name -eq $Interface }
    }

    if (-not $adapters) {
        Write-Warning "No active network interfaces found."
        return
    }

    $adapters | ForEach-Object {
        $currentDns = (Get-DnsClientServerAddress -InterfaceAlias $_.Name -ErrorAction SilentlyContinue).ServerAddresses
        $dnsString = if ($currentDns) { $currentDns -join ', ' } else { 'DHCP' }

        [pscustomobject]@{
            InterfaceName = $_.Name
            ConnectionStatus = $_.Status
            CurrentDnsServers = $dnsString
        }
    } | Format-Table -AutoSize
}

<#
.SYNOPSIS
    Sets DNS settings for a network interface.

.DESCRIPTION
    This tool modifies the DNS server settings for a network interface.
    It requires administrative privileges and will prompt for them if needed.

.EXAMPLE
    Set-Dns -Interface 'Ethernet' -DnsServer '8.8.8.8', '8.8.4.4'
    Sets Google DNS for the 'Ethernet' interface. This will prompt for elevation.

.EXAMPLE
    Set-Dns -Interface 'Wi-Fi' -Dhcp
    Reverts the 'Wi-Fi' interface to use DNS from DHCP (automatic). This will prompt for elevation.
    
.EXAMPLE
    Set-Dns -Interface 'Ethernet' -DnsPreset 'Google'
    Sets DNS using the 'Google' preset defined in the module manifest.

.PARAMETER Interface
    The name of the network interface to be modified.

.PARAMETER DnsServer
    One or more IP addresses for the new DNS servers. The first is primary, others are secondary.
    This parameter is part of the 'ManualIP' parameter set.

.PARAMETER DnsPreset
    The name of a DNS preset defined in the module manifest.
    This parameter is part of the 'PresetName' parameter set. The available presets
    are automatically populated for tab completion.

.PARAMETER Dhcp
    A switch to revert the interface to use DNS from DHCP (automatic).
    This parameter is part of the 'Dhcp' parameter set.
#>
function Set-Dns {
    [CmdletBinding(DefaultParameterSetName='ManualIP')]
    param(
        [Parameter(Mandatory=$true, Position=0, HelpMessage='The name of the network interface.')]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # Get available network interfaces
            try {
                $interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty Name
                
                # Filter based on what user has typed
                $results = if ($wordToComplete) {
                    $interfaces | Where-Object { $_ -like "$wordToComplete*" }
                } else {
                    $interfaces
                }
                
                # Return as CompletionResult objects
                return $results | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        "'$_'",           # CompletionText (quoted to handle spaces)
                        $_,               # ListItemText  
                        'ParameterValue', # ResultType
                        "Network Interface: $_"  # ToolTip
                    )
                }
            } catch {
                # If Get-NetAdapter fails, return empty array
                return @()
            }
        })]
        [string]$Interface,
        
        [Parameter(ParameterSetName='ManualIP', Mandatory=$false)]
        [string[]]$DnsServer,
        
        [Parameter(ParameterSetName='PresetName', Mandatory=$true)]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # Get the module and presets directly in the completer
            $module = Get-Module -Name DnsManager
            if ($null -eq $module -or $null -eq $module.PrivateData.PSData.DnsPresets) {
                return @()
            }
            
            $presets = $module.PrivateData.PSData.DnsPresets.Keys
            
            # Filter and return completion results
            $results = if ($wordToComplete) {
                $presets | Where-Object { $_ -like "$wordToComplete*" }
            } else {
                $presets
            }
            
            # Return as CompletionResult objects to override file completion
            return $results | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new(
                    $_,           # CompletionText
                    $_,           # ListItemText  
                    'ParameterValue', # ResultType
                    "DNS Preset: $_"  # ToolTip
                )
            }
        })]
        [ValidateScript({
            $module = Get-Module -Name DnsManager
            if ($null -ne $module -and $null -ne $module.PrivateData.PSData.DnsPresets) {
                return $module.PrivateData.PSData.DnsPresets.ContainsKey($_)
            }
            return $false
        })]
        [string]$DnsPreset,
        
        [Parameter(ParameterSetName='Dhcp', Mandatory=$true)]
        [switch]$Dhcp
    )
    
    # Check if a preset name was provided and get the IPs
    if ($PSCmdlet.ParameterSetName -eq 'PresetName') {
        $presetData = Get-DnsPreset -PresetName $DnsPreset
        if ($null -eq $presetData) {
            # Error message is handled by Get-DnsPreset
            return
        }
        $DnsServer = @($presetData.Primary, $presetData.Secondary)
    }
    
    # Validate DNS server IP addresses if provided
    if ($DnsServer) {
        foreach ($dns in $DnsServer) {
            if (-not [System.Net.IPAddress]::TryParse($dns, [ref]$null)) {
                Write-Error "Invalid IP address: $dns"
                return
            }
        }
    }
    
    # Check for elevation and re-run as admin if needed
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This command requires administrative privileges. Please approve the UAC prompt."
        
        # Build parameter string for elevation
        $params = $PSBoundParameters
        $paramString = ($params.GetEnumerator() | ForEach-Object { 
            if ($_.Value -is [array]) {
                "-{0} '{1}'" -f $_.Key, ($_.Value -join "','")
            } elseif ($_.Value -is [switch] -and $_.Value) {
                "-{0}" -f $_.Key
            } else {
                "-{0} '{1}'" -f $_.Key, $_.Value
            }
        }) -join ' '
        
        $command = "Import-Module DnsManager; Set-Dns $paramString"
        Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", $command
        return
    }

    # Verify that the specified interface exists
    $adapter = Get-NetAdapter -Name $Interface -ErrorAction SilentlyContinue
    if (-not $adapter) {
        Write-Error "Interface '$Interface' not found."
        return
    }

    # Handle the Dhcp switch
    if ($PSCmdlet.ParameterSetName -eq 'Dhcp') {
        Write-Host "Reverting '$Interface' to automatic DNS..."
        try {
            Set-DnsClientServerAddress -InterfaceAlias $Interface -ResetServerAddresses
            [PSCustomObject]@{
                Interface = $Interface
                Action = "Reset to DHCP"
                DnsServers = "Automatic"
                Status = "Success"
            }
        } catch {
            Write-Error "Failed to reset DNS for interface '$Interface': $($_.Exception.Message)"
            return
        }
        return
    }
    
    # Handle the case where no DnsServer is provided (in the manual set)
    if ($null -eq $DnsServer -and $PSCmdlet.ParameterSetName -eq 'ManualIP') {
        Write-Host "No DNS servers were provided. No changes have been made."
        return
    }

    # Handle setting new DNS servers
    Write-Host "Setting DNS for '$Interface' to: $($DnsServer -join ', ')"
    try {
        Set-DnsClientServerAddress -InterfaceAlias $Interface -ServerAddresses $DnsServer
        [PSCustomObject]@{
            Interface = $Interface
            Action = "Set DNS"
            DnsServers = $DnsServer -join ', '
            Status = "Success"
        }
    } catch {
        Write-Error "Failed to set DNS for interface '$Interface': $($_.Exception.Message)"
        return
    }
}

# Preset functions for common DNS providers
function Set-GoogleDns {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # Get available network interfaces
            try {
                $interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty Name
                
                # Filter based on what user has typed
                $results = if ($wordToComplete) {
                    $interfaces | Where-Object { $_ -like "$wordToComplete*" }
                } else {
                    $interfaces
                }
                
                # Return as CompletionResult objects
                return $results | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        "'$_'",           # CompletionText (quoted to handle spaces)
                        $_,               # ListItemText  
                        'ParameterValue', # ResultType
                        "Network Interface: $_"  # ToolTip
                    )
                }
            } catch {
                # If Get-NetAdapter fails, return empty array
                return @()
            }
        })]
        [string]$Interface = "Wi-Fi"
    )
    Set-Dns -Interface $Interface -DnsPreset "Google"
}

function Set-CloudflareDns {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # Get available network interfaces
            try {
                $interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty Name
                
                # Filter based on what user has typed
                $results = if ($wordToComplete) {
                    $interfaces | Where-Object { $_ -like "$wordToComplete*" }
                } else {
                    $interfaces
                }
                
                # Return as CompletionResult objects
                return $results | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        "'$_'",           # CompletionText (quoted to handle spaces)
                        $_,               # ListItemText  
                        'ParameterValue', # ResultType
                        "Network Interface: $_"  # ToolTip
                    )
                }
            } catch {
                # If Get-NetAdapter fails, return empty array
                return @()
            }
        })]
        [string]$Interface = "Wi-Fi"
    )
    Set-Dns -Interface $Interface -DnsPreset "Cloudflare"
}

function Set-AdBlockDns {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # Get available network interfaces
            try {
                $interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty Name
                
                # Filter based on what user has typed
                $results = if ($wordToComplete) {
                    $interfaces | Where-Object { $_ -like "$wordToComplete*" }
                } else {
                    $interfaces
                }
                
                # Return as CompletionResult objects
                return $results | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        "'$_'",           # CompletionText (quoted to handle spaces)
                        $_,               # ListItemText  
                        'ParameterValue', # ResultType
                        "Network Interface: $_"  # ToolTip
                    )
                }
            } catch {
                # If Get-NetAdapter fails, return empty array
                return @()
            }
        })]
        [string]$Interface = "Wi-Fi"
    )
    Set-Dns -Interface $Interface -DnsPreset "AdGuard"
}

function Reset-Dns {
    [CmdletBinding()]
    param(
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
            
            # Get available network interfaces
            try {
                $interfaces = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -ExpandProperty Name
                
                # Filter based on what user has typed
                $results = if ($wordToComplete) {
                    $interfaces | Where-Object { $_ -like "$wordToComplete*" }
                } else {
                    $interfaces
                }
                
                # Return as CompletionResult objects
                return $results | ForEach-Object {
                    [System.Management.Automation.CompletionResult]::new(
                        "'$_'",           # CompletionText (quoted to handle spaces)
                        $_,               # ListItemText  
                        'ParameterValue', # ResultType
                        "Network Interface: $_"  # ToolTip
                    )
                }
            } catch {
                # If Get-NetAdapter fails, return empty array
                return @()
            }
        })]
        [string]$Interface = "Wi-Fi"
    )
    Set-Dns -Interface $Interface -Dhcp
}

# Create convenient aliases
New-Alias -Name "dns-google" -Value "Set-GoogleDns"
New-Alias -Name "dns-cf" -Value "Set-CloudflareDns" 
New-Alias -Name "dns-adblock" -Value "Set-AdBlockDns"
New-Alias -Name "dns-reset" -Value "Reset-Dns"