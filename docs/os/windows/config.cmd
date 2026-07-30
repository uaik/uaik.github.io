@echo off

sfc /scannow
rem ---
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
reg add "HKU\.DEFAULT\Control Panel\Accessibility\StickyKeys" /v "Flags" /t "REG_SZ" /d "506" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t "REG_DWORD" /d "1" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t "REG_DWORD" /d "1" /f
reg unload "HKU\DefaultUser"
rem ---
netsh advfirewall firewall set rule group="@FirewallAPI.dll,-28752" new enable=Yes
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d "0" /f
rem ---
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t "REG_DWORD" /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t "REG_DWORD" /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Edge" /v "HideFirstRunExperience" /t "REG_DWORD" /d "1" /f
rem ---
if exist "C:\Windows.old" rmdir /s /q "C:\Windows.old"
rem ---
exit
