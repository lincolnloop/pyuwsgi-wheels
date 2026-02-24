#!/bin/bash
set -eu -o pipefail

if [ -n "${IS_MACOS:-}" ]; then
  # make sure the linked binaries are equivalent to our target
  if [ -z "${MACOSX_DEPLOYMENT_TARGET:-}" ]; then
    python="$(command -v python)"
    # Python < 3.14 uses LC_VERSION_MIN_MACOSX; Python 3.14+ uses LC_BUILD_VERSION
    min_ver="$(
      otool -l "$python" |
      grep -A2 LC_VERSION_MIN_MACOSX |
      tail -1 |
      awk '{print $2}'
    )" || min_ver="$(
      otool -l "$python" |
      grep -A4 LC_BUILD_VERSION |
      grep "minos" |
      awk '{print $2}'
    )"
    if [ -z "$min_ver" ]; then
      echo "ERROR: Could not determine MACOSX_DEPLOYMENT_TARGET from binary" >&2
      exit 1
    fi
    export MACOSX_DEPLOYMENT_TARGET="$min_ver"
  fi
  make_install=(sudo make install)
else
  make_install=(make install)
fi

JANSSON_HASH=6e85f42dabe49a7831dbdd6d30dca8a966956b51a9a50ed534b82afc3fa5b2f4
JANSSON_DOWNLOAD_URL=https://github.com/akheron/jansson/releases/download/v2.11/jansson-2.11.tar.gz
JANSSON_ROOT=jansson-2.11

PCRE2_HASH=86b9cb0aa3bcb7994faa88018292bc704cdbb708e785f7c74352ff6ea7d3175b
PCRE2_DOWNLOAD_URL=https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.gz
PCRE2_ROOT=pcre2-10.44

# From Multibuild
BUILD_PREFIX="${BUILD_PREFIX:-/usr/local}"
MULTIBUILD_DIR=$(dirname "${BASH_SOURCE[0]}")
function rm_mkdir {
    # Remove directory if present, then make directory
    local path=$1
    if [ -z "$path" ]; then echo "Need not-empty path"; exit 1; fi
    if [ -d "$path" ]; then rm -rf "$path"; fi
    mkdir "$path"
}
function fetch_unpack {
    # Fetch input archive name from input URL
    # Parameters
    #    url - URL from which to fetch archive
    #    archive_fname (optional) archive name
    #
    # Echos unpacked directory and file names.
    #
    # If `archive_fname` not specified then use basename from `url`
    # If `archive_fname` already present at download location, use that instead.
    local url="$1"
    if [ -z "$url" ];then echo "url not defined"; exit 1; fi
    local archive_fname="${2:-$(basename "$url")}"
    local arch_sdir="${ARCHIVE_SDIR:-archives}"
    # Make the archive directory in case it doesn't exist
    mkdir -p "$arch_sdir"
    local out_archive="${arch_sdir}/${archive_fname}"
    # If the archive is not already in the archives directory, get it.
    if [ ! -f "$out_archive" ]; then
        # Source it from multibuild archives if available.
        local our_archive="${MULTIBUILD_DIR}/archives/${archive_fname}"
        if [ -f "$our_archive" ]; then
            ln -s "$our_archive" "$out_archive"
        else
            # Otherwise download it.
            curl -sL "$url" > "$out_archive"
        fi
    fi
    # Unpack archive, refreshing contents, echoing dir and file
    # names.
    tar xfv "$out_archive" && ls -1d ./*
#    rm_mkdir arch_tmp
#    install_rsync
#    (cd arch_tmp && \
#        untar ../$out_archive && \
#        ls -1d * &&
#        rsync --delete -ah * ..)
}
function build_pcre2 {
    if [ -e pcre2-stamp ]; then return; fi
    echo "building pcre2 from $PCRE2_DOWNLOAD_URL"
    fetch_unpack "${PCRE2_DOWNLOAD_URL}"
    check_sha256sum "${ARCHIVES_SDIR:-archives}/${PCRE2_ROOT}.tar.gz" "$PCRE2_HASH"
    (cd "${PCRE2_ROOT}" \
        && CFLAGS="${ARCHFLAGS:-}" LDFLAGS="${ARCHFLAGS:-}" ./configure --prefix="$BUILD_PREFIX" \
        && make -j4 \
        && "${make_install[@]}")
    touch pcre2-stamp
}

function check_sha256sum {
    local fname=$1
    if [ -z "$fname" ]; then echo "Need path"; exit 1; fi
    local sha256=$2
    if [ -z "$sha256" ]; then echo "Need SHA256 hash"; exit 1; fi
    echo "${sha256}  ${fname}" > "${fname}.sha256"
    if [ -n "${IS_MACOS:-}" ]; then
        shasum -a 256 -c "${fname}.sha256"
    else
        sha256sum -c "${fname}.sha256"
    fi
    rm "${fname}.sha256"
}
# End from Multibuild


function build_jansson {
    if [ -e jansson-stamp ]; then return; fi
    echo "building jansson from $JANSSON_DOWNLOAD_URL"
    fetch_unpack "${JANSSON_DOWNLOAD_URL}"
    check_sha256sum "${ARCHIVE_SDIR:-archives}/${JANSSON_ROOT}.tar.gz" "${JANSSON_HASH}"
    (cd "${JANSSON_ROOT}" \
        && CFLAGS="${ARCHFLAGS:-}" LDFLAGS="${ARCHFLAGS:-}" ./configure --prefix="$BUILD_PREFIX" \
        && make -j4 \
        && "${make_install[@]}")
    touch jansson-stamp
}

function pre_build {
    build_pcre2
    #build_zlib
    build_jansson
}

pre_build
