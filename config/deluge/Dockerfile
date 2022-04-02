FROM lscr.io/linuxserver/deluge
RUN sed 's/false/bash/' -i /etc/passwd
RUN apk add --update --no-cache --virtual build-dependencies \
		xz \
		tar \
		curl \
		ca-certificates
RUN apk add --no-cache \
		inotify-tools \
		tzdata \
        jq \
        py3-pip \
        py3-curl \
        py3-beautifulsoup4 \
        openjdk11 \
        screen \
		libmediainfo

RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main unrar 
		
RUN mkdir -p /opt/share/filebot
RUN cd /opt/share/filebot \
	&& curl -s -L -o filebot.tar.xz https://get.filebot.net/filebot/FileBot_4.9.6/FileBot_4.9.6-portable.tar.xz \
	&& chmod 777 filebot.tar.xz \
	&& tar xvf filebot.tar.xz \
	&& ln -sf /opt/share/filebot/filebot.sh /usr/local/bin/filebot

RUN apk del build-dependencies \
	&& cd /opt/share/filebot \
	&& rm filebot.tar.xz \
	&& rm update-filebot.sh \
	&& rm -rf \
		/tmp/* \
		/var/tmp/* \
		/var/cache/apk/* \
		/opt/share/filebot/lib/x86_64/* \
		/opt/share/filebot/lib/i686/* \
		/opt/share/filebot/lib/aarch64/*
RUN pip3 install requests
COPY filebot.psm /tmp
RUN filebot --license /tmp/filebot.psm
RUN rm -f /tmp/filebot.psm