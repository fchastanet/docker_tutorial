#!/usr/bin/env bash

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
source "$(cd "${CURRENT_DIR}/.." && pwd)/scripts/framework.sh"

# good tuto https://www.rubix.nl/blogs/utilizing-vagrant-and-packer-provisioning-development-environments