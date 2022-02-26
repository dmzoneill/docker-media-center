FROM linuxserver/deluge:latest
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y jq vim screen curl python3-pip python3-pycurl python3-bs4 psmisc
RUN curl -fsSL https://raw.githubusercontent.com/filebot/plugins/master/installer/deb.sh -o /tmp/deb.sh
RUN sed 's/sudo //g' -i /tmp/deb.sh
RUN sed 's/apt-get/DEBIAN_FRONTEND=noninteractive apt-get -y/g' -i /tmp/deb.sh
RUN bash /tmp/deb.sh
COPY filebot.psm /tmp
RUN filebot --license /tmp/filebot.psm
RUN rm -f /tmp/filebot.psm
RUN pip3 install requests pycurl