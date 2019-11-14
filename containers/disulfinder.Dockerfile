#Download base image ubuntu 18.04
FROM darcyabjones/base:predector-v0.0.1

ARG disulfinderurl="http://ftp.iinet.net.au/pub/ubuntu/pool/universe/d/disulfinder"
ARG version="1.2.11-7"  
    
RUN	wget $disulfinderurl/disulfinder_"${version}"_amd64.deb \
  && wget $disulfinderurl/disulfinder-data_"${version}"_all.deb \
  && dpkg -i disulfinder-data_1.2.11-7_all.deb \
  && dpkg -i disulfinder_1.2.11-7_amd64.deb \
  && rm *.deb

WORKDIR ~/


