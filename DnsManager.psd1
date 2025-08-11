@{
    ModuleVersion = '1.0.0'
    GUID = '232ef43a-8180-4835-916d-f336879308bc'
    Author = 'J.S.'
    CompanyName = 'Independent'
    Copyright = '(c) 2025. All rights reserved.'
    Description = 'PowerShell module for managing DNS settings from the command-line'
    PowerShellVersion = '5.1'
    RootModule = 'DnsManager.psm1'
    FunctionsToExport = @('Get-Dns', 'Set-Dns')
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('DNS', 'NameServer', 'AdBlock', 'Network', 'Administration')
            LicenseUri = 'https://github.com/narzod/Powershell-DNS-Manager/blob/main/LICENSE'
            ProjectUri = 'https://github.com/narzod/Powershell-DNS-Manager'
            ReleaseNotes = 'Initial release of DNS Manager PowerShell module'
        }
    }
}