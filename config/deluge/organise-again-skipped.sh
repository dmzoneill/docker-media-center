#!/bin/bash

for X in `ls logs/`; do
  echo $X;
  grep Skipped logs/$X
 
  if [ $? == 0 ]; then
    details=$(grep "Torrent Details:" logs/$X)
    torrentid=$(echo $details | awk '{print $5}')
    torrentname=$(echo $details | awk '{print $3}')
    torrentpath=$(echo $details | awk '{print $4}')
    ./organise "$torrentid" "$torrentname" "$torrentpath"
  fi
done
