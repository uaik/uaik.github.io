@echo off

set "dsk=%1"
set "ver=%2"
set "drv=vioscsi viostor"

for %%i in (%drv%) do (
  if not exist "%~dp0drv\boot\virtio\%%i" md "%~dp0drv\boot\virtio\%%i"
  robocopy "%dsk%:\%%i\%ver%\amd64" "%~dp0drv\boot\virtio\%%i" /e /is /it /im
  if not exist "%~dp0drv\install\virtio\%%i" md "%~dp0drv\install\virtio\%%i"
  robocopy "%dsk%:\%%i\%ver%\amd64" "%~dp0drv\install\virtio\%%i" /e /is /it /im
)

exit /b 0
