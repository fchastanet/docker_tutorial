#!/usr/bin/env bash

echo "Updating /etc/my.ini in order to allow native password authentication"
sed -i -e 's/# default-authentication-plugin=mysql_native_password/default-authentication-plugin=mysql_native_password/g' /etc/my.cnf