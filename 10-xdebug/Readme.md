# improve exercises/02-docker-compose/exo02
  
In this exercise, you will see:
* how to improve 02-docker-compose/exo02 
  * add xdebug to php image

# create .env file
execute this command in order to create .env file
```bash
# from directory exercise
if [[ "$(uname -o)" = "Msys" ]]; then
    # windows
    echo "HOST_USER_ID=1000" > .env
    echo "HOST_GROUP_ID=1000" >> .env
else
    # linux
    echo "HOST_USER_ID=$(id -u)" > .env
    echo "HOST_GROUP_ID=$(id -g)" >> .env
fi
echo "XDEBUG_ENABLED=1" >> .env
echo "PROFILER_ENABLED=1" >> .env
echo "TRACING_ENABLED=1" >> .env
echo "XDEBUG_LOGS_ENABLED=1" >> .env
```

# Build the images
rebuild php images

```bash
docker-compose build && docker-compose pull
```

during the build, inspect the differences with the exo 2 using a diff viewer

check the file [exercise/php/Dockerfile](exercise/php/Dockerfile)
and notice how it has been reworked
 * xdebug configuration
 * instead of copying whole **php.ini**, just copy default php.ini and override some properties using sed 

# launch our containers
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
docker exec -it -u dev sf4_php bash
```

you can see that symfony project has been already initialized by [php entrypoint](exercise/php/entrypoint.sh)

Finally type 'exit' to return to the host

## open the web sites
Open the web site in your browser [http://localhost](http://localhost)
You should see a page with 'Welcome to Symfony 4.2.3'

Open phpmyadmin [http://localhost:8080](http://localhost:8080)
Notice that you can't authenticate to it using server/login/password mysql/sf4/sf4
defined in the docker-compose.yml file
we will see in the next exercise how to correct this 

## try to use xdebug
you will need to configure your ide for path mapping
02-docker-compose/exo03/exercise/src should match /home/wwwroot/sf4

## cleaning
now remove the containers and the volumes associated (option -v)
```bash
docker-compose down -v
```