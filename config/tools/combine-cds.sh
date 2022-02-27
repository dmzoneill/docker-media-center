#!/bin/bash

IFS=$'\n'

function combine {
   cd "$1"
   pwd
   
   PARTS=$(find . -name "*CD*" -type f -print | grep ".*\.(avi\|mkv\|mp4\|m4v\|mpg)" | sort)
   COUNTER=1
   echo "#ignored" > parts.txt

   for P in $PARTS; do
     mv -v "$P" "$1/$COUNTER.mkv" 
     echo "file '$COUNTER.mkv'" >> parts.txt
     COUNTER=$[$COUNTER +1]
   done

   ffmpeg -f concat -safe 0 -i parts.txt -c copy output.mkv
   mv -v output.mkv "$(basename "$1").mkv"
   
   echo xdg-open "$1/$(basename "$1").mkv"
   cat parts.txt
   rm parts.txt
}

if [ $# -eq 1 ]; then
  combine "$1"
fi

