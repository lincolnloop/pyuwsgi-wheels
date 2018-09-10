function pre_build {
    mv uwsgi/setup.pyuwsgi.py uwsgi/setup.py
    sed 's/uwsgiconfig\.uwsgi_version/uwsgiconfig.uwsgi_version + "'$APPEND_VERSION'"/' uwsgi/setup.pyuwsgi.py
    build_pcre
    build_libyaml
    build_zlib
}

function run_tests {
    pyuwsgi --help
}
