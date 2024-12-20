@echo off

set "idx=%*"
set "drv=%~dp0drv"
set "mnt=%~dp0mnt"
set "pkg=%~dp0pkg"
set "wim=%~dp0wim"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # CREATE STRUCTURE
rem # ---------------------------------------------------------------------------------------------------------------- #

if "%1" == "struct" (
  if not exist "%drv%" md "%drv%"
  if not exist "%mnt%" md "%mnt%"
  if not exist "%pkg%" md "%pkg%"
  if not exist "%wim%" md "%wim%"
  exit
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # BOOT.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

for %%i in (2) do (
  if exist "%wim%\boot.wim" (
    echo Mounting a Windows image...
    Dism /Mount-Image /ImageFile:"%wim%\boot.wim" /Index:%%i /MountDir:"%mnt%"
  ) else (
    exit /b 1
  )

  if exist "%drv%" (
    echo Integrating Windows Drivers...
    Dism /Image:"%mnt%" /Add-Driver /Driver:"%drv%" /Recurse
  )

  echo Saving Windows image...
  Dism /Unmount-Image /MountDir:"%mnt%" /Commit && timeout /t 5 /nobreak > nul
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # INSTALL.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

for %%i in (%idx%) do (
  if exist "%wim%\install.wim" (
    echo Mounting a Windows image...
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%"
  ) else (
    exit /b 1
  )

  if exist "%drv%" (
    echo Integrating Windows Drivers...
    Dism /Image:"%mnt%" /Add-Driver /Driver:"%drv%" /Recurse
  )

  if exist "%pkg%" (
    if exist "%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab" (
      echo Integrating Windows Client Language Packs...
      Dism /Image:"%mnt%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab"
      echo Integration of additional Windows language packs...
      Dism /Image:"%mnt%" /Add-Capability /CapabilityName:Language.Basic~~~ru-ru~0.0.1.0 /CapabilityName:Language.Handwriting~~~ru-ru~0.0.1.0 /CapabilityName:Language.OCR~~~ru-ru~0.0.1.0 /CapabilityName:Language.Speech~~~ru-ru~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~ru-ru~0.0.1.0 /Source:"%pkg%"
    )
    if exist "%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab" (
      echo Integrating Windows Server Language Packs...
      Dism /Image:"%mnt%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab"
      echo Integration of additional Windows language packs...
      Dism /Image:"%mnt%" /Add-Capability /CapabilityName:Language.Basic~~~ru-ru~0.0.1.0 /CapabilityName:Language.Handwriting~~~ru-ru~0.0.1.0 /CapabilityName:Language.OCR~~~ru-ru~0.0.1.0 /CapabilityName:Language.Speech~~~ru-ru~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~ru-ru~0.0.1.0 /Source:"%pkg%"
    )
  )

  echo Saving Windows image...
  Dism /Unmount-Image /MountDir:"%mnt%" /Commit && timeout /t 5 /nobreak > nul
)

exit
