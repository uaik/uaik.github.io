@echo off

set "dsk=%1"
set "ver=%2"
set "drv=fwcfg pvpanic vioinput viomem viorng vioscsi vioserial viostor"

for %%i in (%drv%) do (
  if not exist "%~dp0drv\virtio\%%i" md "%~dp0drv\virtio\%%i"
  robocopy "%dsk%:\%%i\%ver%\amd64" "%~dp0drv\virtio\%%i" /e /is /it /im
)

exit /b 0
