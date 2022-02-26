#!/bin/bash -x
cd /config/seedmage/
screen -wipe
screen -S seedmage -d -m python3 seedmage.py
screen -list