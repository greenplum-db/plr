PGXS := $(shell pg_config --pgxs)
include $(PGXS)

GP_VERSION_NUM := $(GP_MAJORVERSION)

OS=$(word 1,$(subst _, ,$(BLD_ARCH)))
ARCH=$(shell uname -p)

ifeq ($(ARCH),x86_64)
ARCH=amd64
endif

include release.mk
PLR_DEB=plr-$(PLR_VER)-$(PLR_REL).$(ARCH).deb

PWD=$(shell pwd)

.PHONY: distro
distro: $(TARGET_GPPKG)

%.deb:
	rm -rf UBUNTU 2>/dev/null
	mkdir UBUNTU/DEBIAN -p
	cat $(PWD)/$(CONTROL_NAME) | sed -r "s|#version|$(PLR_VER)-$(PLR_REL)|" | sed -r "s|#arch|$(ARCH)|" > $(PWD)/UBUNTU/DEBIAN/control
	$(MAKE) -C $(PLR_DIR) install DESTDIR=$(PWD)/UBUNTU libdir=/lib/postgresql pkglibdir=/lib/postgresql datadir=/share/postgresql
	dpkg-deb --build $(PWD)/UBUNTU "$(PLR_DEB)"

%.gppkg: $(PLR_DEB) $(DEPENDENT_DEBS)
	rm -rf gppkg
	mkdir -p gppkg/deps
	cp gppkg_spec.yml gppkg/
	cp $(PLR_DEB) gppkg/
ifdef DEPENDENT_DEBS
	for dep_deb in $(DEPENDENT_DEBS); do \
		cp $${dep_deb} gppkg/deps; \
	done
endif
	gppkg --build gppkg

clean:
	rm -rf UBUNTU
	rm -rf gppkg
	rm -f gppkg_spec.yml
