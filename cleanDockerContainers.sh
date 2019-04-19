#!/usr/bin/env bash

# this scripts will ensure that all your docker containers are stopped and removed

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
source "$(cd "${CURRENT_DIR}" && pwd)/.scripts/framework.sh"

# first clean at startup
cleanAllContainers
