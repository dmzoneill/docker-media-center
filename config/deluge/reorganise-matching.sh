#!/bin/bash

# Re-run ./organise for each log whose contents match PATTERN.
# Usage: reorganise-matching.sh [--quiet] PATTERN
# --quiet discards the matching lines, matching grep redirected to /dev/null.

quiet=0
if [ "${1:-}" = "--quiet" ]; then
	quiet=1
	shift
fi

if [ "$#" -ne 1 ] || [ -z "$1" ]; then
	echo "usage: reorganise-matching.sh [--quiet] PATTERN" >&2
	exit 1
fi
pattern=$1

shopt -s nullglob
for logfile in logs/*; do
	if [ ! -f "$logfile" ]; then
		continue
	fi
	name=$(basename -- "$logfile")
	echo "$name"
	matched=0
	if [ "$quiet" -eq 1 ]; then
		if grep -e "$pattern" -- "$logfile" >/dev/null 2>&1; then
			matched=1
		fi
	elif grep -e "$pattern" -- "$logfile"; then
		matched=1
	fi
	if [ "$matched" -eq 1 ]; then
		details=$(grep -e "Torrent Details:" -- "$logfile")
		torrentid=$(echo "$details" | awk '{print $5}')
		torrentname=$(echo "$details" | awk '{print $3}')
		torrentpath=$(echo "$details" | awk '{print $4}')
		./organise "$torrentid" "$torrentname" "$torrentpath"
	fi
done
