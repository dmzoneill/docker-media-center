#!/bin/bash

IFS=$'\n'

function make_thumb {
   echo $1;
   uri=$(echo "$1" | perl -MURI::file -e 'print URI::file->new(<STDIN>)');
   echo $uri
   SUM=$(echo -n "$uri" | md5sum | awk '{print $1}')
   echo $SUM
   cover-thumbnailer "$1" /thumbnails/large/$SUM.png
   echo /thumbnails/large/$SUM.png
   xdg-open /thumbnails/large/$SUM.png
}

function make_thumbs {
  cd $1
  for X in `ls`; do
   echo $X;
   uri=$(echo "$1/$X" | perl -MURI::file -e 'print URI::file->new(<STDIN>)');
   echo $uri
   SUM=$(echo -n "$uri" | md5sum | awk '{print $1}')
   echo $SUM
   if [ ! -f /thumbnails/large/$SUM.png ]; then
     cover-thumbnailer "$1/$X" /thumbnails/large/$SUM.png
   fi
   if [ $1 == "/series" ]; then
     cd $1/$X/
     for Y in `ls -d */`; do
       echo $Y;
       uri=$(echo "$1/$X/$Y" | perl -MURI::file -e 'print URI::file->new(<STDIN>)');
       echo $uri
       SUM=$(echo -n "$uri" | md5sum | awk '{print $1}')
       echo $SUM
       if [ ! -f /thumbnails/large/$SUM.png ]; then
         cover-thumbnailer "$1/$X/$Y" /thumbnails/large/$SUM.png
       fi
     done
     cd $1
   fi
  done
}

if [ $# -eq 1 ]; then
  make_thumb "$1"
else
  make_thumbs /series
  make_thumbs /films
fi


