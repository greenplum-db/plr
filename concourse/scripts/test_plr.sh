#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

function install_gppkg() {
    if [[ ${GP_MAJOR_VERSION} == "7" ]]; then
        "${TOP_DIR}/bin_gppkg_v2/gppkg" install -a ./*.gppkg
    else
	gppkg --install ./*.gppkg
    fi
}

function uninstall_gppkg() {
    if [[ ${GP_MAJOR_VERSION} == "7" ]]; then
        "${TOP_DIR}/bin_gppkg_v2/gppkg" remove -a plr
    else
	gppkg --remove plr
    fi
}

function _main() {
    source /home/gpadmin/gpdb_src/gpAux/gpdemo/gpdemo-env.sh

    local tmp_dir=$(mktemp -d)
    pushd "${tmp_dir}"
    tar xfv /home/gpadmin/bin_plr/plr.tar.gz
    install_gppkg
    popd

    source "$GPHOME/greenplum_path.sh"
    gpstop -ra

    pushd /home/gpadmin/plr_src/src
    time make USE_PGXS=1 installcheck
    popd

    pushd "${tmp_dir}"
    uninstall_gppkg
    install_gppkg
    popd
}

_main
