# Auto SSL Root Certificate Installer

Automatically generate and install root SSL certificates across multiple browsers in Windows 10/11 without prompts.

## 🚀 Features

- 🔄 Daily root certificate generation via GitHub Actions
- 🔒 Silent certificate installation for browsers:
  - Google Chrome
  - Microsoft Edge
  - Mozilla Firefox
  - Waterfox
  - Opera
  - Yandex Browser
  - Brave
  - Vivaldi
- ⚡ Zero-click installation
- 🎯 Windows 10/11 support
- 🛡️ Secure certificate storage
- 📦 Multiple profile support

## 🔧 Quick Install

Run in PowerShell with admin rights:

    irm https://raw.githubusercontent.com/madfixed/autosslcert/main/install-cert.ps1 | iex

## 📋 Manual Installation

1. Clone the repository:
```cmd
git clone https://github.com/madfixed/autosslcert.git
```

2. Run as Administrator:
```cmd
.\install-cert.ps1
```

## 🔍 How It Works

1. GitHub Actions generates a secure root certificate daily
2. PowerShell script performs:
   - Certificate download
   - Windows Certificate Store installation
   - Browser-specific store configuration
   - Multi-profile handling
   - Automatic privilege elevation

## 🛡️ Security Features

- Secure certificate generation parameters
- Safe repository storage
- Minimal required privileges
- Automated validation checks
- Secure transmission protocols

## 🌐 Browser Support

Detailed browser compatibility:

| Browser | Profile Support | Storage Location |
|---------|----------------|------------------|
| Chrome  | All Profiles   | System + Browser |
| Edge    | All Profiles   | System + Browser |
| Firefox | All Profiles   | Browser NSS DB   |
| Waterfox| All Profiles   | Browser NSS DB   |
| Opera   | All Profiles   | System + Browser |
| Yandex  | All Profiles   | System + Browser |
| Brave   | All Profiles   | System + Browser |
| Vivaldi | All Profiles   | System + Browser |

## ⚙️ Requirements

- Windows 10/11
- PowerShell 5.1+
- Admin rights (auto-elevation included)
- Internet connection

## 📝 License

MIT License

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## 🔄 Update History

- v1.1.0 - Added multi-browser support
- v1.0.0 - Initial release

## 🚀 One-Line Installation

Super-fast installation via PowerShell:
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('[https://raw.githubusercontent.com/madfixed/autosslcert/refs/heads/main/install-cert.ps1]'))
```

## 📞 Support

- Create an issue
- Join discussions
- Check wiki for common solutions
