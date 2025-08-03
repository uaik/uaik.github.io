@echo off
wpeutil UpdateBootInfo
reg query "HKLM\System\CurrentControlSet\Control" /v "PEFirmwareType" | find "0x2" > nul
if "%ErrorLevel%" EQU 0 (
  set "bootType=UEFI"
  set "partitionTable=GPT"
)
echo SELECT DISK=0 >> "X:\diskpart.txt"
echo CLEAN >> "X:\diskpart.txt"
if "%bootType%" == "UEFI" (
  echo CONVERT GPT >> "X:\diskpart.txt"
  echo CREATE PARTITION EFI SIZE=512 >> "X:\diskpart.txt"
  echo FORMAT QUICK FS=FAT32 LABEL="EFI" >> "X:\diskpart.txt"
  echo CREATE PARTITION MSR SIZE=512 >> "X:\diskpart.txt"
  echo CREATE PARTITION PRIMARY SIZE=2048 >> "X:\diskpart.txt"
  echo FORMAT QUICK FS=NTFS LABEL="WINRE" >> "X:\diskpart.txt"
  echo SET ID="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >> "X:\diskpart.txt"
  echo GPT ATTRIBUTES=0x8000000000000001 >> "X:\diskpart.txt"
) else (
  echo CREATE PARTITION PRIMARY SIZE=512 >> "X:\diskpart.txt"
  echo FORMAT QUICK FS=NTFS LABEL="SYSTEM RESERVED" >> "X:\diskpart.txt"
  echo ACTIVE >> "X:\diskpart.txt"
  echo CREATE PARTITION PRIMARY SIZE=2048 >> "X:\diskpart.txt"
  echo FORMAT QUICK FS=NTFS LABEL="WINRE" >> "X:\diskpart.txt"
  echo SET ID=27 >> "X:\diskpart.txt"
  echo CREATE PARTITION PRIMARY SIZE=100 >> "X:\diskpart.txt"
  echo SET ID=17 OVERRIDE >> "X:\diskpart.txt"
)
echo CREATE PARTITION PRIMARY >> "X:\diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="OS" >> "X:\diskpart.txt"
diskpart /s "X:\diskpart.txt" >> "X:\diskpart.log" || ( type "X:\diskpart.log" & echo DiskPart encountered an error! & pause & exit /b 1 )
exit
