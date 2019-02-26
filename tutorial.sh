#!/usr/bin/env bash

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
source "$(cd "${CURRENT_DIR}" && pwd)/scripts/framework.sh"


declare -a exos

while IFS=  read -r -d $'\0'; do
    exos+=("$REPLY")
done < <(find exercises -name "*.sh" -printf '%h\0' | sort -u -z)

for i in "${!exos[@]}"; do
    echo "$i) ${exos[$i]}"
done

exoNumber=$(askNumber "Enter exercise number (x to exit)")
if [[ "$?" != "0" ]]; then
    # exit
    exit 0
fi

(source ${exos[${exoNumber}]}/exo.sh)