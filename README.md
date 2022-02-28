# docker media center

## Basic Overview

![Alt text](/doc/image/overview.png?raw=true "Overview")

# Getting started

## Configuration
You need to provide your files for config
```
mkdir sensitive
mkdir sensitive/Indexers (your jacket indexers)
touch sensitive/vpn.conf (open vpn config)
```

Update env file
```
vim .env
```

## Build and launch
Build all the images
```
make build
```

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
