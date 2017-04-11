ifneq (,${R_HOME})

SHELL=/bin/bash
all: gppkg

PGXS := $(shell pg_config --pgxs)
include $(PGXS)

OS=$(word 1,$(subst _, ,$(BLD_ARCH)))
ARCH=$(shell uname -p)

PLR_DIR=$(shell cd .. && pwd)
include $(PLR_DIR)/release.mk

R_RPM_FLAGS="--define 'r_dir $(R_HOME)' --define 'r_ver $(R_VER)' --define 'r_rel $(R_REL)'"
R_RPM=R-$(R_VER)-$(R_REL).$(ARCH).rpm

PLR_GPPKG_VER=$(PLR_VER)-$(PLR_REL)-GPBD-$(GP_VERSION)
GPPKG_VERSION=$(PLR_GPPKG_VER)
PLR_RPM_FLAGS="--define 'plr_dir $(PLR_DIR)' --define 'plr_ver $(PLR_VER)' --define 'plr_rel $(PLR_REL)' --define 'r_ver $(R_VER)' --define 'r_dir $(R_HOME)'"
PLR_RPM=plr-$(PLR_VER)-$(PLR_REL).$(ARCH).rpm
PLR_GPPKG=plr-$(PLR_GPPKG_VER)-$(OS)-$(ARCH).gppkg

TARGET_GPPKG=$(PLR_GPPKG)
EXTRA_CLEAN+=$(R_RPM) $(PLR_RPM) $(PLR_GPPKG)

#
# Generic rules to build gppkgs included here
#
include gppkg.mk

.PHONY: gppkg
gppkg: 
	$(MAKE) $(R_RPM) RPM_FLAGS=$(R_RPM_FLAGS)
	PATH=$(INSTLOC)/bin:$(PATH) $(MAKE) $(PLR_RPM) RPM_FLAGS=$(PLR_RPM_FLAGS)
	$(MAKE) $(PLR_GPPKG) MAIN_RPM=$(PLR_RPM) DEPENDENT_RPMS=$(R_RPM)

.PHONY: cleanall
cleanall: clean
	rm -rf BUILDROOT
	rm -rf SOURCES
	rm -rf SRPMS
	rm -rf $(R_RPM)
	rm -rf $(PLR_RPM)
	rm -rf $(PLR_GPPKG)

else

all:
	@echo ""; \
	 echo "*** Cannot build PL/R because R_HOME cannot be found." ; \
	 echo "*** Refer to the documentation for details."; \
	 echo ""

endif
