import argparse
import re
import shutil
from os import mkdir, remove, system
from os.path import abspath, isdir, isfile, join

import moviepy.editor as mp
import pafy
from youtubesearchpython import VideosSearch

class Dowloader:
  def __init__(self):
    self.url_file = ""
    self.name_file = ""
    self.path_file = ""
    self.format_file = ""
    self.path_file_dest = ""

    self.unloader_extensions = {
      "mp3": "m4a",
      "mp4": "mp4"
    }

    self.count_errors = 0
    self.message_errors = []
    self.path_files_errors = []

    parser = argparse.ArgumentParser()
    parser.add_argument('--url', '-u')
    parser.add_argument('--file', '-fi')
    parser.add_argument('--format', '-ft')
    parser.add_argument('--path-dest', '-pd')
    self.args = list(vars(parser.parse_args()).values())

  def write_log_error(self):
    file_log = open('./songs_not_downloaded.txt', 'w')
    file_log.writelines(self.message_errors)
    file_log.close()

  def read_file(self, path):
    readData = []
    with open(path, 'r') as file:
      readFile = file.readlines()
      for _, read in enumerate(readFile):
        readData.append(read.strip('\n').strip('\t'))
    return readData

  def delete_files(self):
    try:
      for _, path_file_error in enumerate(self.path_files_errors):
        remove(path_file_error)
    except:
      return
  
  def move_download(self):
    if self.format_file == "mp3":
      remove(self.path_unloader)
    shutil.move(abspath(f'./{self.name_unloader}'), self.path_file_dest)

  def convert_format(self):
    audio_convert = mp.AudioFileClip(self.path_unloader)
    audio_convert.write_audiofile(self.name_unloader, bitrate="320k")
    audio_convert.close()

  def validate_args(self):
    print('Validating args...\n')
    url, file_names, format, path_dest = self.args

      
    if not format in {'mp3', 'mp4'}:
      raise OSError('Format is invalid... formats valids: mp3, mp4')

    if path_dest == None:
      raise OSError('Destination path cannot be empty please add the path with the command --path-dest or -pd')
    
    if file_names != None and url == None and not isfile(file_names):
        raise OSError("""The path of the names file is invalid or does not exist please
    check the path or the name file format should be .txt
      
    example:
      -fi C:\\Users\\username\\names.txt

    data of file
      name 1
      name 2
      etc...
  """)

    if not isdir(path_dest):
      mkdir(path_dest)

  def unloader(self):
    try:
      pafyNew = pafy.new(self.url_file)
      self.name_file = " ".join(re.sub(r"[^a-zA-Z0-9]", " ", pafyNew.title).split())
      self.name_unloader = f'{self.name_file}.{self.format_file}'
      self.path_unloader = f'{self.name_file}.{self.unloader_format}'

      self.dowloader_methods = {
        "mp3": pafyNew.getbestaudio(preftype=f'{self.unloader_format}'),
        "mp4": pafyNew.getbest(preftype=f'{self.unloader_format}'),
      }

      if isfile(join(self.path_file_dest, self.name_unloader)):
        print(f'\nFile with url: {self.url_file} and name: {self.name_file} already exist')
        return
      print(f"""\n===  Downloading  ===
> Name: {self.name_file}
> Format: {self.format_file}
> Url: {self.url_file} 
> Path_dest: {self.path_file_dest} \n
      """)
      unloader = self.dowloader_methods[self.format_file]
      unloader.download(f'{self.name_file}.{self.unloader_format}')
      if self.format_file == "mp3":
        self.convert_format()
      self.move_download()
      print("\nDownload completed...")
      system("cls")
      self.count_errors = 0
    except:
      self.count_errors += 1

      if self.count_errors == 4:
        self.count_errors = 0
        self.path_files_errors.append(f'{self.path_unloader}.part')
        system('cls')
        self.message_errors.append(f"""=== File could not be downloaded ===
> Name: {self.name_file}
> Url: {self.url_file}
> Format: {self.format_file} \n\n""")
        return
      system('cls')
      print(f'Error downloading trying again attempt {self.count_errors} of 3')
      self.unloader()

  def get_urls(self, data):
    urls = []
    for _, n in enumerate(data):
      print(f'Opting url of the song: {n}')
      url = VideosSearch(n, limit=1)
      urls.append(url.result()['result'][0]['link'])
    return urls

  def main(self):
    self.validate_args()
    url, file_names, format, path_dest = self.args

    self.format_file = format
    self.path_file_dest = path_dest
    self.unloader_format = self.unloader_extensions[self.format_file]

    if file_names != None and url == None:
      names = self.read_file(file_names)
      urls = self.get_urls(names)
      for i in range(len(urls)):
        self.url_file = urls[i]
        self.unloader()
      else:
          if len(self.message_errors) != 0:
            self.delete_files()
            self.write_log_error()
    else:
      self.url_file = url
      self.unloader()

if __name__ == '__main__':
  dw = Dowloader()
  dw.main()
