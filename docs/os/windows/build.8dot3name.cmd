@echo off

set "idx=%*"
set "mnt=%~dp0mnt"
set "tmp=%~dp0tmp"
set "wim=%~dp0wim"

:: ---------------------------------------------------------------------------------------------------------------------
:: BOOT.WIM
:: ---------------------------------------------------------------------------------------------------------------------

if exist "%wim%\boot.wim" (
  for %%i in (2) do (
    echo: && echo --- MOUNTING A BOOT IMAGE
    Dism /Mount-Image /ImageFile:"%wim%\boot.wim" /Index:%%i /MountDir:"%mnt%"

    echo: && echo --- STRIPPING 8.3 FILE NAMES
    fsutil 8dot3name strip /s /f "%mnt%"

    echo: && echo --- SAVING BOOT IMAGE
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit
  )
)

:: ---------------------------------------------------------------------------------------------------------------------
:: INSTALL.WIM
:: ---------------------------------------------------------------------------------------------------------------------

if exist "%wim%\install.wim" (
  for %%i in (%idx%) do (
    echo: && echo --- MOUNTING A WINDOWS IMAGE
    Dism /Mount-Image /ImageFile:"%wim%\install.wim" /Index:%%i /MountDir:"%mnt%" && Dism /Get-MountedImageInfo

    echo: && echo --- STRIPPING 8.3 FILE NAMES
    fsutil 8dot3name strip /s /f "%mnt%"

    echo: && echo --- SAVING WINDOWS IMAGE
    Dism /Unmount-Image /MountDir:"%mnt%" /Commit
  )
) else (
  echo: && echo INSTALL.WIM not found!
  exit /b 1
)

:: ---------------------------------------------------------------------------------------------------------------------
:: EXIT
:: ---------------------------------------------------------------------------------------------------------------------

exit /b 0
