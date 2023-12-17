#!/bin/bash

# Directory containing the files
directory="logs"

# Loop through the files in the directory
for file in "$directory"/organise-*.log; do
  # Extract the sha1sum from the filename
  sha1sum=$(basename "$file" | sed 's/organise-\(.*\)\.log/\1/')

  # Check if the file contains the specified string
  if grep -q "is an exact copy and already exists" "$file"; then
    # Use curl to delete the torrent from Deluge
    echo "I'd delete $sha1sum"
    curl -v -b /config/cookies.txt --compressed -X POST "http://127.0.0.1:8112/json" \
     -d '{"method": "core.remove_torrent", "params": ["'$sha1sum'", true], "id": 1}' \
     -H "Content-Type: application/json"
  fi
done