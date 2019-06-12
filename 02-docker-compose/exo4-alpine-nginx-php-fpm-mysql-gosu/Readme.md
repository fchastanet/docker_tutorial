# improve 02-docker-compose/exo3-alpine-nginx-php-fpm

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
cd "${TUTO_BASE_DIR}/02-docker-compose/exo4-alpine-nginx-php-fpm-mysql-gosu/exercise"
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

## Build the images
we will build apache and php images
and pull the images for phpmyadmin, mysql and maildev

```bash
docker-compose build && docker-compose pull
```

during the build, inspect the differences with the exo 1 using a diff viewer

check the file [exercise/apache/Dockerfile](exercise/php/Dockerfile)
and notice what we are adding
 * added gosu using gosu build phase based on alpine
 * added composer

then we are reusing `entrypoint.sh` and `install.sh` from `02-docker-compose/exo2-apache-mysql-gosu/exercise/apache`
 * notice that we do not use the same `#!/usr/bin/env` (sh this time, not bash as bash is not natively installed in alpine) 

## launch our containers
now we will launch all the services defined in the docker-compose.yml file in background process (-d option)
```bash 
docker-compose up
```

you can see in src folder that symfony project has been already initialized by [php entrypoint](exercise/php/entrypoint.sh)

## open the web sites
Open the web site in your browser [http://localhost](http://localhost)
You should see a page with 'Welcome to Symfony 4.2.3'

Open phpmyadmin [http://localhost:8080](http://localhost:8080)
Notice that you can now authenticate to it using server/login/password mysql/sf4/sf4
defined in the docker-compose.yml file

## cleaning
type `Control-C` to stop `docker-compose up`

now remove the containers and the volumes associated (option -v)
```bash
docker-compose down -v
```
