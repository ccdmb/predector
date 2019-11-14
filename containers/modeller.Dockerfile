FROM darcyabjones/base:predector-v0.0.1

RUN	wget --no-check-certificate https://salilab.org/modeller/9.23/modeller_9.23-1_amd64.deb \
  && env KEY_MODELLER=MODELIRANJE dpkg -i modeller_9.23-1_amd64.deb

WORKDIR ~/


