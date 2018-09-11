#!/bin/bash

set -euf -o pipefail

SRC=$1
APPEND_VERSION=${APPEND_VERSION:-""}

mv $SRC/setup.pyuwsgi.py $SRC/setup.py
sed -i.bak 's/uwsgiconfig\.uwsgi_version/uwsgiconfig.uwsgi_version + "'$APPEND_VERSION'"/' $SRC/setup.py
rm $SRC/setup.py.bak
rm $SRC/PKG-INFO
