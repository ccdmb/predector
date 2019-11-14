FROM darcyabjones/base:predector-v0.0.1

ARG KEY="rostlab-debian-keyring_1.13_all.deb"


RUN	apt-get update --fix-missing \
  && apt-get install -y software-properties-common gnupg \
  && wget "http://rostlab.org/debian/pool/main/r/rostlab-debian-keyring/$KEY" && dpkg -i "$KEY"

RUN apt-add-repository "deb http://rostlab.org/debian/ stable main contrib non-free" \
  && apt-get update \
  && apt-get install -y profbval \
  && rm -rf /var/lib/apt/lists/*
  
WORKDIR ~/


