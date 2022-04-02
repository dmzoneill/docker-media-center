#!/bin/bash

torrentid=$1

curl -c cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"method\": \"auth.login\", \"params\": [\"$DELUGE_PASSWORD\"], \"id\": 1}" http://127.0.0.1:8112/json >/dev/null 2>&1
curl -b cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "web.connected", "params": [], "id": 1}' http://127.0.0.1:8112/json >/dev/null 2>&1

result=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_torrent_status", "params": ["'$torrentid'",["active_time", "label", "tracker_host"]], "id": 1}' http://127.0.0.1:8112/json)

sleep 15

runtime=$(echo $result | grep -oE "\d+" | head -n 1)
runleft=$((1209600 - $runtime))

echo $runleft

