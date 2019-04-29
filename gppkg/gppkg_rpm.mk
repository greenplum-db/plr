PGXS := $(shell pg_config --pgxs)
include $(PGXS)

GP_VERSION_NUM := $(GP_MAJORVERSION)

OS=$(word 1,$(subst _, ,$(BLDARCH)))
ARCH=$(shell uname -p)

RPM_ARGS=$(subst -, ,$*)
RPM_NAME=$(word 1,$(RPM_ARGS))
PLR_RPM=plr-$(PLR_VER)-$(PLR_REL).$(ARCH).rpm
PLR_RPM_FLAGS= --define 'plr_dir $(PLR_DIR)/src' --define 'plr_ver $(PLR_VER)' --define 'plr_rel $(PLR_REL)' --define 'r_ver $(R_VER)' --define 'r_dir $(R_HOME)'
TARGET_GPPKG=plr-$(PLR_VER).$(PLR_REL)-$(GPDBVER)-$(ARCH).gppkg
PWD=$(shell pwd)

.PHONY: distro
distro: $(TARGET_GPPKG)

%.rpm:
	echo "PLR=$(PLR_DIR)"
	rm -rf RPMS BUILD SPECS
	mkdir RPMS BUILD SPECS
	cp $(RPM_NAME).spec SPECS/
	rpmbuild -bb SPECS/$(RPM_NAME).spec --buildroot $(PWD)/BUILD --define '_topdir $(PWD)' --define '__os_install_post \%{nil}' --define 'buildarch $(ARCH)' $(PLR_RPM_FLAGS)
	mv RPMS/$(ARCH)/$*.rpm .
	#rm -rf RPMS BUILD SPECS

%.gppkg: $(PLR_RPM) $(DEPENDENT_RPMS)
	mkdir -p gppkg/deps
	cp gppkg_spec.yml gppkg/
	cp $(PLR_RPM) gppkg/
ifdef DEPENDENT_RPMS
	for dep_rpm in $(DEPENDENT_RPMS); do \
		cp $${dep_rpm} gppkg/deps; \
	done
endif
	source $(GPHOME)/greenplum_path.sh && gppkg --build gppkg

clean:
	rm -rf RPMS BUILD SPECS SOURCES SRPMS
	rm -rf gppkg
ifdef EXTRA_CLEAN
	rm -f $(EXTRA_CLEAN)
endif

install: $(TARGET_GPPKG)
	source $(INSTLOC)/greenplum_path.sh && gppkg -i $(TARGET_GPPKG)

.PHONY: install clean
