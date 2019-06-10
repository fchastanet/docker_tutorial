###################################################################################
#                     multi stage build dependencies                              #
###################################################################################


###################################################################################
#                     Gosu image construction                                     #
###################################################################################
# The gosu utility is often used in scripts called from ENTRYPOINT instructions
# inside Dockerfiles for official images.
# It’s a very simple utility, similar to sudo, that runs a given instruction
# as a given user.
# The difference is that gosu avoids sudo‘s “strange and often annoying TTY
# and signal-forwarding behavior”.
# @see https://github.com/tianon/gosu
FROM debian:stretch as gosuBuild

ARG GOSU_VERSION=1.10
ARG GOSU_GPGKEY=B42F6819007F00F88E364FD4036A9C25BF357DD4
ARG DEBIAN_FRONTEND=noninteractive

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections &&\
    apt-get update &&\
    apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        dirmngr \
        gnupg2 \
        gnupg2 &&\
    rm /bin/sh && ln -s /bin/bash /bin/sh &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

RUN \
    # make your script exit when a command fails
    set -o errexit &&\
    set -o pipefail &&\
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" &&\
    curl -o /usr/local/bin/gosu -L "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}" &&\
    curl -o /usr/local/bin/gosu.asc -L "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${dpkgArch}.asc" &&\
    export GNUPGHOME="$(mktemp -d)" &&\
    # try to get key on different servers
    found=''; \
    for server in $(shuf -e ha.pool.sks-keyservers.net \
                            hkp://p80.pool.sks-keyservers.net:80 \
                            keyserver.ubuntu.com \
                            hkp://keyserver.ubuntu.com:80 \
                            pgp.mit.edu) ; do \
        echo "Fetching GPG key ${GOSU_GPGKEY} from ${server}"; \
        gpg --keyserver "${server}" --recv-keys ${GOSU_GPGKEY} && found=yes && break || : ; \
    done; \
    test -z "${found}" && echo >&2 "error: failed to fetch GPG key ${GOSU_GPGKEY}" && exit 1; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu ;\
    rm -r "${GNUPGHOME}" /usr/local/bin/gosu.asc; \
    chmod +x /usr/local/bin/gosu

###################################################################################
#                               Apache                                            #
###################################################################################
FROM debian:stretch

# Install apache, PHP, and supplimentary programs. openssh-server, curl, and lynx-cur are for debugging the container.
ARG DEBIAN_FRONTEND=noninteractive
RUN true \
    && apt-get update \
    && apt-get -y upgrade \
    &&  apt-get -y install \
        apache2 \
        php7.0 \
        php7.0-mysql \
        libapache2-mod-php7.0 \
        curl \
        lynx-cur \
    \
    # Enable apache mods.
    && a2enmod php7.0 \
    && a2enmod rewrite \
    \
    # Update the PHP.ini file, enable <? ?> tags and quieten logging.
    && sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/7.0/apache2/php.ini \
    && sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.0/apache2/php.ini

# Manually set up the apache environment variables
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

# Expose apache.
EXPOSE 80

# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND