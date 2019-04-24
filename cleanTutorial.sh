#!/usr/bin/env bash

# this script will remove all docker containers and images

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
source "$(cd "${CURRENT_DIR}" && pwd)/.scripts/framework.sh"

# first clean at startup
cleanAllContainers

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

echo "remove docker images"
for image in "${images[@]}"; do
    docker image rm "${image}"
done

# TODO remove packer images