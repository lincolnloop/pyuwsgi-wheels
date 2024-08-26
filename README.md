# Wheel Builder for pyuwsgi

If you have an issue with pyuwsgi packaging, this is a good place to create an issue. If you have an issue with operating pyuwsgi, that is probably an issue for [uWSGI](https://github.com/unbit/uwsgi).

Builds are done via [GitHub Actions](https://github.com/lincolnloop/pyuwsgi-wheels/actions).

## Requirements

GNU `make` and a recent version of `setuptools` and `twine`. If you have a virtualenv,

```
pip install -U setuptools twine
```

## Usage

To cut a new release:

1. Update `SERIAL` in `bin/package-version` to add a post-release tag to the upstream uWSGI version
2. Run `make update` to update uWSGI. uWSGI should be pinned to the [latest release](https://github.com/unbit/uwsgi/releases).
3. Push changes and wait for GH Actions to finish.
4. If GH Actions succeeds, tag the commit with the uWSGI version number and push the tag.
5. GH Actions will publish the new release to PyPI
