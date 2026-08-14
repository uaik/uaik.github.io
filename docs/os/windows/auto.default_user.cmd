@echo off
reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t "REG_DWORD" /d "1" /f
reg unload "HKU\DefaultUser" && exit
