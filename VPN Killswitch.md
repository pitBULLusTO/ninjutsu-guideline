# Multi-Protocol Killswitch Guide (Windows 10/11)

This solution uses the native Windows Filtering Platform (Windows Firewall) to block **all** traffic by default, only allowing traffic passing through your VPN interfaces or specific VPN client processes.

### ⚠️ Prerequisites
*   **Administrator Rights:** You must run PowerShell as Admin.
*   **Correct Paths:** You **must** verify the location of your `v2rayN` folder in the script settings below.

---

## 1. Prepare the Script

1.  Create a new text file on your Desktop named `killswitch.ps1`.
2.  Open it with Notepad or a Code Editor.
3.  **Copy and paste the code below.**

```powershell
<#
.SYNOPSIS
    Universal VPN Killswitch for VLESS (sing-box/Xray) and OpenVPN.
    Runs on Windows Firewall.
    
.DESCRIPTION
    1. Sets Default Outbound Action to BLOCK.
    2. Whitelists the VPN TUN interfaces (singbox_tun / OpenVPN).
    3. Whitelists the VPN Client executables (xray.exe, openvpn.exe) so they can connect.
    4. Whitelists local services (DNS via VPN, DHCP, NTP).

.USAGE
    Run as Administrator.
    .\killswitch.ps1           -> Enables Killswitch
    .\killswitch.ps1 -Rollback -> Disables Killswitch (Restores Internet)
#>

param(
    [switch]$Rollback
)

# ==========================================
#              SETTINGS
# ==========================================

# 1. Name of the firewall group for easy cleanup
$Group = "VLESS_OpenVPN_KillSwitch"

# 2. Interface Names (Must match Get-NetAdapter output exactly)
$TunIfSing  = "singbox_tun"
$OpenVpnIf  = "OpenVPN Data Channel Offload"

# 3. Path to your VPN Exe files
# IMPORTANT: Verfiy these paths match your installation!
# We use $env:USERPROFILE to automatically detect your user folder (e.g., C:\Users\Name)

$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Adjust the folder name "v2rayN-windows-64" if yours is named differently
$XrayPath    = "$DesktopPath\v2rayN-windows-64\bin\xray\xray.exe"
$SingBoxPath = "$DesktopPath\v2rayN-windows-64\bin\sing_box\sing-box.exe"

# Standard OpenVPN Path
$OpenVpnPath = "C:\Program Files\OpenVPN\bin\openvpn.exe"

# 4. Allow LAN Access? (Printers, Local Shares)
$AllowLAN = $true

# ==========================================


function Ensure-Admin {
    $Current = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $Current.IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
        Write-Error "[-] Access Denied. Please run PowerShell as Administrator."
        exit 1
    }
}

function Create-KillSwitch {
    Write-Host "[*] Activating Killswitch..." -ForegroundColor Cyan

    # 1. Clean up old rules first
    Remove-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue

    # 2. Whitelist Loopback (Required for local proxying 127.0.0.1)
    New-NetFirewallRule -Group $Group -DisplayName "KS Allow Loopback" -Direction Outbound -Action Allow -RemoteAddress 127.0.0.0/8 -Profile Any | Out-Null
    Write-Host " [+] Allowed Loopback (127.0.0.1)"

    # 3. Whitelist Network Interfaces (The VPN Tunnels)
    # Sing-box TUN
    if (Get-NetAdapter -Name $TunIfSing -ErrorAction SilentlyContinue) {
        New-NetFirewallRule -Group $Group -DisplayName "KS Allow Interface: $TunIfSing" -Direction Outbound -Action Allow -InterfaceAlias $TunIfSing -Profile Any | Out-Null
        Write-Host " [+] Allowed Interface: $TunIfSing"
    } else { Write-Warning "Interface '$TunIfSing' not active. Rule skipped (VPN might disconnect)." }

    # OpenVPN TUN
    if (Get-NetAdapter -Name $OpenVpnIf -ErrorAction SilentlyContinue) {
        New-NetFirewallRule -Group $Group -DisplayName "KS Allow Interface: $OpenVpnIf" -Direction Outbound -Action Allow -InterfaceAlias $OpenVpnIf -Profile Any | Out-Null
        Write-Host " [+] Allowed Interface: $OpenVpnIf"
    } else { Write-Warning "Interface '$OpenVpnIf' not active. Rule skipped." }

    # 4. Whitelist VPN Executable Paths (To allow initial handshake)
    $Apps = @($XrayPath, $SingBoxPath, $OpenVpnPath)
    foreach ($App in $Apps) {
        if (Test-Path $App) {
            New-NetFirewallRule -Group $Group -DisplayName "KS Allow App: $(Split-Path $App -Leaf)" -Direction Outbound -Action Allow -Program $App -Profile Any | Out-Null
            Write-Host " [+] Allowed Program: $App"
        } else {
            Write-Warning "Program not found: $App. Please check the path in Script Settings."
        }
    }

    # 5. Whitelist Essential Services (DHCP, NTP)
    New-NetFirewallRule -Group $Group -DisplayName "KS Allow DHCP" -Direction Outbound -Action Allow -Service Dhcp -Profile Any | Out-Null
    New-NetFirewallRule -Group $Group -DisplayName "KS Allow NTP (Time Sync)" -Direction Outbound -Action Allow -Protocol UDP -RemotePort 123 -Profile Any | Out-Null
    Write-Host " [+] Allowed DHCP & NTP"

    # 6. Whitelist LAN (Optional)
    if ($AllowLAN) {
        # Private ranges: 10.x, 172.16-31.x, 192.168.x
        New-NetFirewallRule -Group $Group -DisplayName "KS Allow LAN" -Direction Outbound -Action Allow -RemoteAddress "10.0.0.0/8","172.16.0.0/12","192.168.0.0/16" -Profile Private,Public | Out-Null
        Write-Host " [+] Allowed LAN Access"
    }

    # 7. THE BIG SWITCH: Set Default Outbound Action to BLOCK
    Set-NetFirewallProfile -Profile Private,Public,Domain -DefaultOutboundAction Block
    Write-Host " [!] FIREWALL DEFAULT OUTBOUND SET TO BLOCK" -ForegroundColor Yellow
    Write-Host "[SUCCESS] Killswitch is ACTIVE. Connect your VPN now." -ForegroundColor Green
}

function Disable-KillSwitch {
    Write-Host "[*] Deactivating Killswitch (Rollback)..." -ForegroundColor Cyan
    
    # 1. Set Default Action back to ALLOW
    Set-NetFirewallProfile -Profile Private,Public,Domain -DefaultOutboundAction Allow
    Write-Host " [+] Firewall Default Outbound restored to ALLOW"
    
    # 2. Remove our Rules
    Remove-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue
    Write-Host " [+] Killswitch rules removed"
    
    Write-Host "[SUCCESS] Internet restored." -ForegroundColor Green
}

# Execution Flow
Ensure-Admin
if ($Rollback) {
    Disable-KillSwitch
} else {
    Create-KillSwitch
}
```

