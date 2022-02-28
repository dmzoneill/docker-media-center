# docker media center

## Basic Overview

![Alt text](/doc/image/overview.png?raw=true "Overview")

## Getting started

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

Build all the images
```
make build
```

Bring it up
```
make up
```

Install deluge plugin for filebot integration
```
make install-plugin
```

Manage the fake seeder
```
make seedimage-reset
make seedimage-attach
```

All targets
```
clean-mounts:
build-images:
build: build-images clean-mounts
up: build
down: 
check:
clean: down
backup-diff:
backup-config:
update-config: backup-config
reset: clean update-config up
seedmage-reset:
seedmage-attach:
install-plugin:
```

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
