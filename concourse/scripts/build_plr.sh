#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

source "${TOP_DIR}/gpdb_src/concourse/scripts/common.bash"

function pkg() {
    ## Install R before source greenplum_path
    yum install -y R
    
	source /opt/gcc_env.sh
    source /usr/local/greenplum-db-devel/greenplum_path.sh

    export R_HOME=/usr/lib64/R
    export USE_PGXS=1
    pushd plr_src/src
    make clean
    make
    popd
    pushd plr_src/gppkg
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
