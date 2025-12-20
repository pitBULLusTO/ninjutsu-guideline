# TG - Privacy & Security Research

A collection of research documents, guides, and scripts focused on privacy, anonymity, and secure communications.

## Contents

### Guides

| File | Description |
|------|-------------|
| [VLESS Windows 10.md](VLESS%20Windows%2010.md) | Complete guide for setting up VLESS VPN with v2rayN client on Windows, including TUN mode configuration |
| [VPN Killswitch.md](VPN%20Killswitch.md) | Windows Firewall-based killswitch for VLESS and OpenVPN to prevent traffic leaks |

### Research Documents

| File | Description |
|------|-------------|
| [Anonymous Messages.md](Anonymous%20Messages.md) | Comparison of anonymous messaging methods: Tor, I2P, XMPP, Matrix, P2P messengers, and onion-based solutions |
| [Whonix Big Research.md](Whonix%20Big%20Research.md) | In-depth analysis of Whonix setup, host OS selection (Debian, Kicksecure, Qubes), and VM networking |
| [XMR to USDT.md](XMR%20to%20USDT.md) | Research on cryptocurrency privacy: Monero analysis, attack vectors, and anonymization techniques |

### Scripts

| File | Description |
|------|-------------|
| [vless_openvpn_killswitch.ps1](vless_openvpn_killswitch.ps1) | PowerShell script implementing multi-protocol VPN killswitch using Windows Filtering Platform |

## Topics Covered

- **VPN & Proxy**: VLESS protocol, v2rayN setup, TUN mode, killswitch implementation
- **Anonymous Networks**: Tor, I2P, mix networks, onion services
- **Secure Messaging**: XMPP/OMEMO, Matrix, Ricochet, Cwtch, P2P messengers
- **Operating Systems**: Whonix, Kicksecure, Qubes OS, host OS hardening
- **Cryptocurrency Privacy**: Monero internals, privacy coin comparison, transaction anonymization

## Usage

Most documents are standalone guides. For the PowerShell killswitch:

```powershell
# Enable killswitch (run as Administrator)
.\vless_openvpn_killswitch.ps1

# Disable killswitch
.\vless_openvpn_killswitch.ps1 -Rollback
```

## Disclaimer

This repository is for **educational and research purposes only**. The information provided is intended to help understand privacy technologies and security concepts. Always comply with applicable laws in your jurisdiction.
