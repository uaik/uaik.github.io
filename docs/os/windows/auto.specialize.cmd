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
:: Disable Edge Copilot.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t "REG_DWORD" /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "CopilotCDPPageContext" /t "REG_DWORD" /d "0" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable app suggestions.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable copilot.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable recall.
:: Disable AI data analysis.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis" /t "REG_DWORD" /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsAI" /v "AllowRecallEnablement" /t "REG_DWORD" /d "0" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Telemetry to minimum.
:: Disable feedback notifications.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t "REG_DWORD" /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable cloud content.
:: Disable consumer experiences.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t "REG_DWORD" /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableSoftLanding" /t "REG_DWORD" /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableCloudOptimizedContent" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Tools.
:: ---------------------------------------------------------------------------------------------------------------------

sfc /scannow
if exist "C:\Windows.old" rmdir /s /q "C:\Windows.old"

:: ---------------------------------------------------------------------------------------------------------------------
:: Exit.
:: ---------------------------------------------------------------------------------------------------------------------

exit
