@echo off
reg add "HKLM\System\Setup\LabConfig" /v "BypassTPMCheck" /t "REG_DWORD" /d "1" /f
reg add "HKLM\System\Setup\LabConfig" /v "BypassSecureBootCheck" /t "REG_DWORD" /d "1" /f
reg add "HKLM\System\Setup\LabConfig" /v "BypassRAMCheck" /t "REG_DWORD" /d "1" /f
exit
