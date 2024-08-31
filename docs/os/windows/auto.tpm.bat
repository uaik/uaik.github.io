rem # BYPASSING SYSTEM REQUIREMENTS CHECKS (WINDOWS 11)
rem # ---------------------------------------------------------------------------------------------------------------- #

reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t "REG_DWORD" /d "1" /f
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t "REG_DWORD" /d "1" /f
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t "REG_DWORD" /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t "REG_DWORD" /d "1" /f
