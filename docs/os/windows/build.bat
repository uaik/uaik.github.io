@echo off

set index=2 4
set "drv=%~dp0drv"
set "mnt=%~dp0mnt"
set "wim=%~dp0wim"
set "pkg=%~dp0pkg"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # boot.wim
rem # ---------------------------------------------------------------------------------------------------------------- #

if exist "%wim%\boot.wim" (
  Dism /Mount-Image /ImageFile:"%wim%\boot.wim" /Index:2 /MountDir:"%mnt%"
) else (
  exit /b 1
)

if exist "%drv%" (
  Dism /Image:"%mnt%" /Add-Driver /Driver:"%drv%" /Recurse
)

Dism /Unmount-Image /MountDir:"%mnt%" /Commit

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # install.wim
rem # ---------------------------------------------------------------------------------------------------------------- #

for %%i in (%index%) do (
  if exist "%wim%\install.wim" (
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%"
  ) else (
    exit /b 1
  )

  if exist "%drv%" (
    Dism /Image:"%mnt%" /Add-Driver /Driver:"%drv%" /Recurse
  )

  if exist "%pkg%" (
    if exist "%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab" (
      Dism /Image:"%mnt%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab"
      Dism /Image:"%mnt%" /Add-Capability /CapabilityName:Language.Basic~~~ru-ru~0.0.1.0 /CapabilityName:Language.Handwriting~~~ru-ru~0.0.1.0 /CapabilityName:Language.OCR~~~ru-ru~0.0.1.0 /CapabilityName:Language.Speech~~~ru-ru~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~ru-ru~0.0.1.0 /Source:"%pkg%"
    )
    if exist "%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab" (
      Dism /Image:"%mnt%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab"
      Dism /Image:"%mnt%" /Add-Capability /CapabilityName:Language.Basic~~~ru-ru~0.0.1.0 /CapabilityName:Language.Handwriting~~~ru-ru~0.0.1.0 /CapabilityName:Language.OCR~~~ru-ru~0.0.1.0 /CapabilityName:Language.Speech~~~ru-ru~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~ru-ru~0.0.1.0 /Source:"%pkg%"
    )
  )

  Dism /Unmount-Image /MountDir:"%mnt%" /Commit
)

exit
