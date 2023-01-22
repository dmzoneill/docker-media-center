import urllib.request
import requests
import os
import sys
import platform
import shutil
import pickle
from pprint import pprint

dont_touch_torrents = ['localhost.stackoverflow.tech', 'ssl.empirehost.me', 'routing.bgp.technology', 'stackoverflow.tech', 'empirehost.me']
best_trackers_ips = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best_ip.txt"
best_trackers_newtrackton = "https://newtrackon.com/api/stable"
trackers = ""
newtrackton = ""

headers = {
    'authority': 'newtrackon.com',
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-language': 'en-GB,en-US;q=0.9,en;q=0.8',
    'cache-control': 'no-cache',
    'dnt': '1',
    'pragma': 'no-cache',
    'sec-ch-ua': '"Google Chrome";v="105", "Not)A;Brand";v="8", "Chromium";v="105"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Linux"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36',
}

newtrackton = requests.get('https://newtrackon.com/api/stable', headers=headers).text

with urllib.request.urlopen(best_trackers_ips) as f:
    trackers = f.read().decode('utf-8')

state_file_path = os.path.expanduser('state/torrents.state')
state_file = open(state_file_path, 'rb')
state = pickle.load(state_file)
state_file.close()

state_modified = False
for torrent in state.torrents:
    print(torrent.name)
    torrent_tracker_urls = ""
    for trk in torrent.trackers:
        torrent_tracker_urls += trk['url'] + ","

    if not any(x in torrent_tracker_urls for x in dont_touch_torrents):
        for tracker in newtrackton.splitlines():
            if tracker.strip() == "":
                continue
            if tracker not in torrent.trackers:
                torrent.trackers.append(
                    {
                        'complete_sent': False,
                        'endpoints': [],
                        'fail_limit': 0,
                        'fails': 0,
                        'last_error': {'category': '', 'value': 0},
                        'message': '',
                        'min_announce': None,
                        'next_announce': None,
                        'scrape_complete': 0,
                        'scrape_downloaded': 0,
                        'scrape_incomplete': 0,
                        'send_stats': False,
                        'source': 4,
                        'start_sent': False,
                        'tier': 4,
                        'trackerid': '',
                        'updating': False,
                        'url': tracker,
                        'verified': False
                    }
                )
                print("add " + tracker + " to torrent")
                state_modified = True
    else:
        print("skip")


# if state_modified:
#     shutil.copyfile(state_file_path, state_file_path + '.old')
#     state_file = open(state_file_path, 'wb')
#     pickle.dump(state, state_file)
#     state_file.close()
#     print("State Updated")
# else:
#     print("Nothing to do")