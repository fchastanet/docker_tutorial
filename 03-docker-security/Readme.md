# Docker security attention points

## see impact of a container with host root dir shared
Launch bash on debian container.

**Note** :  On windows it's the file of the virtual machine that is running docker containers

**On Windows**
> ```bash
> docker run --rm -it -v //://host debian:stretch //bin/bash
> ```
>
> under windows /host actually points to the root of the virtual machine that is hosting docker
> You can access to the windows host C drive by typing
> ```bash
> dir=/host/host_mnt/c
> cd $dir
> ls -al
> ```

**On linux like systems**
> ```bash
> docker run --rm -it -v /:/host debian:stretch /bin/bash
> ```
>
> under linux /host actually points to the root of your host machine
> ```bash
> dir=/host
> cd $dir
> ls -al
> ```

Remark that you can see the host files. Note that you are root on the container and on the host as docker service is run as root.

## see encrypted password file

You will see how to see encrypted password as well as other information such as account or password expiration values

```bash
cat /host/etc/shadow
cat /host/etc/password
```

## create a file
> ```bash
> touch $dir/tutoDockerSecurityHole
> echo "check on your host that the file $dir/tutoDockerSecurityHole is created"
> # delete the file
> rm "$dir/tutoDockerSecurityHole"
> # exit to leave bash session
> ```

## access to docker daemon
Let's go a little bit further ...

in the case where docker exposes the port 2375 (noauth) or 2375(tls)

Your dev environment should be configured like this.

Also for application that manages containers, the use of this port is needed.

> **NMap tool**
>
> Nmap ("Network Mapper") is a free and open source (license) utility for network discovery and security auditing. 
> Many systems and network administrators also find it useful for 
> tasks such as network inventory, managing service upgrade schedules, 
> and monitoring host or service uptime. Nmap uses raw IP packets in 
> novel ways to determine what hosts are available on the network, 
> what services (application name and version) those hosts are offering, 
> what operating systems (and OS versions) they are running, what type of 
> packet filters/firewalls are in use, and dozens of other characteristics. 
> It was designed to rapidly scan large networks, but works fine against 
> single hosts. Nmap runs on all major computer operating systems, and 
> official binary packages are available for Linux, Windows, and Mac OS X. 

install nmap
```bash
sudo apt update
sudo apt install nmap
```

launch this command
```bash
nmap -p2375 localhost -nvvvv
```
you should see at the end of the logs
>        PORT     STATE SERVICE REASON
>       2375/tcp open  docker  syn-ack
        
You can see docker ps output by running
```bash
docker -H tcp://127.0.0.1:2375 ps
```
   
now launch a container using this port
```bash
docker -H tcp://127.0.0.1:2375 run --rm -it -v //://host debian:stretch //bin/bash
```

see if we have access to /etc/shadow
```bash
cat /etc/shadow
```
exit to leave bash session