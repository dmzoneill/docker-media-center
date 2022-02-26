#!/usr/bin/python3

import cv2
import os

okay = ['mkv', 'mpg', 'avi', 'mpeg']

for dirpath, dirs, files in os.walk("/tv"):
    path = dirpath.split('/')

    for f in files:
        parts = f.split(".")
        end = parts[len(parts)-1]
        if end.lower() in okay:
            print(dirpath + "/" + f)
            vid = cv2.VideoCapture(dirpath + "/" + f)
            height = vid.get(cv2.CAP_PROP_FRAME_HEIGHT)
            width = vid.get(cv2.CAP_PROP_FRAME_WIDTH)       
            print('cv2.CAP_PROP_FRAME_WIDTH :', width)
            print('cv2.CAP_PROP_FRAME_HEIGHT:', height)