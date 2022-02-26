#!/bin/bash
for X in `grep "Torrent Details" logs/organise* | awk '{print $5}' | grep -x '.\{20,60\}'`; do 
  curl -c cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"method\": \"auth.login\", \"params\": [\"$DELUGE_PASSWORD\"], \"id\": 1}" http://127.0.0.1:8112/json
  curl -b cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "web.connected", "params": [], "id": 1}' http://127.0.0.1:55556/json
  curl -b cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.remove_torrent", "params": ["'$X'",false], "id": 1}' http://127.0.0.1:55556/json
done

