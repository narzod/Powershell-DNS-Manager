@{
    ModuleVersion = '1.0.0'
    GUID = '232ef43a-8180-4835-916d-f336879308bc'
    Author = 'J.S.'
    CompanyName = 'Independent'
    Copyright = '(c) 2025. All rights reserved.'
    Description = 'PowerShell module for managing DNS settings from the command-line'
    PowerShellVersion = '5.1'
    RootModule = 'DnsManager.psm1'
    FunctionsToExport = @('Get-Dns', 'Set-Dns', 'Get-DnsPresets','Reset-Dns','Set-AdBlockDns','Set-CloudflareDns','Set-GoogleDns')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @('dns-google', 'dns-cf', 'dns-adblock', 'dns-reset')
    PrivateData = @{
        PSData = @{
            Tags = @('DNS', 'NameServer', 'AdBlock', 'Network', 'Administration')
            LicenseUri = 'https://github.com/narzod/Powershell-DNS-Manager/blob/main/LICENSE'
            ProjectUri = 'https://github.com/narzod/Powershell-DNS-Manager'
            ReleaseNotes = 'Initial release of DNS Manager PowerShell module'
            DnsPresets = @{
                'Google' = @{
                    Primary = '8.8.8.8'
                    Secondary = '8.8.4.4'
                }
                'Cloudflare' = @{
                    Primary = '1.1.1.1'
                    Secondary = '1.0.0.1'
                }
                'Quad9' = @{
                    Primary = '9.9.9.9'
                    Secondary = '149.112.112.112'
                }
                'OpenDNS' = @{
                    Primary = '208.67.222.222'
                    Secondary = '208.67.220.220'
                }
                'AdGuard' = @{
                    Primary = '94.140.14.14'
                    Secondary = '94.140.15.15'
                }
                'CiscoUmbrella' = @{
                    Primary = '208.67.222.123'
                    Secondary = '208.67.220.123'
                }
                'ComodoSecure' = @{
                    Primary = '8.26.56.26'
                    Secondary = '8.20.247.20'
                }
                'CleanBrowsing' = @{
                    Primary = '185.228.168.9'
                    Secondary = '185.228.169.9'
                }
                'Level3' = @{
                    Primary = '209.244.0.3'
                    Secondary = '209.244.0.4'
                }
                'NortonConnectSafe' = @{
                    Primary = '199.85.126.10'
                    Secondary = '199.85.127.10'
                }
            }
        }
    }
}
