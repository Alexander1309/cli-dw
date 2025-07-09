@echo off
setlocal

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
echo Agregando C:\ffmpeg\bin al PATH
echo ========================================
setx /M PATH "%PATH%;C:\ffmpeg\bin"

rem ====== Forzar el PATH en esta sesión ======
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
echo Proceso completado!
echo Ahora puedes usar ffmpeg en cualquier nueva consola.
echo ========================================
pause
