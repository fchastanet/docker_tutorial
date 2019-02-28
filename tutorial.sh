#!/usr/bin/env bash

#ensure all sh files are executables
find . -name '*.sh' -perm -u+rw -exec chmod 755 {} ';' 2>/dev/null

# load framework
CURRENT_DIR="$( cd "$( dirname ${BASH_SOURCE[0]})" && pwd )"
source "$(cd "${CURRENT_DIR}" && pwd)/scripts/framework.sh"

# first clean at startup
[[ "$1" != "0" ]] && cleanAllContainers

declare -a exos

while IFS=  read -r -d $'\0'; do
    exos+=("$REPLY")
done < <(find exercises -name "_exo.sh" -printf '%h\0' | sort -u -z)

chooseExercice() {
    local baseDir=""
    local newBaseDir=""
    for i in "${!exos[@]}"; do
        newBaseDir="$(dirname ${exos[$i]})"
        if [[ "${baseDir}" != "${newBaseDir}" ]]; then
            echo
            echo "${newBaseDir}"
            baseDir="${newBaseDir}"
        fi
        local exoTitle=""
        if [[ -f "${exos[$i]}/_exo_title.txt" ]]; then
            exoTitle=" - $(head -1 "${exos[$i]}/_exo_title.txt")"
        fi
        printf "\t$i) $(basename "${exos[$i]}") ${exoTitle}\n"
    done

    exoNumber=$(askNumber "Enter exercise number (x to exit)")
    if [[ "$?" != "0" ]]; then
        # exit
        exit 0
    fi

    launchExercice "${exoNumber}" "${exos[${exoNumber}]}/_exo.sh"
    chooseExercice
}

chooseExercice
