FROM ruby:2.7.4-alpine
LABEL MAINTAINER="Adhithia Irvan Rachmawan <adhithia.irvan@gmail.com>"

ENV NGINX_PATH=/opt/nginx
ENV SRC_PATH=/usr/src
ENV PASSENGER_PATH=/opt/passenger
ENV PATH=${PASSENGER_PATH}/bin:${NGIN_PATH}/sbin:$PATH
ENV PASSENGER_NGINX_APT_SRC_PATH=${SRC_PATH}/passenger-nginx-apt-src
ENV NGINX_MODULES_PATH=${PASSENGER_NGINX_APT_SRC_PATH}/modules

COPY rules ${PASSENGER_NGINX_APT_SRC_PATH}/

RUN apk add --no-cache --virtual .systemRuntimeDeps \
    sudo
RUN apk add --no-cache --virtual .nginxRuntimeDeps \
    ca-certificates curl libnsl openssl linux-pam lua5.1 perl gd geoip
RUN apk add --no-cache --virtual .nginxBuildDeps \
    expat-dev gd-dev geoip-dev libxml2-dev libxslt-dev linux-pam-dev lua5.1-dev perl-dev
RUN apk add --no-cache --virtual .buildDeps \
    curl-dev g++ make openssl-dev wget zlib
RUN apk add --no-cache --virtual .quilt --repository http://mirrors.gigenet.com/alpinelinux/edge/testing quilt

RUN curl -sL http://s3.amazonaws.com/phusion-passenger/releases/passenger-${PASSENGER}.tar.gz | tar -zxC /opt/ \
    && mv ${PASSENGER_PATH}-${PASSENGER} ${PASSENGER_PATH} \
    && echo "PATH=${PASSENGER_PATH}/bin:$PATH" >> /etc/bashrc

RUN echo "Set disable_coredump false" >> /etc/sudo.conf \
    && echo "docker ALL=(ALL) NOPASSWD: SETENV: ${NGINX_PATH}/sbin/nginx" >> /etc/sudoers \
    && passenger-config compile-agent --optimize --auto

RUN gem install rack

RUN passenger-install-nginx-module --auto --auto-download --prefix=${NGINX_PATH}

CMD ["nginx", "-g", "daemon off;"]