import urllib.request
import os
import sys
import platform
import shutil
import pickle
from pprint import pprint

dont_touch_torrents = ['localhost.stackoverflow.tech', 'ssl.empirehost.me', 'routing.bgp.technology', 'stackoverflow.tech', 'empirehost.me']
best_trackers_ips = "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best_ip.txt"
trackers = ""

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
        for tracker in trackers.splitlines():
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