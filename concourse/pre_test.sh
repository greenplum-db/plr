#!/usr/bin/env bash

set -ex

source "$CI_REPO_DIR/common/entry_common.sh"

function install_test_deps() {
    case "$OS_NAME" in
        rhel*)
            ;;
        ubuntu*)
            apt update
            DEBIAN_FRONTEND=noninteractive apt install -y r-base
            ;;
        *) echo "Unknown OS: $OS_NAME"; exit 1 ;;
    esac
}

install_test_deps
start_gpdb

