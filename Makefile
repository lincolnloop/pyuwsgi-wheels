MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Figure out what version we're building
UPSTREAM_VERSION := $(shell cd uwsgi; python setup.pyuwsgi.py --version)
# super fragile way of extracting `APPEND_VERSION` from workflow 🤮
APPEND_VERSION := $(shell yq e '.jobs.build_wheels.steps[3].env.CIBW_ENVIRONMENT' .github/workflows/build.yml | cut -d' ' -f1 | cut -d= -f2)
VERSION := $(UPSTREAM_VERSION)$(APPEND_VERSION)
HASH := $(shell cd uwsgi; git rev-parse HEAD)

# Grab a clean checkout of uWSGI
build/$(HASH).tar.gz:
	mkdir -p build
	cd build && curl -sLO https://github.com/unbit/uwsgi/archive/$(HASH).tar.gz

# Patch Python packaging of uWSGI
build/pyuwsgi-$(VERSION): build/$(HASH).tar.gz
	cd build; tar xzf $(HASH).tar.gz
	mv build/uwsgi-$(HASH) build/pyuwsgi-$(VERSION)
	APPEND_VERSION=$(APPEND_VERSION) ./patch-uwsgi-packaging.sh build/pyuwsgi-$(VERSION)
	echo "graft ." > build/pyuwsgi-$(VERSION)/MANIFEST.in

# Create sdist from patched uWSGI
dist/$(VERSION)/pyuwsgi-$(VERSION).tar.gz: build/pyuwsgi-$(VERSION)
	mkdir -p dist/$(VERSION)
	cd build/pyuwsgi-$(VERSION); python setup.py sdist
	mv build/pyuwsgi-$(VERSION)/dist/pyuwsgi-$(VERSION).tar.gz $@

.PHONY: sdist
sdist: dist/$(VERSION)/pyuwsgi-$(VERSION).tar.gz

.PHONY: upload
upload:
	twine upload dist/$(VERSION)/*

.PHONY: all
all: dist/$(VERSION) upload

.PHONY: update
update:
	cd uwsgi; git pull


.PHONY: clean
clean:
	rm -rf ./dist ./build

