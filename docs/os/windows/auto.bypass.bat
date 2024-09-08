rem # BYPASSING SYSTEM REQUIREMENTS CHECKS
rem #
rem # @package   CMD
rem # @author    Kai Kimera <mail@kai.kim>
rem # @copyright 2024 Library Online
rem # @license   MIT
rem # @version   0.1.0
rem # @link      https://lib.onl
rem # ---------------------------------------------------------------------------------------------------------------- #

@echo off

reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t "REG_DWORD" /d 1 /f
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t "REG_DWORD" /d 1 /f
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t "REG_DWORD" /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t "REG_DWORD" /d 1 /f

exit
