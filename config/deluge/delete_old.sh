#!/bin/bash -x

echo "============================================================"
echo "======================= DELETE_OLD ========================="
echo "============================================================"
echo ""
echo $DELUGE_PASSWORD

curl -c cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"method\": \"auth.login\", \"params\": [\"$DELUGE_PASSWORD\"], \"id\": 1}" http://127.0.0.1:8112/json
ids=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_torrents_status", "params": [[],[]], "id": 1}' http://127.0.0.1:8112/json | jq -r '.result | keys | .[]')

function delete {
   curl -b cookies.txt --compressed -i -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.remove_torrent", "params": ["'$1'",true], "id": 1}' http://127.0.0.1:8112/json 
}


for X in $ids; do
  left=$(./get_added_time.sh $X)
  if [ $left -lt 0 ]; then
    if [ -f "logs/organise-$X.log" ]; then
      grep "\[COPY\]" logs/organise-$X.log >/dev/null 2>&1
      if [ "$?" == "0" ]; then 
        echo "delete $X"     
        delete $X 
      fi
    else
      echo "delete $X"    
      delete $X
    fi 
  else
    tracker=$(curl -s -b cookies.txt --compressed -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d '{"method": "core.get_torrent_status", "params": ["'$X'",["tracker_host"]], "id": 1}' http://127.0.0.1:8112/json)
    echo $tracker | grep $PRIVATE_TRACKERS >/dev/null 2>&1
    if [ "$?" == "1" ]; then
      grep "\[COPY\]" logs/organise-$X.log >/dev/null 2>&1
      if [ "$?" == "0" ]; then
        echo $i
	      delete $X
      fi
    else
      echo "not time to delete $X : $left"
    fi
  fi	  
done

echo ""
echo ""