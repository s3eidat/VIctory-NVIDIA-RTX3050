@echo off
rem VIctory-NVIDIA tuned for an RTX 3050 8 GB / 16 GB RAM. See README.md.
rem The game folder (the one with your own game_scarlett_master.exe) comes from game_dir.txt (first line)
rem or from the VICTORY_GAME_DIR variable.
cd /d "%~dp0"
if not defined VICTORY_GAME_DIR (
  if exist "%~dp0game_dir.txt" (
    set /p VICTORY_GAME_DIR=<"%~dp0game_dir.txt"
  )
)
if not defined VICTORY_GAME_DIR (
  echo Put the folder with your own game_scarlett_master.exe on the first line of game_dir.txt,
  echo or set VICTORY_GAME_DIR, then run this again.
  pause
  exit /b 2
)
set "VICTORY_GAME_DIR=%VICTORY_GAME_DIR:"=%"
if not exist "%VICTORY_GAME_DIR%\game_scarlett_master.exe" (
  echo No game_scarlett_master.exe in "%VICTORY_GAME_DIR%".
  pause
  exit /b 2
)
rem Copy (never delete) the saves first.
if exist "%LOCALAPPDATA%\victory\data\7952987A" (
  robocopy "%LOCALAPPDATA%\victory\data\7952987A" "%USERPROFILE%\victory-save-backups\7952987A-before-run" /E /NFL /NDL /NJH /NJS /NP >nul
)
rem -Command (not -File) so that the -More hashtable stays a hashtable.
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0scripts\play-foxhound.ps1' -Exe '%VICTORY_GAME_DIR%\game_scarlett_master.exe' -SeriesS -Dlss performance -NoFrameGenReady -Fps 1000 -More @{VICTORY_AMBIENT='1.6';VICTORY_AMBIENT_AIR='0.8'}"
pause
