#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

# NOTE: Because of the R-3.3.3 requires a minimum zlib 1.2.5, but CentOS6 only have 1.2.3 in the
# official repo, CentOS6 is not supported for now.
function build_r() {
    pushd "$(find r_src -maxdepth 1 -type d -regex ".*R.*")"
    ./configure --prefix=$R_PREFIX --with-x=no --with-readline=no --enable-R-shlib --disable-rpath
    make -j4
    make install

    # Magic to make it work from any directory it is installed into
    # given the fact R_HOME is set
    sed -i "s|${R_PREFIX}/lib64/R|\$\{R_HOME\}|g" $R_PREFIX/bin/R
    sed -i "s|${R_PREFIX}/lib64/R|\$\{R_HOME\}|g" $R_PREFIX/lib64/R/bin/R
    popd

    mkdir -p $R_PREFIX/lib64/R/extlib
    cp /usr/lib64/libgomp.so* $R_PREFIX/lib64/R/extlib # libgomp.so.1.0.0
    cp /usr/lib64/libgfortran.so*  $R_PREFIX/lib64/R/extlib # libgfortran.so.5.0.0
    cp /usr/lib64/libquadmath.so*  $R_PREFIX/lib64/R/extlib # libquadmath.0.0.0
}

function build_plr() {
    pushd plr_src/src
    make USE_PGXS=1 -j4
    popd

    pushd plr_src/gppkg
    make USE_PGXS=1

    mkdir -p "$TOP_DIR/bin_plr"
    # A version-less tarball is needed for the intermediates upload. As well as teh versioned file,
    # which is needed for the release bucket
    tar czf "$TOP_DIR/bin_plr/plr.tar.gz" ./*.gppkg
    popd

}

case "$OS_NAME" in
    rhel*)
        R_PREFIX=/home/gpadmin/R_installation
        export R_HOME=$R_PREFIX/lib64/R
        export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${R_PREFIX}/lib64/R/lib:${R_PREFIX}/lib64/R/extlib
        export PATH=$R_PREFIX/bin/:$PATH
        time build_r
        ;;
    ubuntu*)
        # Just use R from apt repo
        # R_HOME should not be set
        R_PREFIX="$(R RHOME)"
        ;;
    *) echo "Unknown OS: $OS_NAME"; exit 1 ;;
esac

time build_plr
