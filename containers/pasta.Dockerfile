ARG IMAGE

FROM "${IMAGE}"

ARG PASTA

FROM debian:buster-slim
MAINTAINER JAMES
ENV PATH=$PATH:/usr/bin
COPY pasta_exe.tar.gz /temp/
WORKDIR /temp
RUN tar -vzxf pasta_exe.tar.gz
RUN rm pasta_exe.tar.gz
WORKDIR /temp/pasta_exe
RUN sed 's/var\/local\/webservers\/shared\/downloads\/pasta_exe\//\/usr\/bin\//'
RUN cp -r * /usr/bin/.

