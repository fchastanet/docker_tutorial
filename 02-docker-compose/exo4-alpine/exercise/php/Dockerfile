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
#                               php                                               #
###################################################################################
FROM php:7.2.3-fpm

# gosu command added via multi-stage builds
COPY --from=gosuBuild /usr/local/bin/gosu /usr/local/bin/gosu
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# group of all the commands in one layer to avoid cache effect
RUN true \
    && apt-get update \
    # one apt package by line and sorted alphabetically for easier merging
    && apt-get install -y --no-install-recommends \
        acl \
        apt-transport-https \
        apt-utils \
        build-essential \
        curl \
        debconf \
        git \
        gnupg \
        gnupg1 \
        gnupg2 \
        locales \
        mailutils \
        subversion \
        unzip \
        vim \
        wget \
        zip \
    \
    # gosu set-user-id mode in order to allow it to be executed in high priviledged mode
    && chmod +xs /usr/local/bin/gosu \
    \
    # add a user 'dev', see entrypoint.sh to see how the mapping with the Host user id is made
    && groupadd dev -g 999 \
    && useradd dev -g dev -d /home/dev -m \
    \
    # locale
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    \
    # clean apt packages
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

WORKDIR /home/dev/

EXPOSE 9000

CMD ["php-fpm"]

ENTRYPOINT ["custom-entrypoint"]