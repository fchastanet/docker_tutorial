#!/usr/bin/env bash

# do not exit on error
set +o errexit
set +o pipefail

let exoNumber=0

declare -g thisCommand
declare -g previousCommand
trap 'previousCommand=$thisCommand; thisCommand=$BASH_COMMAND' DEBUG

openUrl() {
    [[ -x ${BROWSER} ]] && "${BROWSER}" "$1"
    path=$(which xdg-open 2>/dev/null || which gnome-open 2>/dev/null) && "$path" "$1" || echo "open manually the url '$1' in your browser"
}

removeAllContainers() {
    local containers="$(docker ps -aq)"
    [[ ! -z "${containers}" ]] && docker rm "${containers}"
}
stopAllContainers() {
    local containers="$(docker ps -aq)"
    [[ ! -z "${containers}" ]] && docker stop "${containers}"
}
cleanAllContainers() {
    Log::displayInfo "check if containers are running ..."
    local containers="$(docker ps -aq)"
    if [[ ! -z "${containers}" ]] ; then
        Log::displayInfo "cleaning containers ${containers}"
        docker stop ${containers} 2>/dev/null >/dev/null
        docker rm -v -l ${containers} 2>/dev/null >/dev/null
    fi
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
        printf "$1 "
        read -p "(y or n)? " -n 1 -r
        clearLine
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

askNumber() {
    while true; do
        read -p "$1 ? " -r
        if [[ ${REPLY} =~ [0-9]+ ]]; then
            echo ${REPLY}
            return 0
        elif [[ ${REPLY} =~ [xX] ]]; then
            return 1
        else
            read -N 10000000 -t '0.01' ||true; # empty stdin in case of control characters
            # \\r to go back to the beginning of the line
            Log::displayError "\\r invalid answer                                                          "
        fi
    done
}


launchExercice() {
    local exoNumber="$1"
    local exoFile="$2"

    echo
    echo "######################################################################################"
    echo " EXERCISE ${exoNumber}" "${exoFile}"
    echo "######################################################################################"

    (
        cd $(dirname ${exoFile})
        if [[ -f _exo.txt ]]; then
            cat _exo.txt
            echo
            pause
        fi
        source $(basename "${exoFile}")
        [[ -f _exo_clean.sh ]] && source _exo_clean.sh
    )

    echo
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    echo " EXERCISE ${exoNumber}" "${exoFile} finished. Congratulations !"
    echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    pause
}

pause() {
    local msg="${1:-press any key to continue ... }"
    echo
    read -p "${msg}" -n 1 -r
    clearLine
}

clearLine() {
    echo -e "\033[1K"
}

prompt() {
    local help="$1"
    local command="$2"
    local additionalHelp="$3"

    echo
    echo "$help by running :"
    echo
    echo "        \$ ${command}"
    echo
    local msg=""
    [[ ! -z "${additionalHelp}" ]] && msg+="${additionalHelp}\n"
    msg+="run it now"
    if askYesNo "${msg}"; then
        (
            set +o errexit
            set +o pipefail
            eval "${command}"
        )
        local ret=$?
        if [[ "${ret}" != "0" ]]; then
            echo "${output}"
            echo
            if askYesNo "the command has failed, do you want to retry"; then
                prompt "${help}" "${command}"
                return
            fi
        else
            pause
        fi
    fi
    echo
    echo "--------------------------------------------------------------------------------------"
}


Functions:isWindows() {
    [[ "$(uname -o)" = "Msys" ]] && return 0 || return 1
}