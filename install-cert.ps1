param (
    [string]$certUrl = "https://raw.githubusercontent.com/madfixed/autosslcert/main/rootCA.pfx",
    [string]$certPassword = "yourpassword"
)

function Install-Certificate {
    param (
        [string]$certPath,
        [string]$password
    )

    try {
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $cert.Import($certPath, $password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet)
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        $store.Add($cert)
        $store.Close()
        Write-Output "Certificate installed in Windows Certificate Store."
    } catch {
        Write-Error "Failed to install certificate in Windows Certificate Store: $_"
        throw
    }
}

function Install-Cert-For-Browser {
    param (
        [string]$browserProfilesPath,
        [string]$certPath,
        [string]$browserName
    )

    try {
        $profiles = Get-ChildItem -Path $browserProfilesPath -Directory -ErrorAction SilentlyContinue
        if ($profiles.Count -gt 0) {
            foreach ($profile in $profiles) {
                $profilePath = Join-Path -Path $profile.FullName -ChildPath "Certificates"
                if (-not (Test-Path -Path $profilePath)) {
                    New-Item -ItemType Directory -Path $profilePath
                }
                Copy-Item -Path $certPath -Destination $profilePath -Force
            }
            Write-Output "Certificate installed in $browserName profiles."
        } else {
            Write-Output "$browserName is not installed or no profiles found."
        }
    } catch {
        Write-Error "Failed to install certificate in $browserName profiles: $_"
    }
}

function Install-Cert-Firefox {
    param (
        [string]$certPath
    )

    try {
        $firefoxProfiles = Get-ChildItem -Path "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory -ErrorAction SilentlyContinue
        if ($firefoxProfiles.Count -gt 0) {
            foreach ($profile in $firefoxProfiles) {
                $nssDbPath = Join-Path -Path $profile.FullName -ChildPath "cert9.db"
                if (Test-Path $nssDbPath) {
                    certutil -A -n "My Root CA" -t "TCu,Cu,Tu" -i $certPath -d sql:$nssDbPath
                }
            }
            Write-Output "Certificate installed in Firefox profiles."
        } else {
            Write-Output "Firefox is not installed or no profiles found."
        }
    } catch {
        Write-Error "Failed to install certificate in Firefox profiles: $_"
    }
}

function Download-Certificate {
    param (
        [string]$url,
        [string]$outputPath
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Write-Output "Certificate downloaded successfully."
    } catch {
        Write-Error "Failed to download certificate: $_"
        throw
    }
}

function Elevate-Privileges {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Elevate privileges if not running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Elevate-Privileges
}

# Main script execution
$certPath = "$env:TEMP\rootCA.pfx"
try {
    Download-Certificate -url $certUrl -outputPath $certPath
    Install-Certificate -certPath $certPath -password $certPassword
    
    Install-Cert-For-Browser -browserProfilesPath "$env:LOCALAPPDATA\Google\Chrome\User Data" -certPath $certPath -browserName "Chrome"
    Install-Cert-For-Browser -browserProfilesPath "$env:LOCALAPPDATA\Microsoft\Edge\User Data" -certPath $certPath -browserName "Edge"
    Install-Cert-For-Browser -browserProfilesPath "$env:APPDATA\Opera Software\Opera Stable" -certPath $certPath -browserName "Opera"
    Install-Cert-For-Browser -browserProfilesPath "$env:LOCALAPPDATA\Yandex\YandexBrowser\User Data" -certPath $certPath -browserName "Yandex Browser"
    Install-Cert-For-Browser -browserProfilesPath "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data" -certPath $certPath -browserName "Brave"
    Install-Cert-For-Browser -browserProfilesPath "$env:LOCALAPPDATA\Vivaldi\User Data" -certPath $certPath -browserName "Vivaldi"
    Install-Cert-Firefox -certPath $certPath
    
    Write-Output "Certificate installation process completed."
} catch {
    Write-Error "An error occurred: $_"
}
