@echo off

set "dsk=%1"
set "ver=%2"
set "drv=Balloon fwcfg NetKVM pvpanic sriov viofs viogpudo vioinput viomem viorng vioscsi vioserial viosock viostor"

for %%i in (%drv%) do (
  if not exist "%~dp0drv\virtio\%%i" md "%~dp0drv\virtio\%%i"
  robocopy "%dsk%:\%%i\%ver%\amd64" "%~dp0drv\virtio\%%i" /e /is /it /im
)

exit /b 0
