@echo off
title Recowery Auto Installer By Parad1st
color 1f
echo Recovery Auto Installer By Parad1st V1.0
echo.
echo Это бесплатный скрипт: https://github.com/Parad1st/Recovery-Auto-Installer
cd /d %~dp0

if not exist misc.bin goto miscbinnotfound
if not exist vbmeta.img goto vbmetanotfound

set sideload="%~dp0adb.exe"
set fastboot="%~dp0fastboot.exe"
set mode=manual
if exist modern (
	set sideload="%~dp0modern\adb.exe"
	set fastboot="%~dp0modern\fastboot.exe"
	set mode=modern [platform-tools r30.0.5]
)
ver
ver | findstr /il "5.1" >nul
if %errorlevel% equ 0 (
	echo На Windows XP может не работать!
	if exist legacy (
		set sideload="%~dp0legacy\adb.exe"
		set fastboot="%~dp0legacy\fastboot.exe"
		set mode=legacy [platform-tools r23.1.0]
	)
)

if not exist %sideload% goto toolsnotfound
if not exist %fastboot% goto toolsnotfound
echo Режим установки: %mode%

set recovery=~
if not "%~1"=="" set recovery=%1
if "%~1"=="" (
	for %%i in (*twrp*.img recovery.img) do (
		set recovery="%~dp0%%i"
		goto recoveryfound
	)
)
:recoveryfound
if exist %recovery% echo Будет установлено: %recovery%
if not exist %recovery% goto recoverynotfound

%sideload% kill-server >nul 2>&1
%sideload% start-server >nul 2>&1
echo Поиск устройства...
echo Возможно прийдётся подтвердить запрос на экране телефона!
rem Следующая строка приводит г багу
rem %sideload% wait-for-device
rem Пожтому я сделал задержку в 10 секунд
for /l %%i in (1,1,10) do (
	%sideload% devices >nul 2>&1
	ver | findstr /il "5.1" >nul
	if %errorlevel% equ 0 ping -n 2 localhost >nul
	if %errorlevel% neq 0 timeout /t 1 /nobreak >nul
)
echo Список обнаруженных устройств:
%sideload% devices

%sideload% reboot bootloader >nul 2>&1
%sideload% kill-server
echo Поиск устройства FastBoot...
rem Следующая строка приводит к "вечному поиску"
%fastboot% wait-for-device >nul 2>&1
echo Список обнаруженных устройств:
%fastboot% devices
echo Устройство обнаружено, устанавливаем Recovery...
%fastboot% --disable-verity --disable-verification flash vbmeta vbmeta.img
%fastboot% flash recovery %recovery%
%fastboot% flash misc misc.bin
echo Установка завершена, перезагружаемся в Recovery...
%fastboot% reboot >nul 2>&1

color 2f
goto thisistheend

:miscbinnotfound
color 4f
echo Файл misc.bin не обнаружен!
echo Проверьте, правильно ли вы установили программу!
goto thisistheend

:vbmetanotfound
color 4f
echo Файл vbmeta.img не обнаружен!
echo Проверьте, правильно ли вы установили программу!
goto thisistheend

:toolsnotfound
color 4f
echo Программы platform-tools не обнаружены!
goto thisistheend

:recoverynotfound
color 4f
echo Файл Recovery не обнаружен! Перенесите файл в папку со скриптом. 
echo Файл может иметь любое название и расширение .img
echo Скачать Recovery для вашего телефона можно на форуме 4pda.to
goto thisistheend

:thisistheend
echo 
pause
exit