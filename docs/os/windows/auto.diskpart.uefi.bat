@echo off
rem # DISK PARTITIONS (UEFI)
rem # ---------------------------------------------------------------------------------------------------------------- #

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # CLEAN / CONVERT
rem # ---------------------------------------------------------------------------------------------------------------- #

echo SELECT DISK=0 >> "X:\auto.diskpart.txt"
echo CLEAN >> "X:\auto.diskpart.txt"
echo CONVERT GPT >> "X:\auto.diskpart.txt"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # SYSTEM
rem # ---------------------------------------------------------------------------------------------------------------- #

echo CREATE PARTITION EFI SIZE=512 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=FAT32 LABEL="EFI" >> "X:\auto.diskpart.txt"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # MSR
rem # ---------------------------------------------------------------------------------------------------------------- #

echo CREATE PARTITION MSR SIZE=512 >> "X:\auto.diskpart.txt"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # WINDOWS RE
rem # ---------------------------------------------------------------------------------------------------------------- #

echo CREATE PARTITION PRIMARY SIZE=4096 >> "X:\auto.diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="WINRE" >> "X:\auto.diskpart.txt"
echo SET ID="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >> "X:\auto.diskpart.txt"
echo GPT ATTRIBUTES=0x8000000000000001 >> "X:\auto.diskpart.txt"

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