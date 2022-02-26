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
FROM alpine:3.9 as gosuBuild

ARG GOSU_VERSION=1.10
ARG GOSU_GPGKEY=B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN apk update && \
    apk add vim && apk add wget && \
    set -x \
    && apk add --no-cache --virtual .gosu-deps \
        dpkg \
        gnupg \
        openssl \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys ${GOSU_GPGKEY} \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apk del .gosu-deps

###################################################################################
#                               php                                               #
###################################################################################
FROM php:7.3-fpm-alpine3.9

# gosu command added via multi-stage builds
COPY --from=gosuBuild /usr/local/bin/gosu /usr/local/bin/gosu
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

RUN set -x \
    # gosu set-user-id mode in order to allow it to be executed in high priviledged mode
    && chmod +xs /usr/local/bin/gosu \
    && chmod +x  /usr/local/bin/composer

# for a strange reason php:7.3-fpm-alpine3.9 image has lost default cmd, fix it
CMD ["php-fpm"]

# Custom entrypoint
ENTRYPOINT [ "/usr/local/bin/custom-entrypoint" ]
