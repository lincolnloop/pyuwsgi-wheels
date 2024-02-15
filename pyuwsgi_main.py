import os
import sys

# we import `pyuwsgi` with `dlopen` flags set to `os.RTLD_GLOBAL` such that
# uwsgi plugins can discover uwsgi's globals (notably `extern ... uwsgi`)
if hasattr(sys, 'setdlopenflags'):
    orig = sys.getdlopenflags()
    try:
        sys.setdlopenflags(orig | os.RTLD_GLOBAL)
        import pyuwsgi
    finally:
        sys.setdlopenflags(orig)
else:  # ah well, can't control how dlopen works here
    import pyuwsgi

run = pyuwsgi.run
