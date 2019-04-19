FROM debian:stretch

ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $HTTPD_PREFIX/bin:$PATH

# group of all the commands in one layer to avoid cache effect
RUN true \
    && apt-get update \
    # one apt package by line and sorted alphabetically for easier merging
    && apt-get install -y -q --no-install-recommends \
        apache2 \
        curl \
    \
    && a2enmod \
        rewrite \
        proxy \
        proxy_ajp
        proxy_balancer \
        proxy_fcgi \
        proxy_http \
        ssl \
    \
    && mkdir -p "$HTTPD_PREFIX" \
    && chown www-data:www-data "$HTTPD_PREFIX" \
    && sed -i -E '/^#Global configuration$/ServerName localhost/g' /etc/apache2/apache2.conf \
    \
    # clean apt packages
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && rm -f /run/apache2/apache2.pid

WORKDIR $HTTPD_PREFIX

EXPOSE 80 443

CMD apachectl -DFOREGROUND -e info