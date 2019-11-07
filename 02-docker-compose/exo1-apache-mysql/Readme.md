# launch containers using docker-compose  
Aim : launch containers (mysql and php symfony) 
as we have done it already in [01-docker](../../01-docker/Readme.md) 
but with a slighter different stack

## docker images build
we will build apache image and pull the images for phpmyadmin and mysql 

during the build, analyse the content of the directory exercise
```bash
# go to the exercise directory
cd "${TUTO_BASE_DIR}/02-docker-compose/exo1-apache-mysql/exercise"
# builds the images that need to be built
docker-compose build 
# pull (already built) images from official docker repository
docker-compose pull
```

## analyse the files
first take the time to analyse the files in the folder 02-docker-compose/exo01/exercise in this order:
* docker-compose.yml
* apache/Dockerfile

and apache configuration file that you don't really need to analyse this time:
* apache/vhosts/sf4.conf

## launch our docker containers
now we will launch all the services defined in the docker-compose.yml file 
in background process (-d option)
```bash
docker-compose up -d
```

see the logs of the different services
-f option, follow mode
Ctrl-C to go back to the bash prompt
```bash
docker-compose logs -f
```

## initialize the symfony project
connect to the sf4_php container
> **Note**
> On window git bash you will need to open tty (see [Previous tutorial](../../01-docker/Readme.md))
> just prepend *winpty* to the following command

```bash
docker exec -it -u root sf4_apache bash
```

from this container, we will initialize the symfony project
launch the following commands:
```bash
cd /home/wwwroot/sf4
composer create-project symfony/skeleton .
chown -R www-data:www-data * .*
```

Finally type 'exit' to return to the host

## inspect the volume
inspect volume structure
```bash
docker volume inspect exercise_web-site-volume
```
you can see in the property Mountpoint the place where the files of the volume are actually stored

list the files in the volume
```bash
sudo ls -al "$(docker volume inspect exercise_web-site-volume | grep "Mountpoint" | sed -E 's/[ \t]+"Mountpoint": "([^"]+)",$/\1/')"
```

## open the web sites
Open the web site in your browser [http://localhost](http://localhost)
You should see a page with 'Welcome to Symfony 4.2.3'

Open phpmyadmin [http://localhost:8080](http://localhost:8080)
Notice that you can't authenticate to it using server/login/password mysql/sf4/sf4
defined in the docker-compose.yml file
we will see in the next exercise how to correct this 

## cleaning
now remove the containers and the volumes associated (option -v)
```bash
docker-compose down -v
```
