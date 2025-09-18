@echo off

set "idx=%*"
set "cap=%~dp0cap"
set "drv=%~dp0drv"
set "mnt=%~dp0mnt"
set "pkg=%~dp0pkg"
set "tmp=%~dp0tmp"
set "upd=%~dp0upd"
set "wim=%~dp0wim"
set "lang=ru-ru zh-cn"
set "font=Ethi~~~und-ETHI Arab~~~und-ARAB Syrc~~~und-SYRC Beng~~~und-BENG Beng~~~und-BENG Beng~~~und-BENG Cher~~~und-CHER Arab~~~und-ARAB Gujr~~~und-GUJR Hebr~~~und-HEBR Deva~~~und-DEVA Jpan~~~und-JPAN Khmr~~~und-KHMR Knda~~~und-KNDA Deva~~~und-DEVA Kore~~~und-KORE Arab~~~und-ARAB Laoo~~~und-LAOO Mlym~~~und-MLYM Deva~~~und-DEVA Deva~~~und-DEVA Orya~~~und-ORYA Arab~~~und-ARAB Guru~~~und-GURU Arab~~~und-ARAB Arab~~~und-ARAB Sinh~~~und-SINH Syrc~~~und-SYRC Taml~~~und-TAML Telu~~~und-TELU Thai~~~und-THAI Ethi~~~und-ETHI Arab~~~und-ARAB Arab~~~und-ARAB Hans~~~und-HANS Hant~~~und-HANT"

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
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # INSTALL.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

if exist "%wim%\install.wim" (
  for %%i in (%idx%) do (
    echo: && echo Mounting a Windows image...
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%" && Dism /Get-MountedImageInfo

    if exist "%drv%" (
      echo: && echo Integrating Windows Drivers...
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Driver /Driver:"%drv%" /Recurse
    )

    if exist "%pkg%" (
      echo: && echo Integrating Windows Language Packs...
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%pkg%"
    )

    if exist "%cap%" (
      echo: && echo Integrating Windows capabilities...
      for %%l in (%lang%) do (
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Capability /CapabilityName:Language.Basic~~~%%l~0.0.1.0 /CapabilityName:Language.Handwriting~~~%%l~0.0.1.0 /CapabilityName:Language.OCR~~~%%l~0.0.1.0 /CapabilityName:Language.Speech~~~%%l~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~%%l~0.0.1.0 /Source:"%cap%"
      )
      for %%f in (%font%) do (
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Capability /CapabilityName:Language.Fonts.%%f~0.0.1.0 /Source:"%cap%"
      )
    )

    if exist "%upd%" (
      echo: && echo Integrating Windows Updates...
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%upd%"
    )

    echo: && echo Reduce the Size of the Component Store...
    Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Cleanup-Image /StartComponentCleanup /ResetBase

    echo: && echo Repairing a Windows Image...
    Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Cleanup-Image /RestoreHealth

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
