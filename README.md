# 🎧 YouTube Audio/Video Downloader

Este proyecto es un script en Python diseñado para descargar canciones o videos desde YouTube en formato **mp3** o **mp4** de manera rápida y automática. Además, permite buscar y descargar múltiples canciones a partir de un archivo de texto con nombres de canciones o artistas.

## 🚀 Funcionalidades

- **Descarga por URL directa:** Puedes descargar cualquier video o audio directamente proporcionando la URL de YouTube.
- **Descarga por nombres desde archivo:** Lee un archivo de texto con una lista de nombres de canciones y automáticamente busca en YouTube la mejor coincidencia para descargarlas.
- **Formatos soportados:**

  - Audio: `mp3`
  - Video: `mp4`

- **Creación automática de carpeta de destino:** Si la carpeta especificada no existe, se crea automáticamente.
- **Registro de errores:** Guarda en un archivo `songs_not_downloaded.txt` las canciones que no pudieron descargarse.

## 💻 Requisitos

- Python 3.7 o superior
- Paquetes:

  - `yt_dlp`
  - `youtube-search-python`

Puedes instalarlos con:

```bash
pip install yt_dlp youtube-search-python
```

## ⚠️ Instalación de FFmpeg

Antes de usar el script, debes ejecutar el archivo `install.bat` incluido en el proyecto. Este archivo descarga FFmpeg (herramienta necesaria para procesar audio y video), lo descomprime, lo mueve a `C:\ffmpeg`, y agrega automáticamente su carpeta `bin` al PATH de Windows. Además, limpia los archivos temporales y verifica la instalación de `ffmpeg` y `ffprobe`. Una vez completado, tu sistema estará listo para realizar conversiones de audio y video correctamente.

## ⚙️ Uso

### Descarga individual por URL

```bash
python script.py --url "https://www.youtube.com/watch?v=XXXXXXXXXXX" --format mp3 --path-dest "C:\Descargas"
```

### Descarga masiva desde archivo

1. Crear un archivo de texto, por ejemplo `songs.txt`, con el siguiente contenido:

```
Bad Bunny - Ojitos Lindos
The Weeknd - Save Your Tears
Coldplay - Yellow
```

2. Ejecutar el script:

```bash
python script.py --file "C:\ruta\a\songs.txt" --format mp3 --path-dest "C:\Descargas"
```

### Opciones disponibles

| Opción               | Descripción                                |
| -------------------- | ------------------------------------------ |
| `--url`, `-u`        | URL directa del video de YouTube.          |
| `--file`, `-fi`      | Archivo de texto con nombres de canciones. |
| `--format`, `-ft`    | Formato de descarga: `mp3` o `mp4`.        |
| `--path-dest`, `-pd` | Ruta de destino para los archivos.         |

## 🗃️ Estructura del proyecto

```
Downloader/
│
├── script.py
├── install.bat
├── songs_not_downloaded.txt   ← Se crea si hay errores durante la descarga
```

## 🛡️ Advertencia

- Este script se distribuye con fines educativos.
- Asegúrate de respetar las políticas de uso y derechos de autor de YouTube y otros servicios antes de descargar contenido.

## 💬 Datos del creador

Desarrollado por **Alexander Uriel Torres Pérez**.

- 📘 Facebook: [Alexander Uriel Torres Pérez](https://www.facebook.com/57372d0ba6934f836d8e497747097c87)
