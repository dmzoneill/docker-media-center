FROM lscr.io/linuxserver/deluge

# Full installation.
RUN echo "********** [INSTALLING DEPENDENCIES] **********" \
	&& apk add --update --no-cache --virtual build-dependencies \
		xz \
		tar \
		curl \
		ca-certificates \
	&& apk add --no-cache \
		inotify-tools \
		tzdata \
        jq \
        py3-pip \
        py3-curl \
        openjdk11 \
	\
	\
	&& echo "********** [INSTALLING FILEBOT] **********" \
	&& mkdir -p /opt/share/filebot \
	&& cd /opt/share/filebot \
	&& curl -s -L -o filebot.tar.xz https://get.filebot.net/filebot/FileBot_4.9.5/FileBot_4.9.5-portable.tar.xz \
	&& chmod 777 filebot.tar.xz \
	&& tar xvf filebot.tar.xz \
	&& ln -sf /opt/share/filebot/filebot.sh /usr/local/bin/filebot \
	\
	\
	&& echo "********** [CLEAN UP] **********" \
	&& apk del build-dependencies \
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