# Advanced Root Certificate Installation Script
param(
    [string]$CertificateUrl = "https://raw.githubusercontent.com/madfixed/autosslcert/refs/heads/main/root-ca.crt?token=GHSAT0AAAAAAC4ALBCWC3RN6NA72W3GXS6AZ3W7QKQ",
    [string]$CertificatePath = "$env:TEMP\root-ca.crt",
    [switch]$Verbose = $false
)

# Logging function
function Write-Log {
    param([string]$Message, [switch]$Error)
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    
    if ($Error) {
        Write-Host $logMessage -ForegroundColor Red
        Add-Content -Path "$env:TEMP\certificate_install.log" -Value "ERROR: $logMessage"
    } else {
        if ($Verbose) {
            Write-Host $logMessage -ForegroundColor Green
        }
        Add-Content -Path "$env:TEMP\certificate_install.log" -Value "INFO: $logMessage"
    }
}

# Advanced Browser Detection Function
function Get-InstalledBrowsers {
    $browsers = @{
        # Chromium-based browsers
        "Google Chrome" = @{
            Paths = @(
                "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe",
                "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
                "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
            )
            Type = "Chromium"
            CertStore = "$env:LOCALAPPDATA\Google\Chrome\User Data\*\Security\roots"
        }
        "Microsoft Edge" = @{
            Paths = @(
                "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
                "${env:ProgramFiles}\Microsoft\Edge\Application\msedge.exe"
            )
            Type = "Chromium"
            CertStore = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\*\Security\roots"
        }
        "Brave Browser" = @{
            Paths = @(
                "${env:ProgramFiles}\BraveSoftware\Brave-Browser\Application\brave.exe",
                "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe"
            )
            Type = "Chromium"
            CertStore = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\*\Security\roots"
        }
        "Vivaldi" = @{
            Paths = @(
                "${env:ProgramFiles}\Vivaldi\Application\vivaldi.exe",
                "$env:LOCALAPPDATA\Vivaldi\Application\vivaldi.exe"
            )
            Type = "Chromium"
            CertStore = "$env:LOCALAPPDATA\Vivaldi\User Data\*\Security\roots"
        }

        # Mozilla-based browsers
        "Mozilla Firefox" = @{
            Paths = @(
                "${env:ProgramFiles}\Mozilla Firefox\firefox.exe",
                "${env:ProgramFiles(x86)}\Mozilla Firefox\firefox.exe"
            )
            Type = "Mozilla"
            CertStore = "$env:APPDATA\Mozilla\Firefox\Profiles\*.default\cert9.db"
        }
        "Waterfox" = @{
            Paths = @(
                "${env:ProgramFiles}\Waterfox\waterfox.exe",
                "$env:LOCALAPPDATA\Waterfox\waterfox.exe"
            )
            Type = "Mozilla"
            CertStore = "$env:APPDATA\Waterfox\Profiles\*.default\cert9.db"
        }
        "LibreWolf" = @{
            Paths = @(
                "${env:ProgramFiles}\LibreWolf\librewolf.exe",
                "$env:LOCALAPPDATA\LibreWolf\librewolf.exe"
            )
            Type = "Mozilla"
            CertStore = "$env:APPDATA\librewolf\Profiles\*.default\cert9.db"
        }
        "Pale Moon" = @{
            Paths = @(
                "${env:ProgramFiles}\Pale Moon\palemoon.exe",
                "$env:LOCALAPPDATA\Pale Moon\palemoon.exe"
            )
            Type = "Mozilla"
            CertStore = "$env:APPDATA\Pale Moon\Profiles\*.default\cert9.db"
        }
    }

    $installedBrowsers = @{}

    foreach ($browserName in $browsers.Keys) {
        $browserInfo = $browsers[$browserName]
        $exePath = $browserInfo.Paths | Where-Object { Test-Path $_ } | Select-Object -First 1
        
        if ($exePath) {
            $installedBrowsers[$browserName] = @{
                Path = $exePath
                Type = $browserInfo.Type
                CertStore = $browserInfo.CertStore
            }
            Write-Log "Detected $browserName at $exePath"
        }
    }

    return $installedBrowsers
}

# Certificate Installation Functions
function Install-WindowsCertificate {
    try {
        Import-Certificate -FilePath $CertificatePath -CertStoreLocation "Cert:\LocalMachine\Root"
        Write-Log "Certificate added to Windows Root store successfully"
    }
    catch {
        Write-Log "Failed to add certificate to Windows Root store" -Error
    }
}

function Install-BrowserCertificates {
    $installedBrowsers = Get-InstalledBrowsers

    foreach ($browserName in $installedBrowsers.Keys) {
        $browser = $installedBrowsers[$browserName]
        
        try {
            switch ($browser.Type) {
                "Chromium" {
                    # Chromium browsers typically inherit Windows certificate store
                    Write-Log "Chromium browser $browserName uses system certificate store"
                }
                "Mozilla" {
                    # Mozilla browsers require certutil
                    $certDbPaths = Resolve-Path $browser.CertStore
                    foreach ($certDbPath in $certDbPaths) {
                        certutil -A -n "Custom Root Certificate" -t "C,C,C" -i $CertificatePath -d $certDbPath
                        Write-Log "Certificate added to $browserName certificate store"
                    }
                }
            }
        }
        catch {
            Write-Log "Failed to add certificate to $browserName" -Error
        }
    }
}

# Main Execution
try {
    # Download Certificate
    Invoke-WebRequest -Uri $CertificateUrl -OutFile $CertificatePath

    # Install Certificates
    Install-WindowsCertificate
    Install-BrowserCertificates

    Write-Log "Certificate installation completed successfully"
}
catch {
    Write-Log "Certificate installation failed" -Error
}
finally {
    # Clean up
    Remove-Item $CertificatePath -ErrorAction SilentlyContinue
}
