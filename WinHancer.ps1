# Get Admin Privilages
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
	Exit
}

# Set Theme Based on AppsUseLightTheme Prefrence
$theme = @("#ffffff","#202020","#323232")
if (Get-ItemPropertyValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme"){
    $theme = @("#292929","#f3f3f3","#fbfbfb")
}

# GUI Specs
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
$tooltip = New-Object System.Windows.Forms.ToolTip
[System.Windows.Forms.Application]::EnableVisualStyles()
$form = New-Object System.Windows.Forms.Form
$form.Text = "WinHancer - The Windows Enhancer"
$form.StartPosition = "CenterScreen"
$form.ClientSize = New-Object System.Drawing.Point(530,600)
$form.ForeColor = $theme[0]
$form.BackColor = $theme[1]

# Categories
$label = New-Object System.Windows.Forms.Label
$label.Text = "Debloat"
$label.Size = New-Object System.Drawing.Size(150,30)
$label.Location = New-Object System.Drawing.Size(218,10)
$label.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',18)
$form.Controls.Add($label)

$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Applications"
$label2.Size = New-Object System.Drawing.Size(150,30)
$label2.Location = New-Object System.Drawing.Size(198,150)
$label2.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',18)
$form.Controls.Add($label2)

$label = New-Object System.Windows.Forms.Label
$label.Text = "Utilities"
$label.Size = New-Object System.Drawing.Size(150,30)
$label.Location = New-Object System.Drawing.Size(225,290)
$label.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',18)
$form.Controls.Add($label)

# Buttons - Debloat
$debloat = New-Object System.Windows.Forms.Button
$debloat.Text = "Debloat"
$debloat.Size = New-Object System.Drawing.Size(140,38)
$debloat.Location = New-Object System.Drawing.Size(15,70)
$debloat.FlatStyle = "0"
$debloat.FlatAppearance.BorderSize = "0"
$debloat.BackColor = $theme[2]
$tooltip.SetToolTip($debloat, "Disables:`n- Taskbar icons`n- Web search in start`n- Animations & transparency`nEnables:`n- File extensions`n- Verbose startup")
$form.Controls.Add($debloat)

$undo = New-Object System.Windows.Forms.Button
$undo.Text = "Undo"
$undo.Size = New-Object System.Drawing.Size(140,38)
$undo.Location = New-Object System.Drawing.Size(195,70)
$undo.FlatStyle = "0"
$undo.FlatAppearance.BorderSize = "0"
$undo.BackColor = $theme[2]
$tooltip.SetToolTip($undo, "Enables:`n- Taskbar icons`n- Web search in start`n- Animations & transparency`nDisables:`n- File extensions`n- Verbose startup")
$form.Controls.Add($undo)

$wip = New-Object System.Windows.Forms.Button
$wip.Text = "W.I.P"
$wip.Size = New-Object System.Drawing.Size(140,38)
$wip.Location = New-Object System.Drawing.Size(375,70)
$wip.FlatStyle = "0"
$wip.FlatAppearance.BorderSize = "0"
$wip.BackColor = $theme[2]
$tooltip.SetToolTip($wip, "Disable all Amazon apps")
$form.Controls.Add($wip)

# Multi-Buttons
$debloattool = $debloat, $undo

$debloattool.Add_Click{
    if ($this.Text -eq "Debloat"){
        # Enable File Extensions
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" -Name "HideFileExt" -Force -Type DWORD -Value 0 | Out-Host
        # Disable Telemetry (Data Collection, Advertising ID, Wi-Fi Sense)
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Force -Type DWORD -Value 0 | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Force -Type DWORD -Value 0 | Out-Host
        Get-NetFirewallRule | Where { $_.Group -eq 'DiagTrack' } | Remove-NetFirewallRule | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Force -Type DWORD -Value 0 | Out-Host
        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Force | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Force -Type DWORD -Value 1 | Out-Host
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Force -Type DWORD -Value 0 | Out-Host
        # Disable Windows Update Sharing
        Get-NetFirewallRule | Where { $_.DisplayGroup -eq 'Delivery Optimization' } | Remove-NetFirewallRule | Out-Host
        # Cleanup Taskbar
        $icons = @("TaskbarMn","TaskbarDa","ShowTaskViewButton","TaskbarAl")
        foreach ($icon in $icons){
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" -Name "$icon" -Force -Type DWORD -Value 0 | Out-Host
        }
        New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\" -Name "Explorer" -Force | Out-Host
        New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer\" -Name "DisableSearchBoxSuggestions" -Force -Type DWORD -Value 1 | Out-Host
        # Enable Verbose Shutdown
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "VerboseStatus" -Force -Type DWORD -Value 1 | Out-Host
    } else {
        # Enable File Extensions
        New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" -Name "HideFileExt" -Force -Type DWORD -Value 1 | Out-Host
        # Enable Telemetry (Data Collection, Advertising ID, Wi-Fi Sense)
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Force -Type DWORD -Value 1 | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Force -Type DWORD -Value 1 | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Force -Type DWORD -Value 1 | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Force -Type DWORD -Value 0 | Out-Host
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "value" -Force -Type DWORD -Value 1 | Out-Host
        # Rebloat Taskbar
        $icons = @("TaskbarMn","TaskbarDa","ShowTaskViewButton","TaskbarAl")
        foreach ($icon in $icons){
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\" -Name "$icon" -Force -Type DWORD -Value 1 | Out-Host
        }
        New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer\" -Name "DisableSearchBoxSuggestions" -Force -Type DWORD -Value 0 | Out-Host
        # Disable Verbose Shutdown
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "VerboseStatus" -Force -Type DWORD -Value 0 | Out-Host
    }
    [System.Windows.MessageBox]::Show("$($this.Text) Complete! It is highly recommended to reboot.","Notice","OK")
}

$form.ShowDialog()