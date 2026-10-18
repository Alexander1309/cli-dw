# 🎧 YouTube Audio/Video Downloader 4.0.1

Herramienta de línea de comandos para descargar contenido de YouTube en formato **mp3** o **mp4**. La versión 4.0.1 usa la búsqueda integrada de `yt-dlp`, valida los argumentos antes de iniciar, evita descargar listas completas por accidente y devuelve un código de salida distinto de cero si alguna descarga falla.

## 🚀 Funcionalidades

- **Descarga por URL directa:** Puedes descargar cualquier video o audio directamente proporcionando la URL de YouTube.
- **Descarga por nombres desde archivo:** Lee un archivo de texto con una lista de nombres de canciones y automáticamente busca en YouTube la mejor coincidencia para descargarlas.
- **Formatos soportados:**
  - Audio: `mp3`
  - Video: `mp4`

- **Creación automática de carpeta de destino:** Si la carpeta especificada no existe, se crea automáticamente.
- **Registro de errores:** Guarda en un archivo `songs_not_downloaded.txt` las canciones que no pudieron descargarse.
- **Reintentos automáticos:** Reintenta fragmentos y descargas fallidas hasta tres veces.
- **Archivos seguros:** Evita sobrescribir descargas existentes y adapta nombres para Windows.

## 💻 Requisitos

- Python 3.8 o superior
- Paquetes:
  - `yt-dlp`

Puedes instalarlos con:

```bash
pip install -r requirements.txt
```

## ⚠️ Instalación de FFmpeg

Antes de usar el script, ejecuta `instal.bat` (como Administrador recomendado). Este archivo:

- Descarga FFmpeg para Windows.
- Descomprime y mueve los binarios a `C:\ffmpeg`.
- Agrega `C:\ffmpeg\bin` al PATH global.
- Verifica que `ffmpeg` y `ffprobe` estén disponibles.

Si no tienes permisos de administrador, el script añadirá el PATH solo para la sesión actual; en ese caso, abre una nueva consola tras la instalación.

## ⚙️ Uso

### Opción 1: Modo interactivo (recomendado)

Usa el lanzador por lotes `dw.bat`, que guía paso a paso:

```bat
dw.bat
```

Con `dw.bat` podrás:

- Elegir entre descargar por URL o por archivo de nombres (por defecto usa `Lista Canciones.txt`).
- Seleccionar formato de salida: `mp3` o `mp4`.
- Elegir si descargar en una USB o en el PC. Las unidades USB conectadas se detectan automáticamente y se seleccionan por su letra; si no aparece ninguna, puedes volver a buscar o elegir el PC.
- En el PC, indicar una ruta base (por defecto, `Downloads` dentro de tu carpeta de usuario).
- Elegir entre descargar directamente en la raíz del destino seleccionado o indicar el nombre de una carpeta. La carpeta se crea antes de iniciar la descarga; si ya existe, se reutiliza.
- Revisar el destino y confirmar antes de empezar. Las raíces de unidad como `E:\` se pasan correctamente a Python.

Además, `dw.bat` fuerza la consola a UTF-8 para mostrar correctamente caracteres con acentos. La detección USB y la validación de nombres usan Windows PowerShell, incluido en Windows.

### Opción 2: Uso directo de Python

#### Descarga individual por URL

```bash
python dw.py --url "https://www.youtube.com/watch?v=XXXXXXXXXXX" --format mp3 --path-dest "C:\Descargas"
```

#### Descarga masiva desde archivo

1. Crear un archivo de texto, por ejemplo `songs.txt`, con el siguiente contenido:

```
Bad Bunny - Ojitos Lindos
The Weeknd - Save Your Tears
Coldplay - Yellow
```

2. Ejecutar el script:

```bash
python dw.py --file "C:\ruta\a\songs.txt" --format mp3 --path-dest "C:\Descargas"
```

### Opciones disponibles

| Opción               | Descripción                                |
| -------------------- | ------------------------------------------ |
| `--url`, `-u`        | URL directa del video de YouTube.          |
| `--file`, `-fi`      | Archivo de texto con nombres de canciones. |
| `--format`, `-ft`    | Formato obligatorio: `mp3` o `mp4`.        |
| `--path-dest`, `-pd` | Ruta de destino obligatoria.               |
| `--version`          | Muestra la versión instalada.              |

## 🗃️ Estructura del proyecto

```
cli-dw/
│
├── dw.py                      ← Script principal (versión 4.0.1)
├── dw.bat                     ← Lanzador interactivo (Windows)
├── instal.bat                 ← Instalador de FFmpeg (Windows)
├── Lista Canciones.txt        ← Archivo opcional con nombres de canciones
├── songs_not_downloaded.txt   ← Se crea si hay errores durante la descarga
├── requirements.txt           ← Dependencia Python
```

## 🛡️ Advertencia

- Este script se distribuye con fines educativos.
- Asegúrate de respetar las políticas de uso y derechos de autor de YouTube y otros servicios antes de descargar contenido.

## 💬 Datos del creador

Desarrollado por **Alexander Uriel Torres Pérez**.

- 📘 Facebook: [Alexander Uriel Torres Pérez](https://www.facebook.com/57372d0ba6934f836d8e497747097c87)
