#!/usr/bin/env bash

###
### AIM : Launch MySQL Container and test it
###

cleanAllContainers

# launch a MySQL container by running
command="docker run --rm --name wordpressMysql -e MYSQL_ROOT_PASSWORD=password -d mysql:5.7"
prompt "launch a MySQL container" "${command}"

# Wait for mysql image to be ready
Log::displayInfo "now we are waiting for mysql container to be ready ..."
until nc -z $(docker inspect --format='{{.NetworkSettings.IPAddress}}' wordpressMysql) 3306
do
    Log::displayDebug "waiting for mysql container..."
    sleep 1
done
Log::displaySuccess "mysql container is ready"

# Connect to MySQL container
docker exec -it wordpressMysql sh -c 'exec mysql -uroot -ppassword -e "SHOW DATABASES;"'

# Launch bash on mysql container (type ls, exit to leave bash session)
docker exec -it wordpressMysql bash


# Launch Apache linked to Mysql container previously created
docker run --name wordpressApache -p 8080:80 --link wordpressMysql:mysql -d wordpress

# See all running docker containers
docker ps

# See all related docker process
ps axf | grep -E "mysql|apache" | grep -v grep

# Open wordpress http://localhost:8080
openUrl "http://localhost:8080"