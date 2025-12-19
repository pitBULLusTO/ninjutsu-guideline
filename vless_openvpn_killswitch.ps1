<#
vless_openvpn_killswitch.ps1
Killswitch for VLESS (sing-box / xray) and OpenVPN.
Run as Administrator.
Usage:
  .\vless_openvpn_killswitch.ps1           # Apply killswitch
  .\vless_openvpn_killswitch.ps1 -Rollback # Remove killswitch and restore defaults
#>

param(
    [switch]$Rollback
)

# -----------------------
#  SETTINGS (adjust to your system)
# -----------------------
$Group        = "VLESS And OpenVPN KillSwitch"                    
$TunIfSing    = "singbox_tun"                          
$OpenVpnIf    = "OpenVPN Data Channel Offload"         
$XrayPath     = "C:\Program Files\v2rayN-windows-64\bin\xray\xray.exe"   
$SingBoxPath  = "C:\Program Files\v2rayN-windows-64\bin\sing_box\sing-box.exe"  
$OpenVpnExe   = "C:\Program Files\OpenVPN\bin\openvpn.exe"  
$AllowLanOnPrivate = $true                              
# -----------------------

$global:SavedProfiles = @{}

function Ensure-Admin {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    if (-not $isAdmin) {
        Write-Error "This script must be run as Administrator. Please restart PowerShell with elevated privileges."
        exit 1
    }
}

function Save-ProfileDefaults {
    foreach ($p in @("Private","Public")) {
        $prof = Get-NetFirewallProfile -Profile $p
        $global:SavedProfiles[$p] = $prof.DefaultOutboundAction
    }
}

function Restore-ProfileDefaults {
    foreach ($p in @("Private","Public")) {
        if ($global:SavedProfiles.ContainsKey($p)) {
            try {
                Set-NetFirewallProfile -Profile $p -DefaultOutboundAction $global:SavedProfiles[$p] -ErrorAction Stop
                Write-Host "Restored DefaultOutboundAction for profile ${p}: $($global:SavedProfiles[$p])"
            }
            catch {
                Write-Warning "Failed to restore profile ${p}"
            }
        }
    }
}

function Remove-OldRules {
    $existing = Get-NetFirewallRule -Group $Group -ErrorAction SilentlyContinue
    if ($existing) {
        $existing | Remove-NetFirewallRule -ErrorAction SilentlyContinue
        Write-Host "Removed old rules from group '$Group'."
    }
}

function Add-Rule-Loopback {
    New-NetFirewallRule -Group $Group -DisplayName "KS Allow Loopback v4" -Direction Outbound -Action Allow -RemoteAddress 127.0.0.0/8 -Profile Private,Public -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Added rule: Loopback v4"
}

function Add-Rule-InterfaceIfPresent {
    param([string]$ifName, [string]$displayName)
    
    $adapter = Get-NetAdapter -Name $ifName -ErrorAction SilentlyContinue
    if ($adapter) {
        New-NetFirewallRule -Group $Group -DisplayName $displayName -Direction Outbound -Action Allow -InterfaceAlias $ifName -Profile Private,Public -ErrorAction Stop | Out-Null
        Write-Host "Added rule: $displayName (Interface: $ifName)"
        return $true
    }
    else {
        Write-Warning "Interface '$ifName' not found. Rule not created. Start the tunnel and re-run the script."
        return $false
    }
}

function Add-Rule-ProgramIfExists {
    param([string]$programPath, [string]$displayName)
    
    if ([string]::IsNullOrWhiteSpace($programPath)) {
        return $false
    }
    if (Test-Path $programPath) {
        New-NetFirewallRule -Group $Group -DisplayName $displayName -Program $programPath -Direction Outbound -Action Allow -Profile Private,Public -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Added rule: $displayName (Program: $programPath)"
        return $true
    }
    else {
        Write-Warning "File not found: $programPath"
        return $false
    }
}

function Try-AutoDetect-ProcessPath {
    param([string[]]$processNames)
    
    foreach ($pname in $processNames) {
        $proc = Get-Process -Name $pname -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($proc -and $proc.Path) {
            return $proc.Path
        }
    }
    return $null
}

