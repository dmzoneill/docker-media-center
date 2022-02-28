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

## Build
Build all the images
```
make build
```

## Storage Options
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

## Launch
Bring it up
```
make up
```

## Deluge client integration
Install deluge plugin for filebot integration
```
make install-plugin
```

## Fake seeder
Manage the fake seeder
```
make seedimage-reset
make seedimage-attach
```

## Port forwarding
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
