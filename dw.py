import argparse
from pathlib import Path
from typing import List, Optional

import yt_dlp


VERSION = "4.0.1"


class Downloader:
    def __init__(self, args: argparse.Namespace):
        self.args = args
        self.errors: List[str] = []

    def read_queries(self) -> List[str]:
        if self.args.url:
            return [self.args.url]
        with self.args.file.open("r", encoding="utf-8", errors="replace") as file:
            return [line.strip() for line in file if line.strip()]

    def find_url(self, query: str) -> Optional[str]:
        if query.startswith(("http://", "https://")):
            return query
        print(f"Buscando: {query}")
        options = {"quiet": True, "no_warnings": True, "extract_flat": True}
        with yt_dlp.YoutubeDL(options) as ydl:
            result = ydl.extract_info(f"ytsearch1:{query}", download=False)
        entries = result.get("entries") or []
        if not entries:
            return None
        entry = entries[0]
        return entry.get("webpage_url") or entry.get("url")

    def download(self, url: str, query: str) -> None:
        options = {
            "format": (
                "bestaudio/best" if self.args.format == "mp3"
                else "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            ),
            "outtmpl": str(self.args.destination / "%(title)s.%(ext)s"),
            "noplaylist": True,
            "retries": 3,
            "fragment_retries": 3,
            "windowsfilenames": True,
            "overwrites": False,
        }
        if self.args.format == "mp3":
            options["postprocessors"] = [{
                "key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "192",
            }]

        print(f"\nDescargando: {query}\nFormato: {self.args.format}\nDestino: {self.args.destination}")
        with yt_dlp.YoutubeDL(options) as ydl:
            ydl.download([url])

    def run(self) -> int:
        self.args.destination.mkdir(parents=True, exist_ok=True)
        for query in self.read_queries():
            try:
                url = self.find_url(query)
                if not url:
                    raise RuntimeError("No se encontraron resultados")
                self.download(url, query)
                print("Descarga completada.")
            except Exception as error:
                message = f"Consulta: {query}\nError: {error}\n"
                self.errors.append(message)
                print(f"Error: {message}")

        if self.errors:
            Path("songs_not_downloaded.txt").write_text(
                "=== Descargas fallidas (Downloader 4.0) ===\n\n"
                + "\n".join(self.errors), encoding="utf-8"
            )
            return 1
        return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Descargador de YouTube para audio y video")
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--url", "-u", help="URL de un video de YouTube")
    source.add_argument("--file", "-fi", type=Path, help="Archivo con búsquedas, una por línea")
    parser.add_argument("--format", "-ft", choices=("mp3", "mp4"), required=True)
    parser.add_argument("--path-dest", "-pd", type=Path, required=True, dest="destination")
    parser.add_argument("--version", action="version", version=VERSION)
    args = parser.parse_args()
    if args.file and not args.file.is_file():
        parser.error(f"El archivo no existe: {args.file}")
    return args


if __name__ == '__main__':
    raise SystemExit(Downloader(parse_args()).run())
