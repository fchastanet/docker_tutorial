# launch 2 containers

the aim of this first tutorial is to launch 2 containers 
in order to launch wordpress stack with apache and mysql

## PART 1 - Launch mysql container

### 1.1 launch our first docker container

launch a MySQL container from mysql 8.0 image
* --rm option is used to remove the container once it terminates
* -d option runs the container in background 
* --default-authentication-plugin=mysql_native_password : MySQL 8 changed the password authentication method.
```bash
docker run --name wordpressMysql -e MYSQL_ROOT_PASSWORD=password -d mysql:8.0 --default-authentication-plugin=mysql_native_password
```

If you have netcat available on your host, you can use following script to wait 
mysql to be available
```bash
if which nc 2>/dev/null; then
    echo "now we are waiting for mysql container to be ready ..."
    until nc -z $(docker inspect --format='{{.NetworkSettings.IPAddress}}' wordpressMysql) 3306
    do
        echo "waiting for mysql container..."
        sleep 1
    done
    echo "mysql container is ready"
else
    echo "sorry nc command is not available"
fi
```

In the case where netcat is not available on your system. Use one available in a linux image.
So previous command is transformed into (note that it should work also on a system with nc available):
```bash
# create nc command as it was natively available on your system
alias nc='docker run --rm --network=host subfuzion/netcat'
(
    wordpressMysqlIP="$(docker inspect --format='{{.NetworkSettings.IPAddress}}' wordpressMysql)"
    if [[ "$?" != "0" ]]; then
        echo "mysql container is not running"
        exit
    fi
    echo "now we are waiting for mysql container to be ready ..."
    until nc -w 1 -z ${wordpressMysqlIP} 3306
    do
        echo "waiting for mysql container..."
        sleep 1
    done
    echo "mysql container is ready"    
)
unalias nc
```

Check logs of the container
> Note that you can use the -f option to follow the logs
```bash
docker logs wordpressMysql
```

### 1.2 Execute commands in running containers
Docker exec is a commonly used CLI command that allows you to run a command within an existing running container.

Connect to MySQL container and show databases
```bash
docker exec wordpressMysql sh -c "mysql -uroot -ppassword -e 'SHOW DATABASES;'"
```

Launch bash on mysql container (type ls command, exit to leave bash session)
here we will need to launch docker exec with the -i (interactive) flag to keep stdin open 
and -t to allocate a terminal.

```bash
docker exec -it wordpressMysql bash
```

> On windows git bash, winpty is needed for windows to allocate a tty
>
> A tty is a terminal (it stands for teletype - the original terminals 
> used a line printer for output and a keyboard for input!). 
>
> A terminal is basically just a user interface device that 
> uses text for input and output.
>
> A pty is a pseudo-terminal - it's a software implementation that 
> appears to the attached program like a terminal, but instead 
> of communicating directly with a "real" terminal, it transfers 
> the input and output to another program.

> For example, when you ssh in to a machine and run ls, the ls command 
> is sending its output to a pseudo-terminal, the other side of which is 
> attached to the SSH daemon.
```bash
winpty docker exec -it wordpressMysql bash
```

## Part 2 - Launch Apache container

### 2.1 Launch Apache linked to Mysql container previously created

Launch Apache container from wordpress image linked to Mysql container previously created

```bash
docker run --rm --name wordpressApache -p 8080:80 --link wordpressMysql:mysql -d wordpress
```

> Note: the --rm option, if the container is stopped, it will be removed in the same time

See the logs of the Apache container  - type Control-C to interrupt

```bash
docker logs -f wordpressApache
```

## Part 3 - analyse processes/containers

### See all running docker containers
```bash
docker ps
```

### See all docker containers (even non-running containers)
```bash
docker ps -a
```

### See only container id of all the docker containers
```bash
docker ps -aq
```

### See all related processes
> **Docker for windows specificities** 
>
> if you are running docker for windows, you will need to first connect 
> to the vm that is hosting docker server
> ```bash
> winpty docker run --net=host --ipc=host --uts=host --pid=host -it --security-opt=seccomp=unconfined --privileged --rm -v //://host alpine //bin/sh
> ```

See the processes that are running on the host related to this exercise
```bash
ps axf | grep -E 'mysql|apache' | grep -v grep
```

Show all the processes
```bash
ps aux
```

## Part 3 - see if it's working
open wordpress [http://localhost:8080]

## Part 4 - clean everything

### kill all running docker containers
> **WARNING**
>
> the following commands will terminate all your containers even those not related to this tutorial !!!

```bash
docker stop $(docker ps -aq)
```

Instead you can use this command to only remove concerned containers
```bash
docker stop wordpressMysql wordpressApache
```

> **Note**: only the wordpressApache container will be removed because of the --rm option, so we need to remove
> wordpressMysql container  

### remove docker containers
> **WARNING**
>
> the following commands will remove all the stopped containers even those not related to this tutorial !!!
```bash
docker rm $(docker ps -aq)
```

Instead you can use this command to only remove concerned containers
```bash
docker rm wordpressMysql
```

### Note : a lot of prebuilt images already exist
see [Docker Hub](https://hub.docker.com/search?q=&type=image)

Congratulations ! you have finished the first part of the tutorial
[Next tutorial](../02-docker-compose/exo01/Readme.md) will show you how to do the same configuration 
using docker-compose ...
