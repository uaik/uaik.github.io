@echo off

set "dsk=%1"
set "ver=%2"
set "drv=vioscsi viostor"
set "dir=boot install"

for %%i in (%drv%) do (
  for %%d in (%dir%) do (
    if not exist "%~dp0drv\%%d\virtio\%%i" md "%~dp0drv\%%d\virtio\%%i"
    robocopy "%dsk%:\%%i\%ver%\amd64" "%~dp0drv\%%d\virtio\%%i" /mir
  )
)

exit /b 0
