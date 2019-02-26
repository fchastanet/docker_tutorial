#!/usr/bin/env bash

###
### AIM : Launch MySQL Container and test it
###

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
source "$(cd "${CURRENT_DIR}/.." && pwd)/framework.sh"

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
