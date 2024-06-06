@echo off
title Recowery Auto Installer By Parad1st
color 1f
echo Recovery Auto Installer By Parad1st V1.0
echo.
echo �� ��ᯫ��� �ਯ�: https://github.com/Parad1st/Recovery-Auto-Installer
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
	echo �� Windows XP ����� �� ࠡ����!
	if exist legacy (
		set sideload="%~dp0legacy\adb.exe"
		set fastboot="%~dp0legacy\fastboot.exe"
		set mode=legacy [platform-tools r23.1.0]
	)
)

if not exist %sideload% goto toolsnotfound
if not exist %fastboot% goto toolsnotfound
echo ����� ��⠭����: %mode%

set recovery=~
if not "%~1"=="" set recovery=%1
if "%~1"=="" (
	for %%i in (*twrp*.img recovery.img) do (
		set recovery="%~dp0%%i"
		goto recoveryfound
	)
)
:recoveryfound
if exist %recovery% echo �㤥� ��⠭������: %recovery%
if not exist %recovery% goto recoverynotfound

%sideload% kill-server >nul 2>&1
%sideload% start-server >nul 2>&1
echo ���� ���ன�⢠...
echo �������� �਩����� ���⢥न�� ����� �� �࠭� ⥫�䮭�!
rem �������� ��ப� �ਢ���� � ����
rem %sideload% wait-for-device
rem ���⮬� � ᤥ��� ����প� � 10 ᥪ㭤
for /l %%i in (1,1,10) do (
	%sideload% devices >nul 2>&1
	ver | findstr /il "5.1" >nul
	if %errorlevel% equ 0 ping -n 2 localhost >nul
	if %errorlevel% neq 0 timeout /t 1 /nobreak >nul
)
echo ���᮪ �����㦥���� ���ன��:
%sideload% devices

%sideload% reboot bootloader >nul 2>&1
%sideload% kill-server
echo ���� ���ன�⢠ FastBoot...
rem �������� ��ப� �ਢ���� � "��筮�� �����"
%fastboot% wait-for-device >nul 2>&1
echo ���᮪ �����㦥���� ���ன��:
%fastboot% devices
echo ���ன�⢮ �����㦥��, ��⠭�������� Recovery...
%fastboot% --disable-verity --disable-verification flash vbmeta vbmeta.img
%fastboot% flash recovery %recovery%
%fastboot% flash misc misc.bin
echo ��⠭���� �����襭�, ��१���㦠���� � Recovery...
%fastboot% reboot >nul 2>&1

color 2f
goto thisistheend

:miscbinnotfound
color 4f
echo ���� misc.bin �� �����㦥�!
echo �஢����, �ࠢ��쭮 �� �� ��⠭����� �ணࠬ��!
goto thisistheend

:vbmetanotfound
color 4f
echo ���� vbmeta.img �� �����㦥�!
echo �஢����, �ࠢ��쭮 �� �� ��⠭����� �ணࠬ��!
goto thisistheend

:toolsnotfound
color 4f
echo �ணࠬ�� platform-tools �� �����㦥��!
goto thisistheend

:recoverynotfound
color 4f
echo ���� Recovery �� �����㦥�! ��७��� 䠩� � ����� � �ਯ⮬. 
echo ���� ����� ����� �� �������� � ���७�� .img
echo ������ Recovery ��� ��襣� ⥫�䮭� ����� �� ��㬥 4pda.to
goto thisistheend

:thisistheend
echo 
pause
exit