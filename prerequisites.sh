#!/usr/bin/env bash
DOCKER_MINIMAL_VERSION="18.03"
DOCKER_COMPOSE_MINIMAL_VERSION="1.21"
PACKER_MINIMAL_VERSION="1.3.4"
VAGRANT_MINIMAL_VERSION="2.2.3"

# @return 1 if on windows system
Functions::isWindows() {
    [[ "$(uname -o)" = "Msys" ]] && return 0 || return 1
}

# @return 1 if on xsl system
Functions::isWsl() {
    [[ "$(uname -r)" =~ .*-Microsoft$ ]] && return 0 || return 1
}

Functions::checkCommandExists() {
    local commandName="$1"
    local helpIfNotExists="$2"

    which ${commandName} > /dev/null 2>/dev/null && echo "${commandName} is installed" || {
        echo "${commandName} is not installed, please install it. ${helpIfNotExists}"
        return 1
    }
    return 0
}

Version::checkMinimal() {
    local commandName="$1"
    local commandVersion="$2"
    local minimalVersion="$3"

    Functions::checkCommandExists "${commandName}" || return 1

    local version
    version=$(${commandVersion} | sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p')

    Version::compare "${version}" "${minimalVersion}" && {
        echo "${commandName} version ${version} matches minimal required version"
    } || {
        local result=$?
        if [[ "${result}" = "1" ]]; then
            echo "${commandName} version is ${version} greater than ${minimalVersion}, OK let's continue"
        elif [[ "${result}" = "2" ]]; then
            echo "${commandName} minimal version is ${minimalVersion}, your version is ${version}"
        fi
    }

}

# @param $1 version 1
# @param $2 version 2
# @return
#   0 if equal
#   1 if version1 > version2
#   2 else
Version::compare() {
    if [[ "$1" = "$2" ]]
    then
        return 0
    fi
    local IFS=.
    # shellcheck disable=2206
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z "${ver2[i]+unset}" ]] || [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

echo "uname : " $(uname -a)

# check docker version
Version::checkMinimal "docker" "docker -v" "${DOCKER_MINIMAL_VERSION}"
# check docker-compose version
Version::checkMinimal "docker-compose" "docker-compose -v" "${DOCKER_COMPOSE_MINIMAL_VERSION}"
# check packer version
Version::checkMinimal "packer" "packer --version" "${PACKER_MINIMAL_VERSION}"

if [ "$(Functions::isWindows; echo $?)" = "0" ]; then
    # check vagrant version
    Version::checkMinimal "vagrant" "vagrant --version" "${VAGRANT_MINIMAL_VERSION}"

    Functions::checkCommandExists "dos2unix" "are you using git bash ?"
    Functions::checkCommandExists "cygpath" "are you using git bash ?"
    Functions::checkCommandExists "wsl" "you need to install wsl"
elif [[ "$(Functions::isWsl; echo $?)" = "0" ]]; then
    # check vagrant version
    Version::checkMinimal "vagrant.exe" "vagrant.exe --version" "${VAGRANT_MINIMAL_VERSION}"
else
    # check vagrant version
    Version::checkMinimal "vagrant" "vagrant --version" "${VAGRANT_MINIMAL_VERSION}"
fi

# pull docker images
declare -a images=(
    "mysql"
    "mysql:8.0"
    "debian:stretch"
    "php:7.2.3-fpm"
    "phpmyadmin/phpmyadmin"
    "composer"
    "wordpress"
)
echo "pull docker images"
for image in "${images[@]}"; do
    docker image pull "${image}"
    docker image ls --filter "reference=${image}"
done

# TODO pull packer images

# execute docker hello world
if [[ "$(docker run --rm hello-world 2>/dev/null| grep "Hello from Docker!")" = "Hello from Docker!" ]]; then
    echo "Docker Hello world works"
else
    echo "Docker Hello world does not work"
fi
docker image rm hello-world 2>/dev/null >/dev/null
# display images pulled