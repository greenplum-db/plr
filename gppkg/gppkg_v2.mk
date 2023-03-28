# need VARS: OS ARCH PLR_DIR
# Set PACK_R=true to include R in the gppkg
# GP_MAJORVERSION is defined in lib/postgresql/pgxs/src/Makefile.global
GP_VERSION_NUM := $(GP_MAJORVERSION)

PWD=$(shell pwd)
TARGET_GPPKG=plr-$(PLR_VER)-gp$(GP_VERSION_NUM)-$(OS)-$(ARCH).gppkg
ifeq ($(GPPKG),)
GPPKG=gppkg
endif

.PHONY: distro
distro: $(TARGET_GPPKG)

gppkg_spec_v2.yml: gppkg_spec_v2.yml.in
	cat $< | sed "s/#arch/$(ARCH)/g" | sed "s/#os/$(OS)/g" | sed 's/#gpver/$(GP_VERSION_NUM)/g' | sed "s/#gppkgver/$(PLR_VER)-$(PLR_REL)/g" > $@

%.gppkg: gppkg_spec_v2.yml
	rm -rf gppkg_build 2>/dev/null
	mkdir -p gppkg_build/files
	$(MAKE) -C $(PLR_DIR)/src install \
		USE_PGXS=1 \
		DESTDIR=$(PWD)/gppkg_build/files \
		libdir=/lib/postgresql \
		pkglibdir=/lib/postgresql \
		datadir=/share/postgresql \
		gpetcdir=/etc \
		docdir=/share/doc/postgresql/
ifeq ($(PACK_R), true)
	mkdir -p gppkg_build/files/ext/R-$(R_VER)
	cp -RL $(R_HOME)/* gppkg_build/files/ext/R-$(R_VER)
	cat $< | sed "s/#r_ver/$(R_VER)/g" > gppkg_build/30-plr.conf
	mkdir -p gppkg_build/files/etc/environment.d
	cp gppkg_build/30-plr.conf gppkg_build/files/etc/environment.d
endif
	$(GPPKG) build \
		--input $(PWD)/gppkg_build/files \
		--config gppkg_spec_v2.yml \
		--output $(TARGET_GPPKG)

clean:
	rm -rf gppkg_build
	rm -f gppkg_spec_v2.yml
	rm -f $(TARGET_GPPKG)

install: $(TARGET_GPPKG)
	$(GPPKG) install -a $(TARGET_GPPKG)

.PHONY: install clean
