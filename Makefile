.PHONY: build build-images up down check clean clean-mounts backup-diff backup-config update-config reset seedmage-reset seedmage-attach

SHELL := /bin/bash
CWD := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

clean-mounts:
	{ \
		for X in `mount | grep merged | awk '{print $3}'`; do \
			sudo umount $$X; \
		done \
	}

build-images:
	- cp sensitive/filebot.psm config/deluge/
	- cp sensitive/filebot.psm config/tools/
	- docker-compose build
	- rm -f config/deluge/filebot.psm
	- rm -f config/tools/filebot.psm

build: build-images clean-mounts

up: build
	- cp sensitive/.env .env
	cp -vf sensitive/Indexers/* ./config/jackett/Jackett/Indexers/
	cp -vf sensitive/vpn.conf config/vpn/
	docker-compose up -d
	docker exec -it vpn /vpn/port-forward.sh
	docker exec -it deluge /config/seedmage/seedmage.sh
	- cp sensitive/.env.template .env
	- cp sensitive/filebot.psm config/deluge/
	- docker exec -it deluge su abc -c "filebot --license /config/filebot.psm"
	- rm -f config/deluge/filebot.psm

down: 
	docker-compose down

check:
	docker-compose config

clean: down
	- rm -rvf config/deluge/.cache
	- rm -rvf config/deluge/.filebot
	- rm -rvf config/deluge/.java
	- rm -rvf config/deluge/archive
	- rm -rvf config/deluge/icons
	- rm -rvf config/deluge/logs/*
	- rm -rvf config/deluge/seedmage/state/*
	- rm -vf config/deluge/cookies.txt
	- find . -type d -name "__pycache__" -exec rm -rf {} \;
	- find config/deluge/seedmage/torrents/ -regextype posix-egrep -regex '.*/[0-9a-zA-Z]{40}\.torrent' -delete
	- docker system prune -a -f

backup-diff:
	- diff config/deluge/seedmage/seed_speed_file config/deluge/seedmage/seed_speed_file.bak
	- diff config/deluge/auth config/deluge/auth.bak
	- diff config/documentaries/config.xml config/documentaries/config.xml.bak
	- diff config/radarr/config.xml config/radarr/config.xml.bak
	- diff config/sonarr/config.xml config/sonarr/config.xml.bak
	- diff config/lidarr/config.xml config/lidarr/config.xml.bak
	- diff config/jackett/Jackett/ServerConfig.json config/jackett/Jackett/ServerConfig.json.bak
	- diff config/traktarr/config.json config/traktarr/config.json.bak

backup-config:
	- cp -vf config/deluge/seedmage/seed_speed_file config/deluge/seedmage/seed_speed_file.bak
	- cp -vf config/deluge/auth config/deluge/auth.bak
	- cp -vf config/documentaries/config.xml config/documentaries/config.xml.bak
	- cp -vf config/radarr/config.xml config/radarr/config.xml.bak
	- cp -vf config/sonarr/config.xml config/sonarr/config.xml.bak
	- cp -vf config/lidarr/config.xml config/lidarr/config.xml.bak
	- cp -vf config/jackett/Jackett/ServerConfig.json config/jackett/Jackett/ServerConfig.json.bak
	- cp -vf config/traktarr/config.json config/traktarr/config.json.bak

update-config: backup-config
	- cp sensitive/.env .env
	{ \
		set -e ;\
		set -x ;\
		source .env; \
		echo $$SEED_SPEED > config/deluge/seedmage/seed_speed_file; \
		sed "s#deluge.*#deluge:$$DELUGE_PASSWORD:10#g" -i config/deluge/auth; \
		sed "s#<ApiKey>.*</ApiKey>#<ApiKey>$$RADARR_KEY</ApiKey>#g" -i config/documentaries/config.xml; \
		sed "s#<ApiKey>.*</ApiKey>#<ApiKey>$$RADARR_KEY</ApiKey>#g" -i config/radarr/config.xml; \
		sed "s#<ApiKey>.*</ApiKey>#<ApiKey>$$SONARR_KEY</ApiKey>#g" -i config/sonarr/config.xml; \
		sed "s#<ApiKey>.*</ApiKey>#<ApiKey>$$LIDARR_KEY</ApiKey>#g" -i config/lidarr/config.xml; \
		sed "s#\"APIKey\": \".*\",#\"APIKey\": \"$$JACKETT_KEY\",#g" -i config/jackett/Jackett/ServerConfig.json; \
		sed "s#\"api_key\": \".*\",#\"api_key\": \"$$SONARR_KEY\",#g" -i config/traktarr/config.json; \
		sed "s#\"client_id\": \".*\",#\"client_id\": \"$$TRAKT_CLIENT_ID\",#g" -i config/traktarr/config.json; \
		sed "s#\"client_secret\": \".*\",#\"client_secret\": \"$$TRAKT_CLIENT_SECRET\",#g" -i config/traktarr/config.json; \
	}
	- cp sensitive/.env.template .env

reset: clean update-config up

seedmage-reset:
	- docker exec -it deluge killall -9 screen
	- docker exec -it deluge screen -wipe
	- find config/deluge/seedmage/torrents/ -regextype posix-egrep -regex '.*/[0-9a-zA-Z]{40}\.torrent' -delete
	- rm -rvf config/deluge/seedmage/state/*
	- docker exec -it deluge /config/seedmage/seedmage.sh

seedmage-attach:
	- docker exec -it deluge screen -rd seedmage

install-plugin:
	- mkdir -vp ~/.config/deluge/plugins/
	- echo ${CWD}/config/deluge/DelugeOrganise > ~/.config/deluge/plugins/DelugeOrganise.egg-link