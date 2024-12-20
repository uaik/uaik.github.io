@echo off
echo SELECT DISK=0 >> "X:\diskpart.txt"
echo CLEAN >> "X:\diskpart.txt"
echo CREATE PARTITION PRIMARY SIZE=512 >> "X:\diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="SYSTEM RESERVED" >> "X:\diskpart.txt"
echo ACTIVE >> "X:\diskpart.txt"
echo CREATE PARTITION PRIMARY SIZE=2048 >> "X:\diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="WINRE" >> "X:\diskpart.txt"
echo SET ID=27 >> "X:\diskpart.txt"
echo CREATE PARTITION PRIMARY >> "X:\diskpart.txt"
echo FORMAT QUICK FS=NTFS LABEL="OS" >> "X:\diskpart.txt"
diskpart /s "X:\diskpart.txt" >> "X:\diskpart.log"
exit
