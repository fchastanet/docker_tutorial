#!/usr/bin/env bash

# here the user is dev, because it has been launched with gosu from entrypoint

if [[ ! -f /home/wwwroot/sf4/.gitignore ]]; then
    (
        cd /home/wwwroot/sf4
        composer create-project symfony/skeleton my-temp-folder
        cp -Rf /home/wwwroot/sf4/my-temp-folder/. .
        rm -Rf /home/wwwroot/sf4/my-temp-folder
        chown -R www-data:www-data *
    )
fi
