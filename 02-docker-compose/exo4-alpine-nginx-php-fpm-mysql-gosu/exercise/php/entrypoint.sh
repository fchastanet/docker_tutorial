#!/usr/bin/env sh
set -x

# here the user is root
# ensure dev user has the right user/group ids matching host user/group ids
home() {
    local homePath="$1"
    local user="$2"
    local hostUserId="$3"
    local group="$4"
    local hostGroupId="$5"

    # www-data:x:82:82:Linux User,,,:/home/www-data:/sbin/nologin
    sed -i -r "s#${user}:x:[0-9]+:[0-9]+:([^:]+):[^:]+:[^:]+#${user}:x:${hostUserId}:${hostGroupId}:${group}:${homePath}:/bin/ash#g" /etc/passwd
    if [[ ! -z "${group}" ]]; then
        # www-data:x:82:www-data
        sed -i -r "s/${group}:x:[0-9]+:${user}/${group}:x:${hostGroupId}:${user}/g" /etc/group
    fi

    # ensure dev user has the right to write in the /home/wwwroot/sf4 directory
    chown ${user}:${group} /code
    chown ${user}:${group} ${homePath}
}

home "/home/www-data" "www-data" "${HOST_USER_ID}" "www-data" "${HOST_GROUP_ID}"


# initialize src the first time the container starts
gosu www-data /usr/local/bin/install.sh

# finally execute default command
exec docker-php-entrypoint "$@"