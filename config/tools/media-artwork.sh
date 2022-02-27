#!/bin/bash
/tools/fixmedia.sh > media-artwork 2>&1
/usr/bin/python3 /tools/checker.py >> media-artwork 2>&1
/usr/bin/python3 /tools/series_checker.py >> media-artwork 2>&1
/usr/bin/python3 /tools/music_checker.py >> media-artwork 2>&1
/tools/hidden_files.sh >> media-artwork 2>&1
