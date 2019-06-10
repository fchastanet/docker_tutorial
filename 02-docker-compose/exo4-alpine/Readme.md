# improve exercises/02-docker-compose/exo01
  
In this exercise, you will see:
* Phpmyadmin container:
  * add some environment variables in order to be able to connect to mysql server

* Mysql server container:
  * custom entrypoint in order to update /etc/my.cnf

* Php container:
  * Dockerfile added gosu
  * custom entrypoint to initialize symfony project
  * code source is shared with the host and has user/group owner matching host user  

## create .env file
here we are creating .env file
all the variables defined in this file are available in the docker-compose.yml file
and are passed to the container as environment variables via environment instruction

> commands id -u and id -g gives current user/group id
> 
> under windows 1000 default value is used, the files shared between host and container
> are world writable anyway, chmod on windows files has no effect

execute this command in order to create .env file
```bash
# go to the exercise directory
cd "${TUTO_BASE_DIR}/02-docker-compose/exo4-alpine/exercise"
# create .env file
if [[ "$(uname -o)" = "Msys" ]]; then
    # windows
    echo "HOST_USER_ID=1000" > .env
    echo "HOST_GROUP_ID=1000" >> .env
else
    # linux
    echo "HOST_USER_ID=$(id -u)" > .env
    echo "HOST_GROUP_ID=$(id -g)" >> .env
fi
```

## See how docker-compose.yml is interpreted
see how .env variables are replaced in docker-compose.yml
```bash
docker-compose config
```

## Build the images
we will build apache and php images
and pull the images for phpmyadmin, mysql and maildev

```bash
docker-compose build && docker-compose pull
```

during the build, inspect the differences with the exo 1 using a diff viewer

check the file [exercise/apache/Dockerfile](exercise/apache/Dockerfile)
and notice how it has been reworked
 * group of all the commands in one layer to avoid cache effect
 * cleaning at the end of the layer to reduce image size
 * one apt package by line and sorted alphabetically for easier merging
 * same best practice for apache module (a2enmod command)

check the file [exercise/php/Dockerfile](exercise/php/Dockerfile)
and notice how it has been reworked
 * group of all the commands in one layer to avoid cache effect
 * gosu command added via multi-stage builds
 * composer command added via official composer image
 * cleaning at the end of the layer to reduce image size
 * one apt package by line and sorted alphabetically for easier merging
 * note that there is too much apt packages and some of them could be removed (to be analysed)
 * cleaning packages in the same layer, otherwise it doesn't clean anything
 * custom entrypoint configuration
 * files .docker/php/php.ini and .docker/php/php-fpm-pool.conf are simply mounted via
      volume mapping inside docker-compose.yml instead of being copied via image building
      it allows you to modify these files without the need of rebuilding the image
      moreover in the first version, the COPY instruction was before some layers, if it was updated
      the subsequent layers would have been invalidated and rebuilt

check the file [exercise/php/entrypoint.sh](exercise/php/entrypoint.sh)
it allows to override the default /usr/local/bin/docker-php-entrypoint of the php image
it is simply mounted via volume mapping inside docker-compose.yml

## launch our containers
now we will launch all the services defined in the docker-compose.yml file in background process (-d option)
```bash 
docker-compose up -d
```

see the logs of the different services, Ctrl-C to go back to the tutorial
```bash
docker-compose logs -f
```

## initialize the symfony project
connect to the sf4_php container
> **Note**
> On window git bash you will need to open tty (see [Previous tutorial](../../01-docker/Readme.md))
> just prepend winpty to the following command

```bash
docker exec -it -u root sf4_php bash
```

you can see that symfony project has been already initialized by [php entrypoint](exercise/php/entrypoint.sh)

Finally type 'exit' to return to the host

## open the web sites
Open the web site in your browser [http://localhost](http://localhost)
You should see a page with 'Welcome to Symfony 4.2.3'

Open phpmyadmin [http://localhost:8080](http://localhost:8080)
Notice that you can now authenticate to it using server/login/password mysql/sf4/sf4
defined in the docker-compose.yml file

## cleaning
now remove the containers and the volumes associated (option -v)
```bash
docker-compose down -v
```

TODO simplify remove php-fpm
TODO problem with phpmyadmin grant user
ALTER USER 'mysqlUsername'@'localhost' IDENTIFIED WITH mysql_native_password BY 'mysqlUsernamePassword';