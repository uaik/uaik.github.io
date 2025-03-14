@echo off

rem # set "idx=%*"
set "cap=%~dp0cap"
set "drv=%~dp0drv"
set "mnt=%~dp0mnt"
set "pkg=%~dp0pkg"
set "tmp=%~dp0tmp"
set "upd=%~dp0upd"
set "wim=%~dp0wim"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # STRUCTURE
rem # ---------------------------------------------------------------------------------------------------------------- #

if "%1" == "struct" (
  for %%i in ("%drv%" "%mnt%" "%pkg%" "%tmp%" "%wim%") do (
    if not exist "%%i" md "%%i"
  )

  echo The directory structure has been created!
  exit /b 0
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # BOOT.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

if exist "%wim%\boot.wim" (
  for %%i in (2) do (
    echo: && echo Mounting a Windows image...
    Dism /Mount-Image /ImageFile:"%wim%\boot.wim" /Index:%%i /MountDir:"%mnt%"

    if exist "%drv%" (
      echo: && echo Integrating Windows Drivers...
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Driver /Driver:"%drv%" /Recurse
    )

    echo: && echo Saving Windows image...
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit
  )
) else (
  echo: && echo BOOT.WIM not found!
  exit /b 1
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # INSTALL.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

if exist "%wim%\install.wim" (
  Dism /Get-ImageInfo /ImageFile:"%wim%\install.wim"
  set /p "idx=Enter INDEX: "

  for %%i in (%idx%) do (
    echo: && echo Mounting a Windows image...
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%" && Dism /Get-MountedImageInfo

    if exist "%drv%" (
      echo: && echo Integrating Windows Drivers...
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Driver /Driver:"%drv%" /Recurse
    )

    if exist "%pkg%" (
      if exist "%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab" (
        echo: && echo Integrating Windows Client Language Packs...
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Client-Language-Pack_x64_ru-ru.cab"
      )
      if exist "%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab" (
        echo: && echo Integrating Windows Server Language Packs...
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%pkg%\Microsoft-Windows-Server-Language-Pack_x64_ru-ru.cab"
      )
    )

    if exist "%cap%" (
      echo: && echo Integrating Windows capabilities...
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Capability /CapabilityName:Language.Basic~~~ru-ru~0.0.1.0 /CapabilityName:Language.Handwriting~~~ru-ru~0.0.1.0 /CapabilityName:Language.OCR~~~ru-ru~0.0.1.0 /CapabilityName:Language.Speech~~~ru-ru~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~ru-ru~0.0.1.0 /Source:"%cap%"
    )

    if exist "%upd%" (
      echo: && echo Integrating Windows Updates...
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%upd%"
    )

    echo: && echo Reduce the Size of the Component Store...
    Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Cleanup-Image /StartComponentCleanup /ResetBase

    echo: && echo Saving Windows image...
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit
  )
) else (
  echo: && echo INSTALL.WIM not found!
  exit /b 1
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # EXIT
rem # ---------------------------------------------------------------------------------------------------------------- #

exit /b 0
