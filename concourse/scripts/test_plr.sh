#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../
GPDB_CONCOURSE_DIR=${TOP_DIR}/gpdb_src/concourse/scripts

source "${GPDB_CONCOURSE_DIR}/common.bash"
function prepare_test(){	

	cat > /home/gpadmin/test.sh <<-EOF
		set -exo pipefail

        source ${TOP_DIR}/gpdb_src/gpAux/gpdemo/gpdemo-env.sh
        source /usr/local/greenplum-db-devel/greenplum_path.sh
		gppkg -i bin_plr/plr-*.gppkg || exit 1
        source /usr/local/greenplum-db-devel/greenplum_path.sh
        gpstop -arf

        pushd plr_src/src
        
		make USE_PGXS=1 installcheck

        [ -s regression.diffs ] && cat regression.diffs && exit 1
        popd

	EOF

	chown -R gpadmin:gpadmin $(pwd)
	chown gpadmin:gpadmin /home/gpadmin/test.sh
	chmod a+x /home/gpadmin/test.sh

}

function test() {
	su gpadmin -c "bash /home/gpadmin/test.sh $(pwd)"

    case "$OSVER" in
    suse11)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-2.3.0-$GPDBVER-sles11-x86_64.gppkg
      ;;
    centos6)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-2.3.0-$GPDBVER-rhel6-x86_64.gppkg
      ;;
    centos7)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-2.3.0-$GPDBVER-rhel7-x86_64.gppkg
      ;;
    *) echo "Unknown OS: $OSVER"; exit 1 ;;
  esac
}

function setup_gpadmin_user() {
    case "$OSVER" in
        suse*)
        ${GPDB_CONCOURSE_DIR}/setup_gpadmin_user.bash "sles"
        ;;
        centos*)
        ${GPDB_CONCOURSE_DIR}/setup_gpadmin_user.bash "centos"
        ;;
        *) echo "Unknown OS: $OSVER"; exit 1 ;;
    esac
	
}

function install_R()
{
	yum install -y R
}

function _main() {
	time install_R
	time install_gpdb
	time setup_gpadmin_user

	time make_cluster
	time prepare_test
    time test
}

_main "$@"
