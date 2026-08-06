@echo off
fsutil 8dot3name set 1
fsutil 8dot3name strip /s /f C:\
exit
