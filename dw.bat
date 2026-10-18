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

:PREGUNTAR_DESTINO
echo.
echo Donde deseas descargar?
echo   [U] En una USB
echo   [P] En tu PC
choice /C UP /N /M "Opcion (U/P): "
if errorlevel 2 goto DESTINO_PC
goto DESTINO_USB

:DESTINO_USB
echo.
echo Buscando unidades USB conectadas...
set "USB_COUNT=0"
set "USB_CHOICES="
for /f "tokens=1,* delims=|" %%A in ('powershell.exe -NoProfile -Command "$ErrorActionPreference='Stop'; $ids=@(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=2' | Select-Object -ExpandProperty DeviceID); foreach ($disk in @(Get-CimInstance Win32_DiskDrive | Where-Object { $_.InterfaceType -eq 'USB' -or $_.PNPDeviceID -like 'USBSTOR*' })) { foreach ($partition in @(Get-CimAssociatedInstance -InputObject $disk -Association Win32_DiskDriveToDiskPartition)) { $ids+=@(Get-CimAssociatedInstance -InputObject $partition -Association Win32_LogicalDiskToPartition | Select-Object -ExpandProperty DeviceID) } }; Get-CimInstance Win32_LogicalDisk | Where-Object { $ids -contains $_.DeviceID } | Sort-Object DeviceID | ForEach-Object { '{0}|{1}' -f $_.DeviceID,$_.VolumeName }"') do (
  set /a USB_COUNT+=1
  set "USB_!USB_COUNT!=%%A\"
  set "USB_LETTER=%%A"
  set "USB_CHOICES=!USB_CHOICES!!USB_LETTER:~0,1!"
  echo   [!USB_LETTER:~0,1!] %%A\  %%B
)
if "!USB_COUNT!"=="0" (
  echo No se detectaron unidades USB disponibles. Comprueba que tengan letra asignada.
  echo   [R] Volver a buscar
  echo   [P] Descargar en el PC
  choice /C RP /N /M "Opcion (R/P): "
  if errorlevel 2 goto DESTINO_PC
  goto DESTINO_USB
)
choice /C !USB_CHOICES! /N /M "Selecciona la letra de la USB: "
set "USB_INDEX=!ERRORLEVEL!"
for %%N in (!USB_INDEX!) do set "BASE_DEST=!USB_%%N!"
if not exist "!BASE_DEST!" (
  echo La unidad ya no esta disponible. Vuelve a seleccionarla.
  goto DESTINO_USB
)
goto PREGUNTAR_CARPETA

:DESTINO_PC
echo.
set "BASE_DEST="
echo Indica la ruta base del PC ^(Enter para usar: "%USERPROFILE%\Downloads"^).
set /p "BASE_DEST=Ruta: "
if not defined BASE_DEST set "BASE_DEST=%USERPROFILE%\Downloads"
set "BASE_DEST=!BASE_DEST:"=!"
if not defined BASE_DEST goto DESTINO_PC
if "!BASE_DEST:~-1!"==":" set "BASE_DEST=!BASE_DEST!\"

:PREGUNTAR_CARPETA
echo.
echo Destino base: !BASE_DEST!
echo   [C] Crear o usar una carpeta
echo   [R] Descargar directamente en la raiz de este destino
choice /C CR /N /M "Opcion (C/R): "
set "DEST=!BASE_DEST!"
if errorlevel 2 goto RESUMEN

:NOMBRE_CARPETA
set "FOLDER_NAME="
set /p "FOLDER_NAME=Nombre de la carpeta: "
powershell.exe -NoProfile -Command "$name=$env:FOLDER_NAME; if ([string]::IsNullOrWhiteSpace($name) -or $name.IndexOfAny([IO.Path]::GetInvalidFileNameChars()) -ge 0 -or $name.EndsWith('.') -or $name.EndsWith(' ') -or $name -match '^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])($|\.)') { exit 1 }"
if errorlevel 1 (
  echo Nombre no valido. Escribe solo un nombre, sin rutas ni caracteres reservados.
  goto NOMBRE_CARPETA
)
set "DEST=!BASE_DEST!\!FOLDER_NAME!"

:RESUMEN
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
if not exist "!DEST!\" mkdir "!DEST!" 2>nul
if not exist "!DEST!\" (
  echo ERROR: No se pudo crear o acceder al destino: !DEST!
  echo Comprueba la ruta, los permisos y que la unidad siga conectada.
  goto PREGUNTAR_DESTINO
)
echo Iniciando descarga...
if "!MODE!"=="URL" (
  python "%SCRIPT_DIR%dw.py" --url "!INPUT_URL!" --format "!FORMAT!" --path-dest "!DEST!\."
) else (
  python "%SCRIPT_DIR%dw.py" --file "!INPUT_FILE!" --format "!FORMAT!" --path-dest "!DEST!\."
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
