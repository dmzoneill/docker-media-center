#!/bin/bash

for X in `ls logs/`; do
  pcregrep -M "\nFilebot\n=======\n\n\n\n" logs/$X > /dev/null 2>&1
 
  if [ $? == 0 ]; then
    echo $X
    details=$(grep "Torrent Details:" logs/$X | tail -n 1)
    echo $details
    details=$(echo $details | awk -F':' '{print $2}')
    echo $details
    torrentid=$(echo $details | awk '{print $NF}')
    torrentname=$(echo $details | awk -F'/' '{print $1}')
    torrentpath=$(echo $details | awk '{print $(NF-1)}')
    ./organise "$torrentid" "$torrentname" "$torrentpath"
    echo ""
  fi
done
