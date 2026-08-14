@echo off
netsh advfirewall firewall set rule group="@FirewallAPI.dll,-28752" new enable=Yes
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d "0" /f
sfc /scannow
if exist "C:\Windows.old" rmdir /s /q "C:\Windows.old"
exit
