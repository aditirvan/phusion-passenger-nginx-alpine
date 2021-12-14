FROM ruby:2.7.4-alpine
LABEL MAINTAINER="Adhithia Irvan Rachmawan <adhithia.irvan@gmail.com>"

ENV NGINX_PATH="/etc/nginx"
ENV APP_HOME="/usr/src/app" \
    PASSENGER_VERSION="6.0.12" \
    PATH="/opt/passenger/bin:${NGINX_PATH}/sbin:$PATH"

RUN PACKAGES="libcurl freetds curl openssl zlib boost pcre make g++" \
    BUILD_PACKAGES="freetds-dev curl-dev openssl-dev zlib-dev boost-dev pcre-dev" && \
    apk add --update --no-cache $PACKAGES $BUILD_PACKAGES

#download passenger
RUN mkdir -p /opt && \
    curl -L https://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz | tar -xzf - -C /opt && \
    mv /opt/passenger-$PASSENGER_VERSION /opt/passenger && \
    export EXTRA_PRE_CFLAGS='-O' EXTRA_PRE_CXXFLAGS='-O' EXTRA_LDFLAGS='-lexecinfo'

#compile agent
RUN passenger-config compile-agent --auto --optimize && \
    gem install rack && \
    passenger-install-nginx-module --auto --auto-download --prefix=${NGINX_PATH}

#app directory
RUN mkdir -p /usr/src/app

#cleanup passenger src directory
RUN rm -rf /tmp/* && \
    mv /opt/passenger/src/ruby_supportlib /tmp && \
    mv /opt/passenger/src/nodejs_supportlib /tmp && \
    mv /opt/passenger/src/helper-scripts /tmp && \
    rm -rf /opt/passenger/src/* && \
    mv /tmp/* /opt/passenger/src/

#cleanup
RUN passenger-config validate-install --auto && \
    apk del $BUILD_PACKAGES && \
    rm -rf /var/cache/apk/* \
    /tmp/* \
    /opt/passenger/doc

WORKDIR $APP_HOME

CMD ["nginx", "-g", "daemon off;"]