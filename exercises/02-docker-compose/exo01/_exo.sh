#!/usr/bin/env bash

###
### AIM : Launch MySQL Container and test it
###

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"

# analyse the files
command="docker-compose build && docker-compose pull"
prompt "we will build apache and php containers and pull the images for phpmyadmin, mysql and maildev" "${command}" "accept the launch of the command \nand during the build, analyse the content of the directory ${CURRENT_DIR}"

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

