#!/usr/bin/env sh

# here the user is dev, because it has been launched with gosu from entrypoint

if [[ ! -f /code/.gitignore ]]; then
    (
        cd /code
        composer create-project symfony/skeleton .
    )
fi
