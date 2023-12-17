DELUGE_URL="http://127.0.0.1:8112"

# Iterate over files in the directory
for file in logs/organise-*.log; do
    # Extract the SHA1 hash from the filename
    sha1sum=$(echo "$file" | sed -n 's/organise-\(.*\)\.log/\1/p')

    # Check if the SHA1 hash exists in Deluge torrents
    response=$(curl -v -b /config/cookies.txt --compressed -s "$DELUGE_URL/json" -X POST -d '[{"method":"webapi.get_torrents", "params": [], "id": 1}]')

    if ! echo "$response" | grep -q "$sha1sum"; then
        # SHA1 hash doesn't exist in Deluge torrents, delete the file
        echo "Deleting file: $file"
        rm "$file"
    fi
done