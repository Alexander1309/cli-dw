import argparse
import re
import shutil
from os import mkdir, remove
from os.path import abspath, isdir, isfile, join

import moviepy.editor as mp
import pafy
from youtubesearchpython import VideosSearch

parser = argparse.ArgumentParser()
parser.add_argument('--url', '-u')
parser.add_argument('--names', '-n')
parser.add_argument('--format', '-f')
parser.add_argument('--path-dest', '-pd')
args = list(vars(parser.parse_args()).values())

count = 0


def move_file(name, path):
    shutil.move(abspath('./{0}'.format((name))), path)


def dowload_audio(url, path, fromat):
    global count
    try:
        pafyNew = pafy.new(url)
        parser_name = " ".join(
            re.sub(r"[^a-zA-Z0-9]", " ", pafyNew.title).split())
        name_audio = f'{parser_name}.{fromat}'
        path_audio = abspath(f'{parser_name}.m4a')
        if isfile(join(path, name_audio)):
            print(
                f'\nFile with url: {url} and name: {name_audio} already exist')
            return
        print(f'\nDownloading url: {url} name: {name_audio}')
        video = pafyNew.getbestaudio(preftype='m4a')
        video.download(f'{parser_name}.m4a')
        audio_m4a = mp.AudioFileClip(path_audio)
        audio_m4a.write_audiofile(name_audio, bitrate="320k")
        audio_m4a.close()
        remove(path_audio)
        move_file(name_audio, path)
        count = 0
    except:
        count += 1
        if count == 4:
            count = 0
            print(f'\nFile with url: {url} could not be downloaded')
            return
        print('Dowload error trying again...')
        dowload_audio(url, path, fromat)


def dowload_mp4(url, path, format):
    global count
    try:
        pafyNew = pafy.new(url)
        name = f'{pafyNew.title}.mp4'
        if isfile(join(path, name)):
            print(f'\nFile with url: {url} and name: {name} already exist')
            return
        print(f'\nDownloading url: {url} name: {name}')
        video = pafyNew.getbest(preftype='mp4')
        video.download()
        move_file(name, path)
        count = 0
    except:
        count += 1
        if count == 4:
            count = 0
            print(f'\nFile with url: {url} could not be downloaded')
            return
        print('Dowload error trying again...')
        dowload_mp4(url, path, format)


formats = {
    'audio': dowload_audio,
    'mp4': dowload_mp4
}


def read_file(path):
    readData = []
    with open(path, 'r') as file:
        readFile = file.readlines()
        for _, read in enumerate(readFile):
            readData.append(read.strip('\n').strip('\t'))
    return readData


def validations(args):
    print('Validating...')
    url, file_names, format, path_dest = args
    if not format in {'mp3', 'ogg', 'wav', 'mp4'}:
        raise OSError(
            'Fromat is invalid... formats valids: mp3, wav, ogg, mp4')

    if path_dest == None:
        raise OSError(
            'Destination path cannot be empty please add the path with the command --path-dest or -pd')

    if file_names != None and url == None and not isfile(file_names):
        raise OSError("""The path of the names file is invalid or does not exist please
    check the path or the name file format should be .txt
      
    example:
      -fu C:\\Users\\username\\names.txt

      data of file
        name 1
        name 2
        etc...
  """)

    if not isdir(path_dest):
        mkdir(path_dest)


def get_urls(data):
    urls = []
    for _, n in enumerate(data):
        print(f'Opting url of the song: {n}')
        url = VideosSearch(n, limit=1)
        urls.append(url.result()['result'][0]['link'])
    return urls


def main():
    validations(args)
    url, file_names, extension, path_dest = args
    format = 'mp4'
    if extension in {'mp3', 'ogg', 'wav'}:
        format = 'audio'

    if url != None and file_names == None:
        formats[format](url, path_dest, extension)
    elif file_names != None and url == None:
        names = read_file(file_names)
        urls = get_urls(names)
        for i in range(len(urls)):
            formats[format](urls[i], path_dest, extension)


if __name__ == '__main__':
    main()
