#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../
PLR_VERSION=$(git describe | awk -F. '{printf("%d.%d.%d", $1, $2, $3)}')
function release_gpdb5() {
    case "$OSVER" in
    suse11)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-sles11-x86_64.gppkg
      ;;
    centos6)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-rhel6-x86_64.gppkg
      ;;
    centos7)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-rhel7-x86_64.gppkg
      ;;
    *) echo "Unknown OS: $OSVER"; exit 1 ;;
  esac
}

function release_gpdb4() {
    case "$OSVER" in
    suse11)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-sles11-x86_64.gppkg
      ;;
    centos5)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-rhel5-x86_64.gppkg
      ;;
    centos6)
        cp bin_plr/plr-*.gppkg plr_gppkg/plr-$PLR_VERSION-$GPDBVER-rhel6-x86_64.gppkg
      ;;
    *) echo "Unknown OS: $OSVER"; exit 1 ;;
    esac
}

function _main() {
    case "$GPDBVER" in
        GPDB4.3)
        time release_gpdb4
        ;;
        gp5)
        time release_gpdb5
        ;;
        *) echo "Unknown GPDB Version: $GPDBVER"; exit 1 ;;
    esac
}

_main "$@"
