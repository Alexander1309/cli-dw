@echo off
setlocal EnableExtensions EnableDelayedExpansion

rem Forzar consola a UTF-8 para mostrar acentos correctamente
chcp 65001 >nul
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"

title YouTube Audio/Video Downloader 4.0 - CLI

echo ============================================
echo   YouTube Audio/Video Downloader 4.0
echo   Desarrollado por Alexander Uriel Torres Pérez
echo ============================================
echo.

rem --- Comprobaciones básicas ---
where python >nul 2>&1
if errorlevel 1 (
  echo ERROR: Python no está en el PATH. Instala Python 3.8+ y vuelve a intentar.
  pause
  exit /b 1
)

where ffmpeg >nul 2>&1
if errorlevel 1 (
  echo ADVERTENCIA: ffmpeg no se detectó en el PATH.
  echo Si la conversión o mezcla falla, ejecuta "instal.bat" como administrador y vuelve a abrir la consola.
  echo.
)

set "SCRIPT_DIR=%~dp0"

echo Selecciona el modo de descarga:
echo   [U] URL
echo   [A] Archivo ^(lista de nombres^)
choice /C UA /N /M "Opción (U/A): "
if errorlevel 2 goto MODO_ARCHIVO
if errorlevel 1 goto MODO_URL

:MODO_URL
set "MODE=URL"
set /p "INPUT_URL=Ingresa la URL de YouTube: "
if "!INPUT_URL!"=="" (
  echo La URL no puede estar vacía.
  pause
  exit /b 1
)
goto PREGUNTAR_FORMATO

:MODO_ARCHIVO
set "MODE=ARCHIVO"
set "DEFAULT_LIST=%SCRIPT_DIR%Lista Canciones.txt"
echo Ingresa la ruta del archivo de nombres ^(Enter para usar: "!DEFAULT_LIST!"^)
set /p "INPUT_FILE=Ruta del archivo: "
if "!INPUT_FILE!"=="" set "INPUT_FILE=!DEFAULT_LIST!"
if not exist "!INPUT_FILE!" (
  echo No se encontró el archivo: "!INPUT_FILE!"
  pause
  exit /b 1
)
goto PREGUNTAR_FORMATO

:PREGUNTAR_FORMATO
echo.
echo Elige el formato de salida:
echo   [1] mp3 ^(audio^)
echo   [2] mp4 ^(video^)
choice /C 12 /N /M "Opción (1/2): "
if errorlevel 2 set "FORMAT=mp4"
if errorlevel 1 if not defined FORMAT set "FORMAT=mp3"

echo.
set "DEFAULT_DEST=%SCRIPT_DIR%Descargas"
echo Ingresa la carpeta de destino ^(Enter para usar: "!DEFAULT_DEST!"^)
set /p "DEST=Destino: "
if "!DEST!"=="" set "DEST=!DEFAULT_DEST!"

echo.
echo Resumen:
if "!MODE!"=="URL" echo   Modo: URL
if "!MODE!"=="ARCHIVO" echo   Modo: Archivo
if "!MODE!"=="URL" echo   URL: !INPUT_URL!
if "!MODE!"=="ARCHIVO" echo   Archivo: !INPUT_FILE!
echo   Formato: !FORMAT!
echo   Destino: !DEST!

echo.
choice /C SN /N /M "¿Confirmar y comenzar descarga? [S/N]: "
if errorlevel 2 (
  echo Operación cancelada por el usuario.
  pause
  exit /b 0
)

echo.
echo Iniciando descarga...
if "!MODE!"=="URL" (
  python "%SCRIPT_DIR%dw.py" --url "!INPUT_URL!" --format "!FORMAT!" --path-dest "!DEST!"
) else (
  python "%SCRIPT_DIR%dw.py" --file "!INPUT_FILE!" --format "!FORMAT!" --path-dest "!DEST!"
)

set "EXITCODE=%ERRORLEVEL%"
echo.
if %EXITCODE% NEQ 0 (
  echo El proceso finalizó con errores ^(código %EXITCODE%^).
) else (
  echo Descarga finalizada.
)

echo.
pause
exit /b %EXITCODE%
