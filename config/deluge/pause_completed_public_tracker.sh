#!/bin/bash -x

torrentid=$1

if [ -d "/home/dave/src/docker-media-center/config/deluge/" ]; then
   cd /home/dave/src/docker-media-center/config/deluge/
else
  cd /config
fi

curl -c cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"method\": \"auth.login\", \"params\": [\"$DELUGE_PASSWORD\"], \"id\": 1}" http://127.0.0.1:8112/json


function pause {
   curl -s -b cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.pause_torrent", "params": ["'$1'"], "id": 1}' http://127.0.0.1:8112/json 
}

function getstate {
    res=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_torrent_status", "params": ["'$1'",["state"]], "id": 1}' http://127.0.0.1:8112/json | jq -r '.result | .state')
}

function gettracker {
    res=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_torrent_status", "params": ["'$1'",["tracker_host"]], "id": 1}' http://127.0.0.1:8112/json | jq -r '.result | .tracker_host')
}

if [ "$torrentid" == "" ]; then
  ids=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_torrents_status", "params": [[],[]], "id": 1}' http://127.0.0.1:8112/json | jq -r '.result | keys | .[]')
  for X in $ids; do
    getstate $X

    if [ "$res" != "Seeding" ]; then
      continue
    fi

    gettracker $X  

    echo "$res" | grep $PRIVATE_TRACKERS >/dev/null 2>&1
    if [ "$?" == "1" ]; then
        pause $X
    fi
  done
else

  getstate $torrentid

  if [ "$res" != "Seeding" ]; then
    exit 0
  fi

  gettracker $torrentid 

  echo "$res" | grep $PRIVATE_TRACKERS >/dev/null 2>&1
  if [ "$?" == "1" ]; then
    pause $torrentid
  fi

fi