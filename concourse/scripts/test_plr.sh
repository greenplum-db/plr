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
    time make USE_PGXS=1 installcheck
    popd
}

_main
