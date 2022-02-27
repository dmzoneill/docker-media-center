#!/usr/bin/env python3
import subprocess
from difflib import SequenceMatcher
from youtubesearchpython import VideosSearch
from pprint import pprint
import requests
import urllib.parse
import os
import sys
import eyed3

endpoint="http://127.0.0.1:8686"
api_key=os.getenv('LIDARR_KEY')


def similar(a, b):
    return SequenceMatcher(None, a, b).ratio()


def rescan(path):
    data = {
        'name': 'RescanFolders',
        'folders': [path]
    }
    response = requests.post(endpoint + "/api/v1/command", json=data, headers={"X-Api-Key":api_key})
    data = {
        'name': 'DownloadedAlbumsScan',
        'path': path,
        'folders': [path]
    }
    response = requests.post(endpoint + "/api/v1/command", json=data, headers={"X-Api-Key":api_key})

def update_id3tag(artistName, albumName, title, trackNumber):
    path = "/music/" + artistName + "/" + albumName
    filePath = path + "/" + artistName + " - " + albumName + " - " + title + ".mp3"

    rename_command = "mid3v2 -v"
    rename_command += " -a \"" + artistName.replace('"','\\"') + "\""
    rename_command += " -A \"" + albumName.replace('"','\\"') + "\""
    rename_command += " -t \"" + title.replace('"','\\"') + "\""
    rename_command += " -T \"" + trackNumber + "\""
    rename_command += " \"{trackname}\""
    rename_command = rename_command.format(trackname=filePath.replace('"','\\"'))

    proc = subprocess.Popen(rename_command, shell=True, stdout=subprocess.PIPE)
    proc.wait()
    pprint(proc.stdout.read().decode("utf8"))


def update_mp3tag(artistName, albumName, title, trackNumber):
    path = "/music/" + artistName + "/" + albumName
    filePath = path + "/" + artistName + " - " + albumName + " - " + title + ".mp3"
    try:
        audiofile = eyed3.load(filePath)
        try:
            if audiofile.tag.artist == None or audiofile.tag.artist == "":
                pass
        except:
            audiofile.initTag()
            audiofile.tag.artist = artistName
            audiofile.tag.album = albumName
            audiofile.tag.title = title
            audiofile.tag.track_num = trackNumber
            audiofile.tag.save()
            print("Tag updated")
    except:
        os.remove(filePath)


def get_song(artistName, albumName, title, trackNumber):
    best = 0
    bestLink = ""
    searchFor = artistName + " - " + title
    path = "/music/" + artistName + "/" + albumName
    filePath = path + "/" + artistName + " - " + albumName + " - " + title + ".mp3"

    if os.path.exists(filePath):
        update_mp3tag(artistName, albumName, title, trackNumber)
        rescan(path)
        return

    videosSearch = VideosSearch(searchFor)

    for song in videosSearch.result()['result']:
        if similar(searchFor, song['title']) > best:
            best = similar(searchFor, song['title'])
            bestLink = song['link']

    print("Best: " + str(best))

    if best < 0.7:
        print("Unable to find " + searchFor)
        return

    isExist = os.path.exists(path)
    if not isExist:
        os.makedirs(path)

    downloader = "youtube-dl --no-progress -x --audio-format mp3 \"{link}\" -o \"{trackname}\"".format(link=bestLink, trackname=filePath.replace('"','\\"'))
    print(downloader)

    proc = subprocess.Popen(downloader, shell=True, stdout=subprocess.PIPE)
    proc.wait()

    if proc.returncode == 0:
        update_mp3tag(artistName, albumName, title, trackNumber)
        print("Downloaded successfully")
        # pprint(proc.stdout.read().decode("utf8"))
        rescan(path)
        

def get_missing():
    response = requests.get(endpoint + "/api/v1/wanted/missing?page=0&pageSize=500", headers={"X-Api-Key":api_key})
    if response.status_code == 200:
        json = response.json()

        for missing in json['records']:
            resp = requests.get(endpoint + "/api/v1/track?artistid=" + str(missing['artist']['id'])  + "&albumid=" + str(missing['id']), headers={"X-Api-Key":api_key})
            if resp.status_code == 200:
                jsonb = resp.json()

                print("="*120)
                print(missing['title'])
                print(missing['artist']['path'])
                print(missing['artist']['artistName'])

                for track in jsonb:
                    get_song(missing['artist']['artistName'], missing['title'], track['title'], track['trackNumber'])
    

if __name__ == "__main__":
    get_missing()
