#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../
pushd ${TOP_DIR}/plr_src
PLR_VERSION=$(git describe | awk -F. '{printf("%d.%d.%d", $1, $2, $3)}')
popd
function release_gpdb() {
    case "$OSVER" in
    centos6)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-rhel6_x86_64.gppkg
      ;;
    centos7)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-rhel7_x86_64.gppkg
      ;;
    ubuntu18)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-ubuntu18.04_x86_64.gppkg
      ;;
    *) echo "Unknown OS: $OSVER"; exit 1 ;;
  esac
}

function _main() {
	time release_gpdb
}

_main "$@"
