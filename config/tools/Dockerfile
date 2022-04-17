FROM debian

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt install -y apt-utils
RUN apt-get install -y jq vim screen curl python3-pip python3-pycurl python3-bs4 psmisc python3-pip php curl libcurl4-openssl-dev libssl-dev libglib2.0-bin
RUN curl -fsSL https://raw.githubusercontent.com/filebot/plugins/master/installer/deb.sh -o /tmp/deb.sh
RUN sed 's/sudo //g' -i /tmp/deb.sh
RUN sed 's/apt-get/DEBIAN_FRONTEND=noninteractive apt-get -y/g' -i /tmp/deb.sh
RUN sed 's/gnupg-curl/gnupg1-curl/g' -i /tmp/deb.sh
RUN sed 's/unrar/unrar-free/g' -i /tmp/deb.sh
RUN bash /tmp/deb.sh

RUN pip3 install --no-cache-dir --upgrade pip setuptools
COPY requirements.txt /tmp
RUN pip3 install --no-cache-dir --upgrade -r /tmp/requirements.txt
RUN rm -f /tmp/filebot.psm
RUN mkdir -vp /root/.local/share/gvfs-metadata
RUN mkdir -vp /root/.cache/thumbnails

WORKDIR /tools

ENTRYPOINT ["tail", "-f", "/dev/null"]
