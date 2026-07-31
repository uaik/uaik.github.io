@echo off
fsutil 8dot3name set X: 1
fsutil 8dot3name strip /s /f X:\
reg load "HKLM\mount" "X:\Windows\System32\config\SYSTEM"
reg add "HKLM\mount\ControlSet001\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /t "REG_DWORD" /d "1" /f
reg unload "HKLM\mount"
exit
