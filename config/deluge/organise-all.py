import requests
import subprocess
from pprint import pprint

# Deluge API endpoint
deluge_endpoint = "http://127.0.0.1:8112/json"

# Function to execute the 'organise' bash file with arguments
def execute_organise_bash(hash_value, name, download_location):
    command = ['./organise', hash_value, name, download_location]
    subprocess.call(command)

# Create a session object
session = requests.session()

# Login to Deluge
login_response = session.post(deluge_endpoint, json={
    "id": 1,
    "method": "auth.login",
    "params": ["deluge"]
})

# Check if the login was successful
if login_response.status_code == 200:
    # Get the list of torrents from Deluge
    torrents_response = session.post(deluge_endpoint, json={
        "method": "core.get_torrents_status",
        "params": [
            {},
            [
                "hash",
                "name",
                "download_location",
                "state"
            ]
        ],
        "id": 1
    })

    # Check if the request was successful
    if torrents_response.status_code == 200:
        pprint(torrents_response.json())
        torrents = torrents_response.json()["result"]

        # Iterate over completed torrents
        for key in torrents.keys():
            hash_value = torrents[key]['hash']
            name = torrents[key]['name']
            download_location = torrents[key]['download_location']

            # Execute the 'organise' bash file with arguments
            execute_organise_bash(hash_value, name, download_location)
    else:
        print("Error: Unable to retrieve torrents from Deluge.")
else:
    print("Error: Unable to login to Deluge.")