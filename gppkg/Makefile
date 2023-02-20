SHELL=/bin/bash
R_HOME=$(shell R RHOME)
export R_HOME
R_VER=$(shell R --version | sed -nr 's/.*version\s+([0-9.]+)\s+.*/\1/p')
R_REL=1
export R_VER

# default target
all: gppkg

PGXS := $(shell pg_config --pgxs)
include $(PGXS)

OS=$(word 1,$(subst _, ,$(BLDARCH)))
ARCH=$(shell uname -p)

PLR_DIR=$(shell cd .. && pwd)
export PLR_DIR
include $(PLR_DIR)/gppkg/release.mk

#
# Generic rules to build gppkgs included here
#
ifneq (,$(findstring ubuntu,$(OS)))
include gppkg_deb.mk
else
include gppkg_rpm.mk
endif


.PHONY: gppkg gppkg_spec.yml distro
gppkg: clean gppkg_spec.yml distro

gppkg_spec.yml: gppkg_spec.yml.in
	cat $< | sed "s/#arch/$(ARCH)/g" | sed "s/#os/$(OS)/g" | sed 's/#gpver/$(GP_VERSION_NUM)/g' | sed "s/#gppkgver/$(PLR_VER)/g" > $@

.PHONY: cleanall clean
cleanall: clean