function Add-Service-Rules {
    # xray
    $xrayAdded = Add-Rule-ProgramIfExists -programPath $XrayPath -displayName "KS Allow xray.exe"
    if (-not $xrayAdded) {
        $autoXray = Try-AutoDetect-ProcessPath -processNames @("xray","v2ray","v2rayN")
        if ($autoXray) {
            Add-Rule-ProgramIfExists -programPath $autoXray -displayName "KS Allow xray (autodetect)"
        }
    }

    # sing-box
    if (-not [string]::IsNullOrWhiteSpace($SingBoxPath)) {
        Add-Rule-ProgramIfExists -programPath $SingBoxPath -displayName "KS Allow sing-box.exe"
    }
    else {
        $autoSB = Try-AutoDetect-ProcessPath -processNames @("sing-box","singbox")
        if ($autoSB) {
            Add-Rule-ProgramIfExists -programPath $autoSB -displayName "KS Allow sing-box (autodetect)"
        }
    }

    # OpenVPN
    if (-not [string]::IsNullOrWhiteSpace($OpenVpnExe)) {
        Add-Rule-ProgramIfExists -programPath $OpenVpnExe -displayName "KS Allow openvpn.exe"
    }
    else {
        $autoOV = Try-AutoDetect-ProcessPath -processNames @("openvpn","openvpn-gui")
        if ($autoOV) {
            Add-Rule-ProgramIfExists -programPath $autoOV -displayName "KS Allow openvpn (autodetect)"
        }
    }
}

function Add-DNS-Block {
    New-NetFirewallRule -Group $Group -DisplayName "KS Block DNS UDP 53" -Direction Outbound -Protocol UDP -RemotePort 53 -Action Block -Profile Private,Public -ErrorAction SilentlyContinue | Out-Null
    New-NetFirewallRule -Group $Group -DisplayName "KS Block DoT TCP 853" -Direction Outbound -Protocol TCP -RemotePort 853 -Action Block -Profile Private,Public -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Added DNS leak protection rules (Block UDP 53, TCP 853)."
}

function Add-Service-Allowances {
    # DHCP
    New-NetFirewallRule -Group $Group -DisplayName "KS Allow DHCP" -Service Dhcp -Direction Outbound -Action Allow -Profile Private,Public -ErrorAction SilentlyContinue | Out-Null
    # NTP
    New-NetFirewallRule -Group $Group -DisplayName "KS Allow NTP" -Program "$Env:SystemRoot\System32\svchost.exe" -Service W32Time -Protocol UDP -RemotePort 123 -Direction Outbound -Action Allow -Profile Private,Public -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Added service rules: DHCP, NTP."
}

function Add-LAN-Allow {
    if ($AllowLanOnPrivate) {
        New-NetFirewallRule -Group $Group -DisplayName "KS Allow LAN (Private)" -Direction Outbound -Action Allow -RemoteAddress "10.0.0.0/8","172.16.0.0/12","192.168.0.0/16" -Profile Private -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Added rule: Allow LAN access on Private profile."
    }
}

function Create-KillSwitch {
    Ensure-Admin
    Save-ProfileDefaults
    Remove-OldRules

    # Set strict outbound policy
    try {
        Set-NetFirewallProfile -Profile Private,Public -DefaultOutboundAction Block -ErrorAction Stop
        Write-Host "DefaultOutboundAction set to Block for Private and Public profiles."
    }
    catch {
        Write-Error "Failed to set DefaultOutboundAction to Block."
        return
    }

    Add-Rule-Loopback

    # Interface-based rules (if interfaces exist)
    Add-Rule-InterfaceIfPresent -ifName $TunIfSing -displayName "KS Allow via TUN (singbox_tun)"
    Add-Rule-InterfaceIfPresent -ifName $OpenVpnIf -displayName "KS Allow via OpenVPN DCO"

    # Program-based rules
    Add-Service-Rules

    Add-DNS-Block
    Add-Service-Allowances
    Add-LAN-Allow

    Write-Host ""
    Write-Host "=== SUMMARY: Rules in group '$Group' ==="
    Get-NetFirewallRule -Group $Group | Select-Object DisplayName, Enabled, Direction, Action | Format-Table -AutoSize
    Write-Host ""
    Write-Host "Killswitch activated."
    Write-Host "To rollback: .\vless_openvpn_killswitch.ps1 -Rollback"
}

function Do-Rollback {
    Ensure-Admin
    
    # First restore profile defaults
    foreach ($p in @("Private","Public")) {
        try {
            Set-NetFirewallProfile -Profile $p -DefaultOutboundAction Allow -ErrorAction Stop
            Write-Host "Restored DefaultOutboundAction to Allow for profile: $p"
        }
        catch {
            Write-Warning "Failed to restore profile: $p"
        }
    }
    
    Remove-OldRules
    Write-Host "Rollback complete. Killswitch disabled."
}

# -----------------------
#  MAIN
# -----------------------
if ($Rollback) {
    Do-Rollback
}
else {
    Create-KillSwitch
}