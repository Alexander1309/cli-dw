@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo Descargando FFmpeg para Windows...
echo ========================================
curl -L -o ffmpeg.zip https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip

echo ========================================
echo Descomprimiendo...
echo ========================================
powershell -Command "Expand-Archive -Force 'ffmpeg.zip' 'ffmpeg_temp'"

echo ========================================
echo Moviendo a C:\ffmpeg
echo ========================================
if exist "C:\ffmpeg" (
    echo Eliminando version anterior en C:\ffmpeg
    rmdir /s /q C:\ffmpeg
)
move ffmpeg_temp\ffmpeg-* C:\ffmpeg

echo ========================================
echo Preparando PATH global
echo ========================================
rem Leer PATH actual del registro
for /f "tokens=3*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path') do set "OldPath=%%A %%B"

rem Verificar si ya contiene C:\ffmpeg\bin
echo !OldPath! | find /I "C:\ffmpeg\bin" >nul
if not errorlevel 1 (
    echo C:\ffmpeg\bin ya existe en el PATH global.
) else (
    echo Agregando C:\ffmpeg\bin al PATH global...
    set "NewPath=!OldPath!;C:\ffmpeg\bin"
    rem Modificar registro de forma segura
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path /t REG_EXPAND_SZ /d "!NewPath!" /f
)

echo ========================================
echo Actualizando PATH en esta sesion
echo ========================================
set "PATH=C:\ffmpeg\bin;%PATH%"

echo ========================================
echo Limpiando archivos temporales
echo ========================================
del ffmpeg.zip
rmdir /s /q ffmpeg_temp

echo ========================================
echo Verificando instalacion de ffmpeg
echo ========================================
ffmpeg -version
if errorlevel 1 (
    echo ERROR: ffmpeg no esta disponible. Revisa la instalacion manualmente.
    pause
    exit /b 1
)

echo ========================================
echo Verificando instalacion de ffprobe
echo ========================================
ffprobe -version
if errorlevel 1 (
    echo ERROR: ffprobe no esta disponible. Revisa la instalacion manualmente.
    pause
    exit /b 1
)

echo ========================================
echo ¡Proceso completado!
echo ffmpeg y ffprobe funcionan correctamente.
echo ========================================
echo NOTA: Para que el PATH global funcione en nuevas consolas,
echo       debes cerrar sesión o reiniciar, o abrir una nueva consola.
echo ========================================
pause
