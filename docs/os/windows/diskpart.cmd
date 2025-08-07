@echo off

wpeutil UpdateBootInfo && reg query "HKLM\System\CurrentControlSet\Control" /v "PEFirmwareType" | find "0x2" > nul

if "%ErrorLevel%" EQU 0 (
  set "bootType=UEFI"
  set "partitionTable=GPT"
)

>> "X:\diskpart.txt" (
  echo select disk=0
  echo clean
  if "%bootType%" == "UEFI" (
    echo convert gpt
    echo create partition efi size=512
    echo format quick fs=fat32 label="SYSTEM"
    echo create partition msr size=128
    echo create partition primary size=1024
    echo format quick fs=ntfs label="RECOVERY"
    echo set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac"
    echo gpt attributes=0x8000000000000001
  ) else (
    echo create partition primary size=512
    echo format quick fs=ntfs label="SYSTEM"
    echo active
    echo create partition primary size=128
    echo set id=17
    echo create partition primary size=1024
    echo format quick fs=ntfs label="RECOVERY"
    echo set id=27
  )
  echo create partition primary
  echo format quick fs=ntfs label="OS"
)

diskpart /s "X:\diskpart.txt" || ( echo DiskPart encountered an error! & pause & exit /b 1 )

exit
