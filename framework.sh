#!/usr/bin/env bash
let exoNumber=0

declare -g thisCommand
declare -g previousCommand
trap 'previousCommand=$thisCommand; thisCommand=$BASH_COMMAND' DEBUG

openUrl() {
    [[ -x ${BROWSER} ]] && "${BROWSER}" "$1"
    path=$(which xdg-open || which gnome-open) && "$path" "$1"
}

removeAllContainers() {
    docker rm $(docker ps -aq)
}
stopAllContainers() {
    docker stop $(docker ps -aq)
}
cleanAllContainers() {
    stopAllContainers
    removeAllContainers
}

# check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
readonly __ERROR_COLOR='\e[31m'           # Red
readonly __INFO_COLOR='\e[44m'            # white on lightBlue
readonly __SUCCESS_COLOR='\e[32m'         # Green
readonly __WARNING_COLOR='\e[33m'         # Yellow
readonly __DEBUG_COLOR='\e[37m'           # Grey
readonly __TIME_TRACKING_COLOR='\e[37m'   # Grey
readonly __RESET_COLOR='\e[0m'            # Reset Color

Log::displayError() {
    local msg="ERROR - ${1}"
    Log::displayMessage ${__ERROR_COLOR} "${msg}"
}

Log::displayWarning() {
    local msg="WARN  - ${1}"
    Log::displayMessage ${__WARNING_COLOR} "${msg}"
}

Log::displayInfo() {
    local msg="INFO  - ${1}"
    Log::displayMessage ${__INFO_COLOR} "${msg}"
}

Log::displaySuccess() {
    local msg="${1}"
    Log::displayMessage ${__SUCCESS_COLOR} "${msg}"
}

Log::displayMessage() {
    local color="$1"
    local msg="$2"
    echo -e "${color}${msg}${__RESET_COLOR}"
}

askYesNo() {
    while true; do
        read -p "$1 (y or n)? " -n 1 -r
        echo    # move to a new line
        case ${REPLY} in
            [yY]) return 0;;
            [nN]) return 1;;
            *)
                read -N 10000000 -t '0.01' ||true; # empty stdin in case of control characters
                # \\r to go back to the beginning of the line
                Log::displayError "\\r invalid answer                                                          "
        esac
    done
}

prompt() {
    local help="$1"
    local command="$2"

    let exoNumber++
    echo "#############################"
    echo " EXERCISE ${exoNumber}"
    echo "#############################"
    echo "$help by running :"
    echo "\$ ${command}"
    if askYesNo "run it now"; then
        eval "${command}"
    fi
}