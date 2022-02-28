# docker media center
<p align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/7/79/Docker_%28container_engine%29_logo.png" alt="alt text">
</p>

Docker Media Center Over OpenVPN

## Basic Overview

![Alt text](/doc/image/overview.png?raw=true "Overview")

# Getting started

## Configuration
You need to provide your files for config
```
mkdir sensitive
```

Filebot licence, openvpn config and jacket indexers
```
sensitive/
├── filebot.psm
├── Indexers
│   ├── eztv.json
│   ├── iptorrents.json
│   ├── limetorrents.json
│   ├── privatehd.json
│   ├── rarbg.json
│   ├── rutracker.json
│   ├── thepiratebay.json
│   ├── torrentview.json
│   ├── yts.json
│   ├── zooqle.json
└── vpn.conf
```

Update env file
```
vim .env
```

Generate an api key
```
# date | md5sum
2dfc7c419f222a1dc23c5af2787ae485
```

Update radarr, sonarr, lidarr keys
```
PUID=1000
PGID=1000
TZ=Europe/Dublin
PRIVATE_TRACKERS="stackoverflow.tech\|empirehost.me\|privatehd.to\|bgp.technology"
SONARR_KEY=2dfc7c419f222a1dc23c5af2787ae485
RADARR_KEY=2dfc7c419f222a1dc23c5af2787ae485
LIDARR_KEY=2dfc7c419f222a1dc23c5af2787ae485
JACKETT_KEY=2dfc7c419f222a1dc23c5af2787ae485
TRAKT_CLIENT_ID=
TRAKT_CLIENT_SECRET=
DELUGE_PASSWORD=deluge
SEED_SPEED=6507
GVFS_DATA_MUSIC=/smb/series/Entertainment/Music
GVFS_DATA_FILMS=/smb/films/Entertainment/Films
GVFS_DATA_SERIES=/smb/series/Entertainment/Series
GVFS_DATA_DOCUMENTARIES=/smb/series/Entertainment/Documentaries
```

Update the config
```
make update-config
```

### Storage Options
Option 1) Symlink
```
ls -s /path/to/films /films
ls -s /path/to/series /tv
ls -s /path/to/downloads /downloads
ls -s /path/to/documentaries /documentaries
ls -s /path/to/music /music
```

Option 2) Update docker-compose file
```
volumes:
  movies:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /films

  series:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /tv

  downloads:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /downloads

  documentaries:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /documentaries

  music:
    driver: local
    driver_opts:
      o: bind
      type: none
      device: /music
```

## Build
Build all the images
```
make build
```
## Launch
Bring it up
```
make up
```

## Fake seeder
Manage the fake seeder
```
make seedimage-reset
make seedimage-attach
```

## Port forwarding

You can use whatever ports you want externally, but internally all the services use 127.0.0.1 and their default port.
Changing the ports may required changes else where

TCP Ports
```
    ports:
      - 8112:8112     # deluge webui 
      - 55555:55555   # deluge thin-client
      - 3128:3128     # squid
      - 8118:8118     # privoxy
      - 6881:6881/udp # bittorrent
      - 9091:9091     # transmission webui 
      - 51413:51413   # transmission thin-client
      - 9117:9117     # jacket
      - 7878:7878     # radarr
      - 7879:7879     # documentaries
      - 8989:8989     # sonarr
      - 8090:80       # organizr
      - 8686:8686     # lidarr
      - 6767:6767     # bazarr
      - 8265:8265     # tdarr
      - 8266:8266     # tdarr
```

## Other services?
If you want transmision or rutorrent or other, change the replicas in the docker-compose file from 0 to 1
```
  rutorrent:
    container_name: rutorrent
    replicas: 0
    image: linuxserver/rutorrent:latest
    restart: unless-stopped
    network_mode: service:vpn # run on the vpn network
    env_file: .env
    volumes:
      - downloads:/downloads # downloads folder
      - ./config/rutorrent:/config # config files
```

## Deluge organise
![Alt text](/doc/image/organise.png?raw=true "Overview")

### Deluge client integration
Install deluge plugin for filebot integration
```
make install-plugin
```

### Organise script
Inside the docker folder you can find the filebot sorter script.
You must have a filebot license installed for it to work

```
config/deluge/organise
```

### Enable the FBlocation column
![Alt text](/doc/image/fblocation.png?raw=true "Overview")
