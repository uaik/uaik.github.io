@echo off

:: ---------------------------------------------------------------------------------------------------------------------
:: Load DefaultUser.
:: ---------------------------------------------------------------------------------------------------------------------

reg load "HKU\DefaultUser" "C:\Users\Default\NTUSER.DAT"

:: ---------------------------------------------------------------------------------------------------------------------
:: Always show file extensions.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d "0" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Launch folder windows in a separate process.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Left-align the taskbar in Windows 11.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarAl" /t "REG_DWORD" /d "0" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Do not show Bing results when searching in the Start menu or the search box.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKU\DefaultUser\Software\Policies\Microsoft\Windows\Explorer" /v "DisableSearchBoxSuggestions" /t "REG_DWORD" /d "1" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Disable Content Delivery Manager.
:: ---------------------------------------------------------------------------------------------------------------------

reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "OEMPreInstalledAppsEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "PreInstalledAppsEverEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContentEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338387Enabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338393Enabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353694Enabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353696Enabled" /t "REG_DWORD" /d "0" /f
reg add "HKU\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-353698Enabled" /t "REG_DWORD" /d "0" /f

:: ---------------------------------------------------------------------------------------------------------------------
:: Unload DefaultUser and exit.
:: ---------------------------------------------------------------------------------------------------------------------

reg unload "HKU\DefaultUser" && exit
