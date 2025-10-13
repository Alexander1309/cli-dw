import argparse
import re
import os
from os import mkdir, system
from os.path import isdir, isfile, join
from youtubesearchpython import VideosSearch
import yt_dlp


class Downloader:
    def __init__(self):
        self.url_file = ""
        self.name_file = ""
        self.format_file = ""
        self.path_file_dest = ""
        self.message_errors = []

        parser = argparse.ArgumentParser()
        parser.add_argument('--url', '-u')
        parser.add_argument('--file', '-fi')
        parser.add_argument('--format', '-ft')
        parser.add_argument('--path-dest', '-pd')
        self.args = list(vars(parser.parse_args()).values())

    def write_log_error(self):
        with open('./songs_not_downloaded.txt', 'w', encoding='utf-8') as file_log:
            file_log.writelines(self.message_errors)

    def read_file(self, path):
        with open(path, 'r', encoding='utf-8', errors='replace') as file:
            return [line.strip('\n').strip('\t') for line in file.readlines()]

    def validate_args(self):
        print('Validating args...\n')
        url, file_names, format, path_dest = self.args

        if format not in {'mp3', 'mp4'}:
            raise OSError('Invalid format. Valid formats: mp3, mp4')

        if path_dest is None:
            raise OSError('Destination path cannot be empty. Use --path-dest or -pd')

        if file_names and not url and not isfile(file_names):
            raise OSError("""Invalid or non-existent file path.

Example file:
  -fi C:\\Users\\username\\names.txt

File content:
  name 1
  name 2
  ...
""")

        if not isdir(path_dest):
            mkdir(path_dest)

    def unloader(self):
        try:
            # Antes de descargar, obtener el título
            with yt_dlp.YoutubeDL({'quiet': True}) as ydl:
                info = ydl.extract_info(self.url_file, download=False)
                self.name_file = info.get('title', 'Unknown Title')

            ydl_opts = {}

            if self.format_file == "mp3":
                ydl_opts = {
                    'format': 'bestaudio/best',
                    'outtmpl': join(self.path_file_dest, '%(title)s.%(ext)s'),
                    'postprocessors': [{
                        'key': 'FFmpegExtractAudio',
                        'preferredcodec': 'mp3',
                        'preferredquality': '192',
                    }],
                    'quiet': True,
                    'no_warnings': True,
                }
            else:  # mp4
                ydl_opts = {
                    'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4',
                    'outtmpl': join(self.path_file_dest, '%(title)s.%(ext)s'),
                    'quiet': True,
                    'no_warnings': True,
                }

            print(f"""\n=== Downloading ===
> Name: {self.name_file}
> Format: {self.format_file}
> URL: {self.url_file}
> Destination: {self.path_file_dest}\n""")

            with yt_dlp.YoutubeDL(ydl_opts) as ydl:
                ydl.download([self.url_file])

            print("\nDownload completed!")
            system("cls")

        except Exception as e:
            self.message_errors.append(f"""=== Could not download file ===
> URL: {self.url_file}
> Format: {self.format_file}
> Error: {str(e)}\n\n""")

    def get_urls(self, data):
        urls = []
        for n in data:
            if not n:
                continue
            print(f'Getting URL for: {n}')
            try:
                search = VideosSearch(n, limit=1)
                result = search.result()
                items = result.get('result') or []
                if items:
                    urls.append(items[0].get('link'))
                else:
                    self.message_errors.append(f"No results for query: {n}\n")
            except Exception as e:
                self.message_errors.append(f"Search error for '{n}': {str(e)}\n")
        return [u for u in urls if u]

    def main(self):
        self.validate_args()
        url, file_names, format, path_dest = self.args

        self.format_file = format
        self.path_file_dest = path_dest

        if file_names and not url:
            names = self.read_file(file_names)
            urls = self.get_urls(names)
            for i in range(len(urls)):
                self.url_file = urls[i]
                self.unloader()
            else:
                if self.message_errors:
                    self.write_log_error()
        else:
            self.url_file = url
            self.unloader()
            if self.message_errors:
                self.write_log_error()


if __name__ == '__main__':
    dw = Downloader()
    dw.main()
