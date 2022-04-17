#!/usr/bin/env python3
import os
import signal
from plexapi.server import PlexServer

def handler(signum, frame):
    print("Timed out")
    raise Exception("Server timed out")

def optimize_library_call():
    baseurl = 'http://127.0.0.1:32400'
    token = os.environ.get('PLEX_TOKEN')
    plex = PlexServer(baseurl, token, None, 4)
    plex.library.optimize()

signal.signal(signal.SIGALRM, handler)
signal.alarm(3)

try:
    optimize_library_call()
except Exception as exc:
    print(exc)

    