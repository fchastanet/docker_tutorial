#!/usr/bin/env bash

###
### AIM : Launch MySQL Container and test it
###

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
BASE_DIR=$( cd "${CURRENT_DIR}/.." && pwd )

# show the differences with the exo 1
echo "Here the file differences with exo1"
echo
(
    cd "${BASE_DIR}"
    diff -dqwr --exclude="_exo*" --left-column "exo01" "exo02" | grep exo02
)
pause

# analyse the files
command="docker-compose build && docker-compose pull"
prompt "
        we will build apache and php containers
        and pull the images for phpmyadmin, mysql and maildev
    " \
    "${command}" \
    "accept the launch of the command \nand during the build, analyse the content of the directory ${CURRENT_DIR}"

pause "
    check the file 'exercises/02-docker-compose/exo02/.docker/apache/Dockerfile'
    and notice how it has been reworked
    - group of all the commands in one layer to avoid cache effect
    - cleaning at the end of the layer to reduce image size
    - one apt package by line and sorted alphabetically for easier merging
    - same best practice for apache module (a2enmod command)

    press any key to continue ...
"

pause "
    check the file 'exercises/02-docker-compose/exo02/.docker/php/Dockerfile'
    and notice how it has been reworked
    - group of all the commands in one layer to avoid cache effect
    - gosu command added via multi-stage builds
    - composer command added via official composer image
    - cleaning at the end of the layer to reduce image size
    - one apt package by line and sorted alphabetically for easier merging
    - note that there is too much apt packages and some of them could be removed (to be analysed)
    - cleaning packages in the same layer, otherwise it doesn't clean anything
    - custom entrypoint configuration
    - files .docker/php/php.ini and .docker/php/php-fpm-pool.conf are simply mounted via
      volume mapping inside docker-compose.yml instead of being copied via image building
      it allows you to modify these files without the need of rebuilding the image
      moreover in the first version, the COPY instruction was before some layers, if it was updated
      the subsequent layers would have been invalidated and rebuilt

    press any key to continue ...
"

pause "
    check the file 'exercises/02-docker-compose/exo02/.docker/php/entrypoint.sh'
    it allows to override the default /usr/local/bin/docker-php-entrypoint of the php image
    it is simply mounted via volume mapping inside docker-compose.yml

    press any key to continue ...
"

pause "
    here we are creating .env file
    all the variables defined in this file are available in the docker-compose.yml file
    and are passed to the container as environment variables via environment instruction

    commands id -u and id -g gives current user/group id

    under windows 1000 default value is used, the files shared between host and container
    are world writable anyway, chmod on windows files has no effect

    press any key to continue ...
"
if [[ "$(uname -o)" = "Msys" ]]; then
    # windows
    echo "HOST_USER_ID=1000" > .env
    echo "HOST_GROUP_ID=1000" >> .env
else
    # linux
    echo "HOST_USER_ID=$(id -u)" > .env
    echo "HOST_GROUP_ID=$(id -g)" >> .env
fi

command="docker-compose up -d"
prompt "now we will launch all the services defined in the docker-compose.yml file in background process (-d option)" "${command}"

command="docker-compose logs -f"
prompt "see the logs of the different services, Ctrl-C to go back to the tutorial" "${command}"

command="docker exec -it -u root sf4_php bash"
Functions:isWindows && command="winpty ${command}"
prompt "connect to the sf4_php container" "${command}" "
    You will have to manually launch the following commands:
        \$ cd /home/wwwroot/sf4
        \$ composer create-project symfony/skeleton my-temp-folder

    When it’s done, we will get the project to the root path.
        \$ cp -Rf /home/wwwroot/sf4/my-temp-folder/. .
        \$ rm -Rf /home/wwwroot/sf4/my-temp-folder
        \$ chown -R www-data:www-data *

    Finally type 'exit' to return to this tutorial
"

command="openUrl 'http://localhost'"
prompt "Open the web site in your browser http://localhost" "${command}" "You should see a page with 'Welcome to
Symfony 4.2.3'"

command="openUrl 'http://localhost:8080'"
prompt "Open phpmyadmin http://localhost:8080" "${command}" "
    Notice that you can't authenticate to it using server/login/password mysql/sf4/sf4
    defined in the docker-compose.yml file
    we will see in the next exercise how to correct this
"

command="docker-compose down -v"
prompt "now remove the containers and the volumes associated (option -v)" "${command}"

