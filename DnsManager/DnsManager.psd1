@{
    ModuleVersion = '1.3.0'
    GUID = '232ef43a-8180-4835-916d-f336879308bc'
    Author = 'J.S.'
    CompanyName = 'Independent'
    Copyright = '(c) 2025. All rights reserved.'
    Description = 'PowerShell module for managing DNS settings from the command-line with extensive preset configurations'
    PowerShellVersion = '5.1'
    RootModule = 'DnsManager.psm1'
    FunctionsToExport = @('Get-Dns', 'Set-Dns', 'Get-DnsPresets','Reset-Dns','Set-AdBlockDns','Set-CloudflareDns','Set-GoogleDns')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @('dns-google', 'dns-cf', 'dns-adblock', 'dns-reset')
    FileList = @('DnsManager.psm1', 'DnsPresets.psd1')
    PrivateData = @{
        PSData = @{
            Tags = @('DNS', 'NameServer', 'AdBlock', 'Network', 'Administration', 'Security', 'Privacy')
            LicenseUri = 'https://github.com/narzod/Powershell-DNS-Manager/blob/main/LICENSE'
            ProjectUri = 'https://github.com/narzod/Powershell-DNS-Manager'
            ReleaseNotes = @'
v1.3.0 Release Notes:
- Moved to conventional module directory structure (DnsManager/)
- Separated DNS presets into dedicated DnsPresets.psd1 data file for better maintainability
- Expanded DNS preset collection (25+ providers including security, family-safe, and privacy-focused options)
- Improved admin privilege handling with conventional Windows behavior (requires running as Administrator)
- Enhanced Get-DnsPresets to return objects for better PowerShell pipelining and sorting
- Added new DNS providers: Quad9Unsecured, AdGuardFamily, DNS.WATCH, Yandex variants, ControlD, and more
- Improved error handling and user experience
- Updated installation process to follow PowerShell module conventions
'@
            }
    }
}
