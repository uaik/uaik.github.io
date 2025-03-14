@echo off

set "idx=%*"
set "cap=%~dp0cap"
set "drv=%~dp0drv"
set "mnt=%~dp0mnt"
set "pkg=%~dp0pkg"
set "upd=%~dp0upd"
set "wim=%~dp0wim"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # CREATE STRUCTURE
rem # ---------------------------------------------------------------------------------------------------------------- #

if "%1" == "struct" (
  for %%i in ("%drv%" "%mnt%" "%pkg%" "%wim%") do (
    if not exist "%%i" md "%%i"
  )

  echo The directory structure has been created!
  exit /b 0
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # BOOT.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

for %%i in (2) do (
  if exist "%wim%\boot.wim" (
    echo: && echo Mounting a Windows image...
    Dism /Mount-Image /ImageFile:"%wim%\boot.wim" /Index:%%i /MountDir:"%mnt%"

    if exist "%drv%" (
      echo: && echo Integrating Windows Drivers...
      Dism /Image:"%mnt%" /Add-Driver /Driver:"%drv%" /Recurse
    )

    echo: && echo Saving Windows image...
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit
  ) else (
    echo boot.wim not found!
    exit /b 1
  )
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # INSTALL.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

for %%i in (%idx%) do (
  if exist "%wim%\install.wim" (
    echo: && echo Mounting a Windows image...
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%"

    if exist "%drv%" (
      echo: && echo Integrating Windows Drivers...
      Dism /Image:"%mnt%" /Add-Driver /Driver:"%drv%" /Recurse
    )

    if exist "%pkg%" (
      if exist "%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab" (
        echo: && echo Integrating Windows Client Language Packs...
        Dism /Image:"%mnt%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab"
      )
      if exist "%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab" (
        echo: && echo Integrating Windows Server Language Packs...
        Dism /Image:"%mnt%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab"
      )
    )

    if exist "%cap%" (
      echo: && echo Integrating Windows capabilities...
      Dism /Image:"%mnt%" /Add-Capability /CapabilityName:Language.Basic~~~ru-ru~0.0.1.0 /CapabilityName:Language.Handwriting~~~ru-ru~0.0.1.0 /CapabilityName:Language.OCR~~~ru-ru~0.0.1.0 /CapabilityName:Language.Speech~~~ru-ru~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~ru-ru~0.0.1.0 /Source:"%cap%"
    )

    if exist "%upd%" (
      echo: && echo Integrating Windows Updates...
      Dism /Image:"%mnt%" /Add-Package /PackagePath:"%upd%"
    )

    echo: && echo Saving Windows image...
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit
  ) else (
    echo install.wim not found!
    exit /b 1
  )
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # EXIT
rem # ---------------------------------------------------------------------------------------------------------------- #

exit /b 0
