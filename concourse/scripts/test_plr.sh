#!/bin/bash -l

set -exo pipefail

function _main() {
    source /home/gpadmin/gpdb_src/gpAux/gpdemo/gpdemo-env.sh

    local tmp_dir=$(mktemp -d)
    pushd "${tmp_dir}"
    tar xfv /home/gpadmin/bin_plr/plr.tar.gz
    gppkg --install ./*.gppkg
    popd

    source $GPHOME/greenplum_path.sh
    gpstop -ra

    pushd /home/gpadmin/plr_src/src

    MAJOR_VERSION = $(shell grep GP_MAJORVERSION $(shell $(PG_CONFIG) --includedir-server)/pg_config.h | grep -Eo '[0-9]+')
    ifeq ($(MAJOR_VERSION), 7)
        time make USE_PGXS=1 REGRESS_OPTS+=' --schedule=../regress/plr_schedule_7X' installcheck
    else
        time make USE_PGXS=1 REGRESS_OPTS+=' --schedule=../regress/plr_schedule' installcheck
    endif
    popd
}

_main
