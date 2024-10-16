.PHONY: build build-images up down check clean clean-mounts backup-diff backup-config update-config reset seedmage-reset seedmage-attach

SHELL := /bin/bash
CWD := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
THIS_FILE := $(lastword $(MAKEFILE_LIST))
WHOAMI := $(shell whoami)

ifeq ($(dmc),)
    $(error Please set the 'dmc' variable to either 'docker' or 'podman')
endif

ifeq ($(dmc),docker)
    CONTAINER_TOOL = docker
    COMPOSE_TOOL = docker-compose
	COMPOSE_FILE = docker-compose.yaml
	COMPOSE_ARGS = 
else ifeq ($(dmc),podman)
    CONTAINER_TOOL = podman
    COMPOSE_TOOL = podman-compose
	COMPOSE_FILE = podman-compose.yaml
	COMPOSE_ARGS = --prod-args ' --uidmap "+1000:@1000" --gidmap "+g1000:1000"'
else
    $(error Invalid value for dmc. Use 'docker' or 'podman')
endif

clean-mounts:
	- { \
		for X in `mount | grep merged | awk '{print $3}'`; do \
			sudo umount $$X; \
		done \
	}
	sudo chown -R ${WHOAMI}:${WHOAMI} config/*

build-images:
	- ${COMPOSE_TOOL} -f ${COMPOSE_FILE} build

build: build-images clean-mounts

up: build
	- cp sensitive/.env .env
	cp -vf sensitive/Indexers/* ./config/jackett/Jackett/Indexers/
	cp -vf sensitive/airvpn.conf config/vpn/
	cp -vf sensitive/vpn.conf config/vpn/
	${COMPOSE_TOOL} ${COMPOSE_ARGS} -f ${COMPOSE_FILE} up -d
	${CONTAINER_TOOL} exec -it vpn /vpn/port-forward.sh
	${CONTAINER_TOOL} exec -it deluge /config/seedmage/seedmage.sh
	- cp sensitive/.env.template .env
	$(MAKE) -f ${THIS_FILE} filebot-update-opensubtitles
	if [ ! -d "./home/.filebot" ]; then \
		$(MAKE) -f ${THIS_FILE} filebot-update-license; \
	fi

filebot-update-license:
	- cp sensitive/filebot.psm config/deluge/
	- ${CONTAINER_TOOL} exec -it deluge su ubuntu -c "filebot --license /config/filebot.psm"
	- ${CONTAINER_TOOL} exec -it deluge chmod 775 /data/.filebot
	- ${CONTAINER_TOOL} exec -it deluge chown -R ubuntu:ubuntu /data/.filebot
	- rm -f config/deluge/filebot.psm

filebot-update-opensubtitles:
	- cp sensitive/filebot-opensubtitles config/deluge/fbprefs.xml
	- ${CONTAINER_TOOL} exec -it deluge su ubuntu -c "mkdir -vp /data/.java/.userPrefs/net/filebot/login/"
	- ${CONTAINER_TOOL} exec -it deluge su ubuntu -c "cp -vf /config/fbprefs.xml /data/.java/.userPrefs/net/filebot/login/prefs.xml"
	- rm -f config/deluge/fbprefs.xml 

down: 
	${COMPOSE_TOOL} -f ${COMPOSE_FILE} down
	sudo chown -R ${WHOAMI}:${WHOAMI} config/*

check:
	${COMPOSE_TOOL} -f ${COMPOSE_FILE} config

clean: down
	- sudo rm -rvf config/deluge/.cache
	- sudo rm -rvf config/deluge/.filebot
	- rm -rvf config/deluge/.java
	- rm -rvf config/deluge/archive
	- rm -rvf config/deluge/icons
	- rm -rvf config/deluge/logs/*
	- rm -rvf config/deluge/seedmage/state/*
	- rm -rvf config/deluge/cookies.txt
	- sudo find . -type d -name "__pycache__" -exec sudo rm -rf {} \;
	- find config/deluge/seedmage/torrents/ -regextype posix-egrep -regex '.*/[0-9a-zA-Z]{40}\.torrent' -delete
	- ${CONTAINER_TOOL} system prune -a -f

backup-diff:
	- diff config/deluge/seedmage/seed_speed_file config/deluge/seedmage/seed_speed_file.bak
	- diff config/deluge/auth config/deluge/auth.bak
	- diff config/documentaries/config.xml config/documentaries/config.xml.bak
	- diff config/radarr/config.xml config/radarr/config.xml.bak
	- diff config/sonarr/config.xml config/sonarr/config.xml.bak
	- diff config/lidarr/config.xml config/lidarr/config.xml.bak
	- diff config/readarr/config.xml config/readarr/config.xml.bak
	- diff config/jackett/Jackett/ServerConfig.json config/jackett/Jackett/ServerConfig.json.bak
	- diff config/traktarr/config.json config/traktarr/config.json.bak

backup-config:
	- cp -vf config/deluge/seedmage/seed_speed_file config/deluge/seedmage/seed_speed_file.bak
	- cp -vf config/deluge/auth config/deluge/auth.bak
	- cp -vf config/documentaries/config.xml config/documentaries/config.xml.bak
	- cp -vf config/radarr/config.xml config/radarr/config.xml.bak
	- cp -vf config/sonarr/config.xml config/sonarr/config.xml.bak
	- cp -vf config/lidarr/config.xml config/lidarr/config.xml.bak
	- cp -vf config/readarr/config.xml config/readarr/config.xml.bak
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
		sed "s#<ApiKey>.*</ApiKey>#<ApiKey>$$READARR_KEY</ApiKey>#g" -i config/readarr/config.xml; \
		sed "s#\"APIKey\": \".*\",#\"APIKey\": \"$$JACKETT_KEY\",#g" -i config/jackett/Jackett/ServerConfig.json; \
		sed "s#\"api_key\": \".*\",#\"api_key\": \"$$SONARR_KEY\",#g" -i config/traktarr/config.json; \
		sed "s#PlexOnlineToken=\".*?\"#PlexOnlineToken=\"$$PLEX_TOKEN\"#g" -i "config/plex/Library/Application Support/Plex Media Server/Preferences.xml"; \
		sed "s#\"client_id\": \".*\",#\"client_id\": \"$$TRAKT_CLIENT_ID\",#g" -i config/traktarr/config.json; \
		sed "s#\"client_secret\": \".*\",#\"client_secret\": \"$$TRAKT_CLIENT_SECRET\",#g" -i config/traktarr/config.json; \
	}
	- cp sensitive/.env.template .env

reset: clean update-config up

check-update:
	{ \
		cmd="python3 ${CWD}/check_updates.py"; \
		$$($$cmd); \
		if [ $$? -eq 1 ]; then \
		   echo "Update required"; \
		   $$(make -f ${THIS_FILE} reset); \
		fi; \
	}

seedmage-reset:
	- ${CONTAINER_TOOL} exec -it deluge killall -9 screen
	- ${CONTAINER_TOOL} exec -it deluge screen -wipe
	- find config/deluge/seedmage/torrents/ -regextype posix-egrep -regex '.*/[0-9a-zA-Z]{40}\.torrent' -delete
	- rm -rvf config/deluge/seedmage/state/*
	- ${CONTAINER_TOOL} exec -it deluge /config/seedmage/seedmage.sh

seedmage-attach:
	- ${CONTAINER_TOOL} exec -it deluge screen -rd seedmage

install-plugin:
	- mkdir -vp ~/.config/deluge/plugins/
	- echo ${CWD}/config/deluge/DelugeOrganise > ~/.config/deluge/plugins/DelugeOrganise.egg-link
