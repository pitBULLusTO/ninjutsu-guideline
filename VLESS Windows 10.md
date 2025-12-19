# How to Connect VLESS VPN Config in Windows 10 (Complete Guide)

This guide covers the installation of the `v2rayN` client, adding a VLESS configuration, enabling TUN mode (transparent proxying for all apps), and verifying your connection.

## Prerequisites
*   **A VLESS configuration string** (starts with `vless://...`).
*   **Windows 10/11** (64-bit).
*   **Administrator rights** on your PC.

---

## Step 1: Download and Install v2rayN

1.  **Download the Client:**
    *   Go to the official GitHub releases page: [v2rayN Releases](https://github.com/2dust/v2rayN/releases).
    *   Download the zip file named `v2rayN-windows-64.zip` (usually the latest version).
    *   *Note: If you don't have the Microsoft .NET Runtime installed, the app will prompt you to download it.*

2.  **Extract the Files:**
    *   Right-click the downloaded zip file and select **Extract All**.
    *   **Important:** Do not place the folder in `C:\Program Files`. Place it on your Desktop or `C:\v2rayN` to avoid permission issues.

3.  **Launch the Application:**
    *   Open the extracted folder.
    *   Find `v2rayN.exe` and run it. The application will open, and an icon (check mark `V` or `N` icon) will appear in your system tray (bottom right corner).

---

## Step 2: Add Your VLESS Configuration

1.  **Copy your Config:**
    *   Highlight your VLESS link (e.g., `vless://uuid@ip:port...`) and copy it (`Ctrl+C`).

2.  **Import to v2rayN:**
    *   Open the `v2rayN` main window.
    *   Click on the **Servers** icon (or access the top menu).
    *   Click the **Paste** icon (or press `Ctrl+V` inside the window).
    *   Alternatively, click **Servers** -> **Import bulk URL from clipboard**.

3.  **Activate the Server:**
    *   You will see your server in the list.
    *   **Right-click** the server line and select **Set as active server** (it will turn blue/highlighted), or simply press `Enter` on it.

---

## Step 3: Configure Core Settings (Crucial for Speed & Stability)

1.  Go to **Settings** -> **Settings**.
2.  Navigate to the **Tun Mode settings** tab.
3.  **Enable TUN Mode:**
    *   This forces all traffic (not just browser traffic) through the VPN.
    *   **Stack:** Select `gvisor` or `system` (gvisor is more stable for bypassing censorship; system is faster).
    *   **Strict Route:** Turn **ON** (prevents DNS leaks).
4.  Navigate to the **Core Type settings** tab.
    *   Ensure **VLESS** is set to `Xray` or `Sing-box` (Xray is recommended for standard users).
5.  Click **Confirm**.

---

## Step 4: Configure Routing (Global vs. Split Connection)

At the bottom of the main window, you will see a dropdown menu labeled **Routing**. This determines how traffic is handled.

*   **Global (Recommended for maximum anonymity):**
    *   Select **Global** (or "Proxy All").
    *   *Effect:* Every single packet of data goes through the VLESS server. If the server fails, the internet stops working. This prevents accidental leaks of your real IP.

*   **Whitelist / Rule-based:**
    *   Select **Whitelist** (or "Bypass LAN/China").
    *   *Effect:* Local traffic (printers, local network) stays direct; everything else goes through the proxy. Useful if you need to access local devices while on VPN.

---

## Step 5: Start the Connection

1.  Look at the bottom of the `v2rayN` window.
2.  **Tun Mode:** Toggle the switch to **ON**.
    *   *Note: This effectively acts as the "Connect" button.*
3.  **Administrator Prompt:** Windows will ask for permission to create a network adapter. Click **Yes**.
4.  The log window at the bottom should show messages like `Inbound: [tun]... started`.

---

## Step 6: Verify the Connection

Open PowerShell (`Win + X` -> Terminal/PowerShell) and run the following commands to verify your traffic is routed correctly.

1.  **Check IP:**
    ```powershell
    curl http://ip-api.com/line
    ```
    *Result:* You should see the IP address of your VLESS server, not your home IP.

2.  **Check Trace (Verify Hops):**
    ```powershell
    tracert -d 8.8.8.8
    ```
    *Result:*
    *   Hop 1 should be your local gateway (e.g., `192.168.1.1`).
    *   Hop 2 (or 3) should *immediately* jump to your VLESS server IP or an internal VPN IP (like `10.x.x.x` or `172.x.x.x`). You should *not* see your ISP's intermediate hops.

---

## Troubleshooting Connectivity & TOR Issues

If you are chaining this with TOR or facing connection drops:

1.  **TOR Won't Connect:**
    *   If using TUN mode, enable **"Strict Route"** in Settings.
    *   Try changing the **Routing** mode at the bottom from *Global* to *Rule-based (Whitelist)* temporarily to let the initial handshake pass, then switch back.
    *   Ensure your system time is synced (`Settings -> Time & Language -> Sync Now`).

2.  **Kill Switch:**
    *   If you used a PowerShell Kill Switch script, remember that **Global Routing** in `v2rayN` is the software-level equivalent. The script is a failsafe.
    *   If connection is blocked entirely, run this command in Administrator PowerShell to reset the firewall rules:
        ```powershell
        Remove-NetFirewallRule -DisplayName "KS *" -ErrorAction SilentlyContinue
        ```

3.  **DNS Leaks:**
    *   In `v2rayN`, ensure **Sniffing** is enabled in Settings -> Core: basic settings.
    *   Check `dnsleaktest.com` in your browser. It should only show the VLESS server location.