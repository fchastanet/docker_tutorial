#!/usr/bin/env bash

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
source "$(cd "${CURRENT_DIR}/.." && pwd)/scripts/framework.sh"

# Launch Apache linked to Mysql container previously created
docker run --name wordpressApache -p 8080:80 --link wordpressMysql:mysql -d wordpress

# See all running docker containers
docker ps

# See all related docker process
ps axf | grep -E "mysql|apache" | grep -v grep

# Open wordpress http://localhost:8080
