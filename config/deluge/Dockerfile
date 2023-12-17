FROM ubuntu:latest
RUN DEBIAN_FRONTEND=noninteractive dpkg --add-architecture i386
RUN DEBIAN_FRONTEND=noninteractive apt update -y
RUN DEBIAN_FRONTEND=noninteractive apt upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y apt-utils
RUN DEBIAN_FRONTEND=noninteractive apt install -y jq \
	deluge* \
	python3-pip \
	python3-pycurl \
	python3-bs4 \
	screen \
	libmediainfo0v5 \
	unrar \
	curl \
	wget \
	supervisor \
	apt-utils \
	psmisc \
	net-tools \
	bind9-utils \
	iproute2 \
	iputils-ping \
	nmap \
	ffmpeg \
	libc6-i386 \
	libc6-x32

ADD supervisord.conf /etc/supervisor/
ADD software/jdk-18_linux-x64_bin.deb /tmp
RUN DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/jdk-18_linux-x64_bin.deb
RUN update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk-18/bin/java" 1
RUN update-alternatives --set java "/usr/lib/jvm/jdk-18/bin/java"
RUN java -version
RUN wget -qO - https://get.filebot.net/filebot/KEYS | apt-key add -
RUN echo "deb [arch=amd64] https://get.filebot.net/deb/ universal main" >> /etc/apt/sources.list
RUN DEBIAN_FRONTEND=noninteractive apt update -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y filebot
RUN pip3 install requests plexapi
RUN useradd -u 1000 default
RUN sed 's#/home/default#/data#g' -i /etc/passwd
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
