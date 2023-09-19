#!/usr/bin/env bash

set -ex

# R will be shipped in the plr gppkg for rhel, since those don't have R in the officail repo.
# For ubuntu, just use the r-base from apt source.
function install_build_deps() {
    case "$OS_NAME" in
        rhel*)
            yum install -y gcc-gfortran pcre-devel
            ;;
        ubuntu*)
            apt update
            DEBIAN_FRONTEND=noninteractive apt install -y r-base
            ;;
        *) echo "Unknown OS: $OS_NAME"; exit 1 ;;
    esac
}

install_build_deps

# Needed by gppkg Makefile
BLDARCH="${OS_NAME}_x86_64"
{
    echo "export BLDARCH=$BLDARCH"
} >>/home/gpadmin/.bashrc

