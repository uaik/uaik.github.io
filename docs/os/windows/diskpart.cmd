@echo off

wpeutil UpdateBootInfo && reg query "HKLM\System\CurrentControlSet\Control" /v "PEFirmwareType" | find "0x2" > nul

if "%ErrorLevel%" EQU 0 (
  set "bootType=UEFI"
  set "partitionTable=GPT"
)

>> "X:\diskpart.txt" (
  echo SELECT DISK=0
  echo CLEAN
  if "%bootType%" == "UEFI" (
    echo CONVERT GPT
    echo CREATE PARTITION EFI SIZE=512
    echo FORMAT QUICK FS=FAT32 LABEL="SYSTEM"
    echo CREATE PARTITION MSR SIZE=512
    echo CREATE PARTITION PRIMARY SIZE=2048
    echo FORMAT QUICK FS=NTFS LABEL="RECOVERY"
    echo SET ID="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
    echo GPT ATTRIBUTES=0x8000000000000001
  ) else (
    echo CREATE PARTITION PRIMARY SIZE=512
    echo FORMAT QUICK FS=NTFS LABEL="SYSTEM"
    echo ACTIVE
    echo CREATE PARTITION PRIMARY SIZE=2048
    echo FORMAT QUICK FS=NTFS LABEL="RECOVERY"
    echo SET ID=27
    echo CREATE PARTITION PRIMARY SIZE=100
    echo SET ID=17 OVERRIDE
  )
  echo CREATE PARTITION PRIMARY
  echo FORMAT QUICK FS=NTFS LABEL="OS"
)

diskpart /s "X:\diskpart.txt" || ( echo DiskPart encountered an error! & pause & exit /b 1 )

exit
