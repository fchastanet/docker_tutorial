#!/usr/bin/env bash


declare command
declare commonInfo
decalre dir

# exo 1
command="docker run --rm -it -v //://host debian:stretch //bin/bash"
Functions:isWindows && command="winpty ${command}"
dir="/host"
Functions:isWindows && dir="/host/host_mnt/c/Temp"

prompt "
    Launch bash on debian container and then type
    $ cat /etc/shadow

    You can see encrypted password as well as other information such as account or password expiration values
    *Note* :  On windows it's the file of the virtual machine

    Windows Specificities:

        Note that under windows /host actually points to the root of the virtual machine that is hosting docker
        You can access to the windows host C drive by typing
        $ cd /host/host_mnt/c


    Now try to access to host files
    $ cd ${dir}
    $ ls -al

    remark that you can see the host files
    note that you are root on the container and on the host
    as docker is run as root

    create a file
    $ touch ${dir}/tutoDockerSecurityHole

    check on your host that the file is created

    delete the file
    $ rm ${dir}/tutoDockerSecurityHole

    check on your host that the file has disappeared

    exit to leave bash session

" "${command}"

# exo 2
pause "
    Let's go a little bit further ...

        access to docker daemon
        in the case where docker exposes the port 2375 (noauth) or 2375(tls)
        Your dev environment should be configured like this.
        Also for application that manages containers, the use of this port is needed.

    press any key to continue ...
"

commonInfo="
    follow these instructions

    if nmap not available
    $ sudo apt install nmap

    launch this command
    $ nmap -p2375 localhost -nvvvv

    you should see at the end of the logs
        PORT     STATE SERVICE REASON
        2375/tcp open  docker  syn-ack

    You can see docker ps output by running
    $ docker -H tcp://127.0.0.1:2375 ps

    now launch a container using this port
    $ docker -H tcp://127.0.0.1:2375 run --rm -it -v /:/host debian:stretch /bin/bash

    see if we have access to /etc/shadow
    $ cat /etc/shadow

    exit to leave bash session
"
if Functions:isWindows; then
    if which wsl 2>/dev/null >/dev/null; then
        command="winpty wsl"
        prompt "
            Under windows you will need wsl

            ${commonInfo}
        " "${command}"
    else
        pause "sorry wsl is not installed, you can't do this exercise"
    fi
else
    command="bash"
    prompt "
        ${commonInfo}
    " "${command}"

fi