---

## 2. Configuration & Execution

### Step A: Verify Paths
Look at the `# SETTINGS` section of the script. The script automatically tries to find the Desktop of the current user.
*   If your v2rayN folder is **not** on the Desktop, or if the folder name is different than `v2rayN-windows-64`, you must manually edit the `$XrayPath` and `$SingBoxPath` lines in the script.

### Step B: Enable the Killswitch
1.  **Connect to your VPN** (VLESS or OpenVPN) first. This ensures the virtual network adapters are active and detected.
2.  Press `Win + X` and select **Terminal (Admin)** or **PowerShell (Admin)**.
3.  Navigate to the script location (e.g., Desktop):
    ```powershell
    cd "$env:USERPROFILE\Desktop"
    ```
4.  Run the script:
    ```powershell
    .\killswitch.ps1
    ```

### Step C: Disable (Rollback)
To restore normal internet access without VPN:
1.  Open PowerShell as Administrator.
2.  Run the script with the rollback flag:
    ```powershell
    .\killswitch.ps1 -Rollback
    ```

---

## 3. How It Works (Technical Summary)

This script implements a "Zero Trust" outbound policy:

**1. The "Default Block":**
The Firewall is switched to **Block Mode** for all outgoing connections. By default, **no** traffic can leave your computer. This safeguards against IP leaks if the VPN crashes.

**2. The "Allow List":**
*   **Interfaces:** Traffic is allowed only if it is passing through `singbox_tun` (VLESS) or `OpenVPN Data Channel Offload`.
*   **Binaries:** The script explicitly allows `xray.exe` and `openvpn.exe`. This allows the VPN clients themselves to bypass the block so they can establish the handshake with the remote server.
*   **System Services:** DHCP (IP assignment) and NTP (Time sync) are allowed, as encryption protocols (TLS/SSL) fail if the system clock is de-synchronized.

**3. Behavior Logic:**
*   **VPN Active:** Traffic -> Virtual Interface -> Firewall "Allow" -> Internet.
*   **VPN Crash/Off:** Traffic -> Physical Interface (Ethernet/Wi-Fi) -> Firewall "Block" -> **Connection Dropped.** Your real IP is never exposed.