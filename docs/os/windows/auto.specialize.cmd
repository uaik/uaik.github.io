@echo off

:: ---------------------------------------------------------------------------------------------------------------------
:: Enable Remote Desktop services (RDP).
:: ---------------------------------------------------------------------------------------------------------------------

netsh advfirewall firewall set rule group="@FirewallAPI.dll,-28752" new enable=Yes
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d "0" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Prevent download and installation of applications associated with certain hardware devices.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable widgets.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t "REG_DWORD" /d "0" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Hide Edge First Run Experience.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable app suggestions.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable SmartScreen in Windows and Edge.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t "REG_SZ" /d "Off" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WTDS\Components" /v "ServiceEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WTDS\Components" /v "NotifyMalicious" /t "REG_DWORD" /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WTDS\Components" /v "NotifyPasswordReuse" /t "REG_DWORD" /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WTDS\Components" /v "NotifyUnsafeApp" /t "REG_DWORD" /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows Defender Security Center\Systray" /v "HideSystray" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Tools.
:: ---------------------------------------------------------------------------------------------------------------------

sfc /scannow
if exist "C:\Windows.old" rmdir /s /q "C:\Windows.old"

:: ---------------------------------------------------------------------------------------------------------------------
:: Exit.
:: ---------------------------------------------------------------------------------------------------------------------

exit
