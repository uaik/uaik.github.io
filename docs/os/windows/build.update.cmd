@echo off

set "idx=%*"
set "mnt=%~dp0mnt"
set "tmp=%~dp0tmp"
set "upd0=%~dp0upd.0"
set "upd1=%~dp0upd.1"
set "wim=%~dp0wim"

set "msu=windows11.0-kb5121003-x64_dc58f03fef04b4c611e0db0ab3fadfb301194113.msu"

:: ---------------------------------------------------------------------------------------------------------------------
:: INSTALL.WIM
:: ---------------------------------------------------------------------------------------------------------------------

if exist "%wim%\install.wim" (
  for %%i in (%idx%) do (
    echo: && echo --- MOUNTING A WINDOWS IMAGE
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%" && Dism /Get-MountedImageInfo

    if exist "%upd0%" (
      if exist "%upd0%\%msu%" (
        echo: && echo --- INTEGRATING CUMULATIVE UPDATE
        Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%upd0%\%msu%"
      )
    )

    if exist "%upd1%" (
      echo: && echo --- INTEGRATING OTHER UPDATES
      Dism /Image:"%mnt%" /ScratchDir:"%tmp%" /Add-Package /PackagePath:"%upd1%"
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

:: ---------------------------------------------------------------------------------------------------------------------
:: EXIT
:: ---------------------------------------------------------------------------------------------------------------------

exit /b 0
