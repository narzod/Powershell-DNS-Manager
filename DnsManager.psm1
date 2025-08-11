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
    Reverts the 'Wi-Fi' interface to use DHCP. This will prompt for elevation.

.PARAMETER Interface
    The name of the network interface to be modified.

.PARAMETER DnsServer
    One or more IP addresses for the new DNS servers. The first is primary, others are secondary.

.PARAMETER Dhcp
    A switch to revert the interface to use DNS from DHCP (automatic).
#>
function Set-Dns {
    [CmdletBinding(DefaultParameterSetName='SetDns')]
    param(
        [Parameter(Mandatory=$true, Position=0, HelpMessage='The name of the network interface.')]
        [string]$Interface,
        
        [Parameter(ParameterSetName='SetDns', Mandatory=$false)]
        [string[]]$DnsServer,
        
        [Parameter(ParameterSetName='Dhcp', Mandatory=$true)]
        [switch]$Dhcp
    )

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
                "-$($_.Key) '$($_.Value -join "','")'"
            } elseif ($_.Value -is [switch] -and $_.Value) {
                "-$($_.Key)"
            } else {
                "-$($_.Key) '$($_.Value)'"
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

    # Handle the case where no DnsServer is provided
    if ($null -eq $DnsServer) {
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