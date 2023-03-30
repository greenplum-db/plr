#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

function _main() {
    source /home/gpadmin/gpdb_src/gpAux/gpdemo/gpdemo-env.sh

    local tmp_dir=$(mktemp -d)
    pushd "${tmp_dir}"
    tar xfv /home/gpadmin/bin_plr/plr.tar.gz
    if [[ ${GPDB_VERSION} == "7" ]]; then
        ${TOP_DIR}/bin_gppkg_v2/gppkg install -a ./*.gppkg
    else
	gppkg --install ./*.gppkg
    fi
    popd

    # FIXME: Remove this when https://github.com/greenplum-db/gpdb/pull/15254 is released
    sed -i "s|for env.*do|for env in \$(find \"\${GPHOME}/etc/environment.d\" -regextype sed -regex '.*\\\/[0-9][0-9]-.*\\\.conf\$' -type f \| sort -n); do|g" \
        $GPHOME/greenplum_path.sh
    source $GPHOME/greenplum_path.sh
    gpstop -ra

    pushd /home/gpadmin/plr_src/src

    time make USE_PGXS=1 installcheck
    popd
}

_main
