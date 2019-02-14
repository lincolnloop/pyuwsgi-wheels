#!/bin/bash

set -euf -o pipefail

SRC=$1
APPEND_VERSION=${APPEND_VERSION:-""}

cp setup.py $SRC/setup.py
sed -i.bak 's/uwsgiconfig\.uwsgi_version/uwsgiconfig.uwsgi_version + "'$APPEND_VERSION'"/' $SRC/setup.py
rm $SRC/setup.py.bak
cp $SRC/buildconf/pyuwsgi.ini $SRC/buildconf/pyuwsginossl.ini
echo "ssl = false" >> $SRC/buildconf/pyuwsginossl.ini
rm $SRC/PKG-INFO
