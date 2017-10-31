#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

if [ "$GPDBVER" == "GPDB4.3" ]; then
    source "${TOP_DIR}/gpdb_src/ci/concourse/scripts/common.bash"
else
    source "${TOP_DIR}/gpdb_src/concourse/scripts/common.bash"
fi
function pkg() {
    source /opt/gcc_env.sh
    source /usr/local/greenplum-db-devel/greenplum_path.sh

    ## Install R
    tar zxf bin_r/bin_r_$OSVER.tar.gz -C /usr/lib64

    export LD_LIBRARY_PATH=/usr/lib64/R/lib64/R/lib:/usr/lib64/R/lib64/R/extlib:$LD_LIBRARY_PATH

    export R_HOME=/usr/lib64/R/lib64/R
    export USE_PGXS=1
    pushd plr_src/src
    make clean
    make
    popd
    pushd plr_src/gppkg
    if [ "$GPDBVER" == "GPDB4.3" ]; then
       sed -i 's/extension/contrib/g' gppkg_spec.yml.in
    fi
    make cleanall
    make
    popd
    
    cp plr_src/gppkg/plr-*.gppkg bin_plr/plr-$OSVER.gppkg
	
}

function _main() {	
	time install_gpdb
	time pkg
}

_main "$@"
