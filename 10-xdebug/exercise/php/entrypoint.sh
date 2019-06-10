#!/usr/bin/env bash

# here the user is root
# ensure dev user has the right user/group ids matching host user/group ids
Configure::home() {
    local homePath="$1"
    local user="$2"
    local hostUserId="$3"
    local group="$4"
    local hostGroupId="$5"

    sed -i -r "s#${user}:x:[0-9]+:[0-9]+:(${group})?:.*:.*#${user}:x:${hostUserId}:${hostGroupId}:${group}:/home/${user}:/bin/bash#g" /etc/passwd
    if [ ! -z "${group}" ]; then
        sed -i -r "s/${group}:x:[0-9]+:/${group}:x:${hostGroupId}:/g" /etc/group
    fi
}

Configure::home "/home/dev" "dev" "${HOST_USER_ID}" "dev" "${HOST_GROUP_ID}"

DockerFunctions::getHostIp() {
    readonly hostDomain="host.docker.internal"
    local hostIp=$(ping ${hostDomain} -c 1 -s 16 2>/dev/null | grep -o '([^ ]*' | head -1 | tr -d '(44):\n') || $(echo '')
    if [[ -z "${hostIp}" ]]; then
      hostIp=$(/sbin/ip route|awk '/default/ { print $3 }')
    fi
    echo ${hostIp}
}
# dynamic configuration debug tools
ConfigureApache::xDebug() {
    local xDebugIniFile="$1"
    local xDebugEnabled="$2"
    local profilerEnabled="$3"
    local tracingEnabled="$4"
    local xDebugLogsEnabled="$5"
    local logsPath="$6"

    rm -f "${xDebugIniFile}"
    set -x
    if [[ "${xDebugEnabled}" = "1" ]]; then
        # get php extension dir
        local extDir
        extDir="$(php -i | grep '^extension_dir .*=>'  | sed -E 's/.* => (.*)$/\1/g')/"
        if [[ "${extDir}" = "/" ]]; then
            extDir=""
        fi
        # Enable Remote xdebug
        text=''

        text+="zend_extension=${extDir}xdebug.so\n"
        text+="xdebug.remote_enable=1\n"
        # Normally you need to use a specific HTTP GET/POST variable to start remote debugging
        # (see Remote Debugging). When this setting is set to 1, Xdebug will always attempt
        # to start a remote debugging session and try to connect to a client,
        # even if the GET/POST/COOKIE variable was not present.
        # it can be useful to set it to 1 to debug automatically cli scripts
        # with PhpStorm use XDEBUG_CONFIG=idekey=PHPSTORM and PHP_IDE_CONFIG='serverName=localhost'to avoid setting this to 1
        text+="xdebug.remote_autostart=1\n"
        text+="xdebug.remote_connect_back=0\n"
        #xdebug.remote_host not needed if xdebug.remote_connect_back
        text+="xdebug.remote_host=$(DockerFunctions::getHostIp)\n"
        text+="xdebug.remote_port=9000\n"
        text+="xdebug.idekey=PHPSTORM\n"
        text+="xdebug.max_nesting_level=500\n"

        # Profiler
        if [[ "${profilerEnabled}" = "1" ]]; then
            Log::displayInfo 'php profiler enabled'
            text+="xdebug.profiler_enable=on\n"
        else
            Log::displayInfo 'php profiler disabled'
            text+="xdebug.profiler_enable=off\n"
        fi

        text+="xdebug.trace_format=on\n"
        text+="xdebug.profiler_enable_trigger=on\n"
        text+="xdebug.profiler_output_dir=${logsPath}\n"

        if [[ "${tracingEnabled}" = "1" ]]; then
            Log::displayInfo 'php tracing enabled'
            text+="xdebug.auto_trace=on\n"
            text+="xdebug.show_mem_delta=1\n"
            text+="xdebug.trace_enable_trigger=off\n"
            text+="xdebug.trace_output_dir=${logsPath}\n"
        else
            Log::displayInfo 'php tracing disabled'
            text+="xdebug.auto_trace=off\n"
        fi

        printf "%b" "${text}" > "${xDebugIniFile}"
    fi
    set +x
}

ConfigureApache::xDebug \
    "/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini" \
    "${XDEBUG_ENABLED}" \
    "${PROFILER_ENABLED}" \
    "${TRACING_ENABLED}" \
    "${XDEBUG_LOGS_ENABLED}" \
    "/home/wwwroot/sf4/logs"

# ensure dev user has the right to write in the /home/wwwroot/sf4 directory
chown dev:dev /home/wwwroot/sf4

# initialize src the first time the container starts
gosu dev /usr/local/bin/install.sh

# finally call the original entrypoint
source /usr/local/bin/docker-php-entrypoint