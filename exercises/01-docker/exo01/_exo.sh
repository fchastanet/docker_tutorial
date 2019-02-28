#!/usr/bin/env bash

###
### AIM : Launch MySQL Container and test it
###

command="docker run --rm --name wordpressMysql -e MYSQL_ROOT_PASSWORD=password -d mysql:5.7"
prompt "launch a MySQL container from mysql 8.0 image" "${command}"

# Wait for mysql image to be ready
if which nc 2>/dev/null; then
    Log::displayInfo "now we are waiting for mysql container to be ready ..."
    until nc -z $(docker inspect --format='{{.NetworkSettings.IPAddress}}' wordpressMysql) 3306
    do
        Log::displayInfo "waiting for mysql container..."
        sleep 1
    done
    Log::displaySuccess "mysql container is ready"
fi

command="docker logs -f wordpressMysql"
prompt "see the logs of the MySQL container (type Control-C to return to this tutorial)" "${command}" "${help}"

command="docker exec wordpressMysql sh -c 'exec mysql -uroot -ppassword -e \"SHOW DATABASES;\"'"
prompt "Connect to MySQL container and show databases" "${command}" "${help}"

command="docker exec -it wordpressMysql bash"
Functions:isWindows && command="winpty ${command}"
help=""
Functions:isWindows && help="winpty is needed for windows to allocate a tty"
prompt "Launch bash on mysql container (type ls, exit to leave bash session)" "${command}"

# Launch Apache linked to Mysql container previously created
command="docker run --name wordpressApache -p 8080:80 --link wordpressMysql:mysql -d wordpress"
prompt "Launch Apache container from wordpress image linked to Mysql container previously created" "${command}"

command="docker logs -f wordpressApache"
prompt "see the logs of the Apache container (type Control-C to return to this tutorial)" "${command}" "${help}"

# See all running docker containers
command="docker ps"
prompt "See all docker containers" "${command}"

# See all docker containers
command="docker ps -a"
prompt "See all docker containers" "${command}" " -a, --all             Show all containers (default shows just running)"

# See only container id of all the docker containers
command="docker ps -aq"
prompt "See only container id of all the docker containers" "${command}"

# See all related processes
if ! Functions:isWindows ; then
    command="ps axf | grep -E 'mysql|apache' | grep -v grep"
    prompt "See the processes that are running on the host related to this exercise" "${command}"

fi

command="openUrl 'http://localhost:8080'"
prompt "Open wordpress http://localhost:8080" "${command}"

# kill all running docker containers
command="docker stop \$(docker ps -aq)"
prompt "kill all running docker containers" "${command}"

# remove docker containers
command="docker rm \$(docker ps -aq)"
prompt "finally remove docker containers" "${command}"