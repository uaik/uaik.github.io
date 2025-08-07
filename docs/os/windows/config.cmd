@echo off
if "%1" == "11" (
  reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t "REG_DWORD" /d 1 /f
  reg add "HKLM\System\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t "REG_DWORD" /d 1 /f
)
sfc /scannow
rem ---
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d 0 /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t "REG_DWORD" /d 1 /f
reg add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t "REG_DWORD" /d 1 /f
reg unload "HKU\DefaultUser"
rem ---
netsh advfirewall firewall set rule group="@FirewallAPI.dll,-28752" new enable=Yes
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d 0 /f
rem ---
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t "REG_DWORD" /d 1 /f
rem ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t "REG_DWORD" /d 1 /f
rem ---
if exist "C:\Windows.old" rmdir /s /q "C:\Windows.old"
exit
