@echo off

set "idx=%*"
set "cap=%~dp0cap"
set "drv=%~dp0drv"
set "mnt=%~dp0mnt"
set "pkg=%~dp0pkg"
set "tmp=%~dp0tmp"
set "upd=%~dp0upd"
set "wim=%~dp0wim"
set "lang=af-za am-et ar-sa as-in az-latn-az ba-ru be-by bg-bg bn-bd bn-in br-fr bs-latn-ba ca-es cs-cz cy-gb da-dk de-ch de-de el-gr en-au en-ca en-gb en-in es-es es-mx es-us et-ee eu-es fa-ir fi-fi fil-ph fo-fo fr-be fr-ca fr-ch fr-fr ga-ie gd-gb gl-es gu-in ha-latn-ng haw-us he-il hi-in hr-hr hu-hu hy-am id-id ig-ng is-is it-it ja-jp ka-ge kk-kz kl-gl km-kh kn-in ko-kr kok-deva-in ky-kg lb-lu lo-la lt-lt lv-lv mi-nz mk-mk ml-in mn-mn mr-in ms-bn ms-my mt-mt my-mm nb-no ne-np nl-nl nn-no nso-za or-in pa-arab-pk pa-in pl-pl ps-af pt-br pt-pt quc-latn-gt quz-bo rm-ch ro-ro ru-ru rw-rw sah-ru sd-arab-pk si-lk sk-sk sl-si so-so sq-al sr-cyrl-rs sr-latn-rs sv-se sw-ke ta-in te-in tg-cyrl-tj th-th tk-tm tn-za tr-tr tt-ru ug-cn uk-ua ur-pk uz-latn-uz vi-vn wo-sn xh-za yo-ng zh-cn zh-hk zh-tw zu-za"
set "font=Arab~~~und-ARAB~0.0.1.0 Beng~~~und-BENG~0.0.1.0 Cans~~~und-CANS~0.0.1.0 Cher~~~und-CHER~0.0.1.0 Deva~~~und-DEVA~0.0.1.0 Ethi~~~und-ETHI~0.0.1.0 Gujr~~~und-GUJR~0.0.1.0 Guru~~~und-GURU~0.0.1.0 Hans~~~und-HANS~0.0.1.0 Hant~~~und-HANT~0.0.1.0 Hebr~~~und-HEBR~0.0.1.0 Jpan~~~und-JPAN~0.0.1.0 Khmr~~~und-KHMR~0.0.1.0 Knda~~~und-KNDA~0.0.1.0 Kore~~~und-KORE~0.0.1.0 Laoo~~~und-LAOO~0.0.1.0 Mlym~~~und-MLYM~0.0.1.0 Orya~~~und-ORYA~0.0.1.0 PanEuropeanSupplementalFonts~~~~0.0.1.0 Sinh~~~und-SINH~0.0.1.0 Syrc~~~und-SYRC~0.0.1.0 Taml~~~und-TAML~0.0.1.0 Telu~~~und-TELU~0.0.1.0 Thai~~~und-THAI~0.0.1.0"

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
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Capability /CapabilityName:Language.Fonts.%%f /Source:"%cap%"
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
