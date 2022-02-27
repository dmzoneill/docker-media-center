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
