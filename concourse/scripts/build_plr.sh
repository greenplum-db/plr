#!/bin/bash -l

# OSVER : centos6, centos7, ubuntu18

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

source "${TOP_DIR}/gpdb_src/concourse/scripts/common.bash"

function install_R() {
case $OSVER in
centos*)
	yum install -y R
	export R_HOME=/usr/lib64/R
	;;
ubuntu*)
	apt update
	apt install -y r-base
	export R_HOME=/usr/lib/R
	;;
*)
	echo "unknown OS = $OS"
	;;
esac
}

function pkg() {
    ## Install R before source greenplum_path
    install_R
    which R
    echo "R_HOME='$R_HOME'"
    
    source /opt/gcc_env.sh
    source /usr/local/greenplum-db-devel/greenplum_path.sh

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
