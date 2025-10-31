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
set "font=Arab~~~und-ARAB~0.0.1.0 Beng~~~und-BENG~0.0.1.0 Cans~~~und-CANS~0.0.1.0 Cher~~~und-CHER~0.0.1.0 Deva~~~und-DEVA~0.0.1.0 Ethi~~~und-ETHI~0.0.1.0 Gujr~~~und-GUJR~0.0.1.0 Guru~~~und-GURU~0.0.1.0 Hans~~~und-HANS~0.0.1.0 Hant~~~und-HANT~0.0.1.0 Hebr~~~und-HEBR~0.0.1.0 Jpan~~~und-JPAN~0.0.1.0 Khmr~~~und-KHMR~0.0.1.0 Knda~~~und-KNDA~0.0.1.0 Kore~~~und-KORE~0.0.1.0 Laoo~~~und-LAOO~0.0.1.0 Mlym~~~und-MLYM~0.0.1.0 Orya~~~und-ORYA~0.0.1.0 PanEuropeanSupplementalFonts~~~~0.0.1.0 Sinh~~~und-SINH~0.0.1.0 Syrc~~~und-SYRC~0.0.1.0 Taml~~~und-TAML~0.0.1.0 Telu~~~und-TELU~0.0.1.0 Thai~~~und-THAI~0.0.1.0"

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # STRUCTURE
rem # ---------------------------------------------------------------------------------------------------------------- #

if "%1" == "struct" (
  for %%i in ("%drv%\boot" "%drv%\install" "%mnt%" "%pkg%" "%tmp%" "%wim%") do (
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
    echo: && echo --- MOUNTING A WINDOWS IMAGE
    Dism /Mount-Image /ImageFile:"%wim%\boot.wim" /Index:%%i /MountDir:"%mnt%"

    if exist "%drv%\boot" (
      echo: && echo --- INTEGRATING DRIVERS
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Driver /Driver:"%drv%\boot" /Recurse
    )

    echo: && echo --- SAVING WINDOWS IMAGE
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit
  )
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # INSTALL.WIM
rem # ---------------------------------------------------------------------------------------------------------------- #

if exist "%wim%\install.wim" (
  for %%i in (%idx%) do (
    echo: && echo --- MOUNTING A WINDOWS IMAGE
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%" && Dism /Get-MountedImageInfo

    if exist "%drv%\install" (
      echo: && echo --- INTEGRATING DRIVERS
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Driver /Driver:"%drv%\install" /Recurse
    )

    if exist "%pkg%" (
      echo: && echo --- INTEGRATING PACKAGES
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%pkg%"
    )

    if exist "%cap%" (
      echo: && echo --- INTEGRATING CAPABILITIES
      for %%l in (%lang%) do (
        echo: && echo Installing capability "%%l"...
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Capability /CapabilityName:Language.Basic~~~%%l~0.0.1.0 /CapabilityName:Language.Handwriting~~~%%l~0.0.1.0 /CapabilityName:Language.OCR~~~%%l~0.0.1.0 /CapabilityName:Language.Speech~~~%%l~0.0.1.0 /CapabilityName:Language.TextToSpeech~~~%%l~0.0.1.0 /Source:"%cap%"
      )
      for %%f in (%font%) do (
        echo: && echo Installing font "%%f"...
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Capability /CapabilityName:Language.Fonts.%%f /Source:"%cap%"
      )
    )

    if exist "%upd%" (
      echo: && echo --- INTEGRATING UPDATES
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%upd%"
    )

    echo: && echo --- REDUCE THE SIZE OF THE COMPONENT STORE
    Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Cleanup-Image /StartComponentCleanup /ResetBase

    echo: && echo --- REPAIRING A WINDOWS IMAGE
    Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Cleanup-Image /RestoreHealth

    echo: && echo --- SAVING WINDOWS IMAGE
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit

    echo: && echo --- EXPORTING AND COMPRESSING WINDOWS IMAGE
    Dism /Export-Image /SourceImageFile:"%wim%\install.wim" /SourceIndex:%%i /DestinationImageFile:"%wim%\install.%%i.wim" /Compress:max /CheckIntegrity
  )
) else (
  echo: && echo INSTALL.WIM not found!
  exit /b 1
)

rem # ---------------------------------------------------------------------------------------------------------------- #
rem # EXIT
rem # ---------------------------------------------------------------------------------------------------------------- #

exit /b 0
