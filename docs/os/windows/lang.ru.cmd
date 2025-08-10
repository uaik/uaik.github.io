@echo off

bcdedit /set {current} locale ru-RU & bcdboot %WinDir% /l ru-RU
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\MUI\UILanguages\en-US" /f

exit
