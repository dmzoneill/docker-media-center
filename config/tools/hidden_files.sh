#!/bin/bash -x

IFS=$'\n'

for X in `find /music -type d -print`; do 
  cp -v .hidden $X/
done

for X in `find /series -type d -name "Season*" -print`; do 
  cp -v .hidden $X/
done

for X in `find /films -type d -print`; do 
  cp -v .hidden $X/
done
