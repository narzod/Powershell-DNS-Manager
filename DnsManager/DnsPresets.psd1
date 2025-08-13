# ==============================================================================
# DnsPresets.psd1
#
# PowerShell data file defining DNS server presets for quick configuration.
# Each preset contains 'Primary' and 'Secondary' DNS server addresses.
# ==============================================================================
@{
    # Google Public DNS - Fast, reliable general-purpose service
    'Google' = @{
        Primary = '8.8.8.8'
        Secondary = '8.8.4.4'
    }
    
    # Cloudflare Public DNS - Fast, privacy-focused resolver
    'Cloudflare' = @{
        Primary = '1.1.1.1'
        Secondary = '1.0.0.1'
    }

    # Cloudflare Family - Blocks adult content automatically
    'CloudflareFamily' = @{
        Primary = '1.1.1.3'
        Secondary = '1.0.0.3'
    }

    # Cloudflare Malware - Blocks malware and phishing sites
    'CloudflareMalware' = @{
        Primary = '1.1.1.2'
        Secondary = '1.0.0.2'
    }

    # Quad9 - Security-focused, blocks malicious domains
    'Quad9' = @{
        Primary = '9.9.9.9'
        Secondary = '149.112.112.112'
    }

    # Quad9 Unsecured - No malware blocking, faster performance
    'Quad9Unsecured' = @{
        Primary = '9.9.9.10'
        Secondary = '149.112.112.10'
    }

    # OpenDNS Home - Basic content filtering and malware protection
    'OpenDNS' = @{
        Primary = '208.67.222.222'
        Secondary = '208.67.220.220'
    }

    # AdGuard DNS - Blocks ads, trackers, and malware
    'AdGuard' = @{
        Primary = '94.140.14.14'
        Secondary = '94.140.15.15'
    }

    # AdGuard Family - Blocks ads plus adult content
    'AdGuardFamily' = @{
        Primary = '94.140.14.15'
        Secondary = '94.140.15.16'
    }

    # DNS.WATCH - Privacy-focused German service, no logging
    'DNSWatch' = @{
        Primary = '84.200.69.80'
        Secondary = '84.200.70.40'
    }

    # Yandex DNS - Russian service, basic protection
    'Yandex' = @{
        Primary = '77.88.8.8'
        Secondary = '77.88.8.1'
    }

    # Yandex Safe - Blocks malware and phishing
    'YandexSafe' = @{
        Primary = '77.88.8.88'
        Secondary = '77.88.8.2'
    }

    # Yandex Family - Blocks adult content and malware
    'YandexFamily' = @{
        Primary = '77.88.8.7'
        Secondary = '77.88.8.3'
    }

    # Control D - Customizable DNS with various filter options
    'ControlD' = @{
        Primary = '76.76.19.19'
        Secondary = '76.76.2.0'
    }

    # Cisco Umbrella - Enterprise-grade security protection
    'CiscoUmbrella' = @{
        Primary = '208.67.222.123'
        Secondary = '208.67.220.123'
    }

    # Comodo Secure DNS - Protects against phishing and malware
    'ComodoSecure' = @{
        Primary = '8.26.56.26'
        Secondary = '8.20.247.20'
    }

    # CleanBrowsing Family - Family-safe filtering
    'CleanBrowsing' = @{
        Primary = '185.228.168.9'
        Secondary = '185.228.169.9'
    }

    # CleanBrowsing Adult - Blocks adult content only
    'CleanBrowsingAdult' = @{
        Primary = '185.228.168.10'
        Secondary = '185.228.169.11'
    }

    # CleanBrowsing Security - Blocks malware and phishing only
    'CleanBrowsingSecurity' = @{
        Primary = '185.228.168.11'
        Secondary = '185.228.169.12'
    }

    # Alternate DNS - General purpose with basic malware protection
    'AlternateDNS' = @{
        Primary = '76.76.19.19'
        Secondary = '76.223.100.101'
    }

    # UncensoredDNS - No filtering or censorship
    'UncensoredDNS' = @{
        Primary = '91.239.100.100'
        Secondary = '89.233.43.71'
    }

    # Verisign Public DNS - Basic service from domain registry
    'Verisign' = @{
        Primary = '64.6.64.6'
        Secondary = '64.6.65.6'
    }

    # Norton ConnectSafe Family - Blocks malware and adult content
    'NortonConnectSafe' = @{
        Primary = '199.85.126.10'
        Secondary = '199.85.127.10'
    }

    # NextDNS - Customizable filtering (generic endpoints)
    'NextDNS' = @{
        Primary = '45.90.28.188'
        Secondary = '45.90.30.188'
    }

    # Neustar UltraDNS - Enterprise DNS service
    'NeustarUltra' = @{
        Primary = '156.154.70.1'
        Secondary = '156.154.71.1'
    }

    # SafeDNS - Blocks malware, phishing, and adult content
    'SafeDNS' = @{
        Primary = '195.46.39.39'
        Secondary = '195.46.39.40'
    }

    # Hurricane Electric - IPv4/IPv6 capable service
    'HurricaneElectric' = @{
        Primary = '74.82.42.42'
        Secondary = '64.71.168.183'
    }
}