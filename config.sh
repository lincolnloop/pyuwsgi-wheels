#!/bin/bash

JANSSON_HASH=6e85f42dabe49a7831dbdd6d30dca8a966956b51a9a50ed534b82afc3fa5b2f4
JANSSON_DOWNLOAD_URL=http://www.digip.org/jansson/releases
JANSSON_ROOT=jansson-2.11


function pre_build {
    build_pcre
    build_libyaml
    build_zlib
    build_jansson
}

function build_jansson {
    if [ -e jansson-stamp ]; then return; fi
    fetch_unpack ${JANSSON_DOWNLOAD_URL}/${JANSSON_ROOT}.tar.gz
    check_sha256sum $ARCHIVE_SDIR/${JANSSON_ROOT}.tar.gz ${JANSSON_HASH}
    (cd ${JANSSON_ROOT} \
        && ./configure --prefix=$BUILD_PREFIX \
        && make -j4 \
        && make install)
    touch jansson-stamp
}

function run_tests {
    pyuwsgi --help
}
