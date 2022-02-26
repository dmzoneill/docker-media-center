#!/bin/bash

ENDPOINT="http://127.0.0.1:8112/json"

curl -c cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"method\": \"auth.login\", \"params\": [\"$DELUGE_PASSWORD\"], \"id\": 1}" http://127.0.0.1:8112/json >/dev/null 2>&1
curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "web.connected", "params": [], "id": 1}' $ENDPOINT > /dev/null
RES=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_session_state", "params": [], "id": 1}' $ENDPOINT)

echo $RES | jq -r '.result | .[]' | while read i; do
    tracker=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_torrent_status", "params": ["'$i'",["tracker_host"]], "id": 1}' $ENDPOINT)
    echo $tracker | grep $PRIVATE_TRACKERS >/dev/null 2>&1
    if [ "$?" == "1" ]; then
       echo $i
    fi       
done

