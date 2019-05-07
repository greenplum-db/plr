#!/bin/bash -l

# OSVER : centos6, centos7, ubuntu18

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

source "${TOP_DIR}/gpdb_src/concourse/scripts/common.bash"

function install_pkg() {
case $OSVER in
centos*)
    yum install -y pkgconfig
    ;;
ubuntu*)
    apt update
    apt install -y r-base pkg-config
    ;;
*)
    echo "unknown OSVER = $OSVER"
    exit 1
    ;;
esac
}

function pkg() {
    ## Install R before source greenplum_path
    install_pkg

    [ -f /opt/gcc_env.sh ] && source /opt/gcc_env.sh
    source /usr/local/greenplum-db-devel/greenplum_path.sh

    ## Install R
    if [ "$OSVER" != "ubuntu18" ]; then
    	tar zxf bin_r/bin_r_$OSVER.tar.gz -C /usr/lib64
        export LD_LIBRARY_PATH=/usr/lib64/R/lib64/R/lib:/usr/lib64/R/lib64/R/extlib:$LD_LIBRARY_PATH
        export R_HOME=/usr/lib64/R/lib64/R
	export PATH=/usr/lib64/R/bin/:$PATH
    fi

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
