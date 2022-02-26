# slightly modified example from 02-docker-compose/exo1-apache-mysql
we reuse the 02-docker-compose/exo1-apache-mysql example but an error in it gives some performance issues

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
cd "${TUTO_BASE_DIR}/04-debug-image/exo1-debug-using-strace/exercise"
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

## launch our containers
now we will launch all the services defined in the docker-compose.yml file in background process (-d option)
```bash 
docker-compose up -d --build
```

## open the web site
Open the web site in your browser [http://localhost](http://localhost)
You should see the `php information` page

## debug the php container

```bash 
docker exec -it --user=root sf4_php sh
```

## cleaning
now remove the containers and the volumes associated (option -v)
```bash
docker-compose down -v
```
