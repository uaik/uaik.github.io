@echo off
rem # DISK PARTITIONS (BIOS)
rem #
rem # @package   CMD
rem # @author    Kai Kimera <mail@kai.kim>
rem # @copyright 2024 Library Online
rem # @license   MIT
rem # @version   0.1.0
rem # @link      https://lib.onl
rem # ---------------------------------------------------------------------------------------------------------------- #

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # CLEAN
rem # ---------------------------------------------------------------------------------------------------------------- #

echo SELECT DISK=0 >> "X:\auto.diskpart.txt"
echo CLEAN >> "X:\auto.diskpart.txt"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # SYSTEM RESERVED
rem # ---------------------------------------------------------------------------------------------------------------- #

echo CREATE PARTITION PRIMARY SIZE=512 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="SYSTEM RESERVED" >> "X:\auto.diskpart.txt"
echo ACTIVE >> "X:\auto.diskpart.txt"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # WINDOWS RE
rem # ---------------------------------------------------------------------------------------------------------------- #

echo CREATE PARTITION PRIMARY SIZE=4096 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="WINRE" >> "X:\auto.diskpart.txt"
echo SET ID=27 >> "X:\auto.diskpart.txt"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # OS
rem # ---------------------------------------------------------------------------------------------------------------- #

echo CREATE PARTITION PRIMARY >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="OS" >> "X:\auto.diskpart.txt"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # DISKPART
rem # ---------------------------------------------------------------------------------------------------------------- #

diskpart /s "X:\auto.diskpart.txt" >> "X:\auto.diskpart.log"

exit
