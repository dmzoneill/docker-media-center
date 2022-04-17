.PHONY: build build-images up down check clean clean-mounts backup-diff backup-config update-config reset seedmage-reset seedmage-attach

SHELL := /bin/bash
CWD := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
THIS_FILE := $(lastword $(MAKEFILE_LIST))
WHOAMI := $(shell whoami)

clean-mounts:
	- { \
		for X in `mount | grep merged | awk '{print $3}'`; do \
			sudo umount $$X; \
		done \
	}

build-images:
	sudo chown -Rv ${WHOAMI}:${WHOAMI} config/deluge/*
	- docker-compose build

build: build-images clean-mounts

up: build
	sudo chown -Rv ${WHOAMI}:${WHOAMI} config/deluge/*
	- cp sensitive/.env .env
	cp -vf sensitive/Indexers/* ./config/jackett/Jackett/Indexers/
	cp -vf sensitive/vpn.conf config/vpn/
	docker-compose up -d
	docker exec -it vpn /vpn/port-forward.sh
	docker exec -it deluge /config/seedmage/seedmage.sh
	- cp sensitive/.env.template .env
	@$(MAKE) -f $(THIS_FILE) filebot-update-opensubtitles
	if [ ! -d "./home/.filebot" ]; then \
		@$(MAKE) -f $(THIS_FILE) filebot-update-license; \
	fi

filebot-update-license:
	- cp sensitive/filebot.psm config/deluge/
	- docker exec -it deluge su default -c "filebot --license /config/filebot.psm"
	- docker exec -it deluge chmod 775 /root/.filebot
	- docker exec -it deluge chown -R default:default /root/.filebot
	- rm -f config/deluge/filebot.psm

filebot-update-opensubtitles:
	- cp sensitive/filebot-opensubtitles config/deluge/fbprefs.xml
	- docker exec -it deluge su default -c "mkdir -vp /data/.java/.userPrefs/net/filebot/login/"
	- docker exec -it deluge su default -c "cp -vf /config/fbprefs.xml /data/.java/.userPrefs/net/filebot/login/prefs.xml"
	- rm -f config/deluge/fbprefs.xml 

down: 
	docker-compose down

check:
	docker-compose config

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
		sed "s#PlexOnlineToken=\".*?\"#PlexOnlineToken=\"$$PLEX_TOKEN\"#g" -i "config/plex/Library/Application Support/Plex Media Server/Preferences.xml"; \
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