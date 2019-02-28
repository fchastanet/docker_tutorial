#!/usr/bin/env bash

# here the user is root
# ensure dev user has the right user/group ids matching host user/group ids
Configure::home() {
    local homePath="$1"
    local user="$2"
    local hostUserId="$3"
    local group="$4"
    local hostGroupId="$5"

    sed -i -r "s#${user}:x:[0-9]+:[0-9]+:(${group})?:.*:.*#${user}:x:${hostUserId}:${hostGroupId}:${group}:/home/${user}:/bin/bash#g" /etc/passwd
    if [ ! -z "${group}" ]; then
        sed -i -r "s/${group}:x:[0-9]+:/${group}:x:${hostGroupId}:/g" /etc/group
    fi
}

Configure::home "/home/dev" "dev" "${HOST_USER_ID}" "dev" "${HOST_GROUP_ID}"

# ensure dev user has the right to write in the /home/wwwroot/sf4 directory
chown dev:dev /home/wwwroot/sf4

# initialize src the first time the container starts
gosu dev /usr/local/bin/install.sh

# finally call the original entrypoint
source /usr/local/bin/docker-php-entrypoint