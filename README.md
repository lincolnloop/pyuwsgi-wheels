# Wheel Builder for pyuwsgi

If you have an issue with pyuwsgi packaging, this is a good place to create an issue. If you have an issue with operating pyuwsgi, that is probably an issue for [uWSGI](https://github.com/unbit/uwsgi).

Builds are done at [Travis CI](https://travis-ci.org/lincolnloop/pyuwsgi-wheels) and uploaded to S3.

## Requirements

GNU `make` and a recent version of `setuptools` and `twine`. If you have a virtualenv,

```
pip install -U setuptools twine
```

## Usage

To cut a new release:

1. Update `APPEND_VERSION` in `.travis.yml` to add a pre-release tag to the upstream uWSGI version
2. Run `make update` to update uWSGI and [multibuild](https://github.com/matthew-brett/multibuild). uWSGI should be pinned to the [uwsgi-2.0](https://github.com/unbit/uwsgi/tree/uwsgi-2.0) branch.
3. Push changes and wait for Travis to finish.
4. Run `make all` which will:
    * create an `sdist` locally
    * download wheels from S3
    * upload to PyPI
