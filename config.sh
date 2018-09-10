function pre_build {
    mv uwsgi/setup.pyuwsgi.py uwsgi/setup.py
    build_pcre
    build_libyaml
    build_zlib
}

function run_tests {
    pyuwsgi --help
}
