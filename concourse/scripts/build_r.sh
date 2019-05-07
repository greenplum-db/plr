#!/bin/bash -l

set -exo pipefail

CWDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TOP_DIR=${CWDIR}/../../../

if [ "$OSVER" == "suse11" ]; then
    zypper addrepo http://download.opensuse.org/distribution/11.4/repo/oss/ oss
    zypper --no-gpg-checks -n install -f binutils
    zypper --no-gpg-checks -n install subversion
    zypper --no-gpg-checks -n install gcc gcc-c++ gcc-fortran
    zypper --no-gpg-checks -n install texlive
    zypper --no-gpg-checks -n install texlive-latex
    zypper --no-gpg-checks -n install libopenssl-devel openssl
    zypper --no-gpg-checks -n install wget
elif [ "$OSVER" == "ubuntu18" ]; then
    apt-get update
    apt-get install -y texlive
    apt-get install -y wget
    apt-get install -y build-essential gfortran
else
    yum install -y subversion
    yum install -y gcc gcc-c++ gcc-gfortran
    yum install -y 'texlive-*'
    yum install -y wget
fi


# Zlib dependency
pushd ${TOP_DIR}/zlib 
tar zxf zlib-1.2.8.tar.gz
pushd zlib-1.2.8
./configure --prefix=/usr/local/lib64/zlib
make -j
make install
export LD_LIBRARY_PATH=/usr/local/lib64/zlib/lib:$LD_LIBRARY_PATH
export CFLAGS="$CFLAGS -I/usr/local/lib64/zlib/include"
popd
popd


# BZip2 dependency
pushd ${TOP_DIR}/bzip2
#wget http://www.bzip.org/1.0.6/bzip2-1.0.6.tar.gz
tar zxf bzip2-1.0.6.tar.gz
pushd bzip2-1.0.6
make -f Makefile-libbz2_so
make -j
make install PREFIX=/usr/local/lib64/bzip2
ln -s libbz2.so.1.0.6 libbz2.so.1
ln -s libbz2.so.1     libbz2.so
cp libbz2.so* /usr/local/lib64/bzip2/lib
export LD_LIBRARY_PATH=/usr/local/lib64/bzip2/lib:$LD_LIBRARY_PATH
export CFLAGS="$CFLAGS -I/usr/local/lib64/bzip2/include"
popd
popd

# LZMA dependency
pushd ${TOP_DIR}/xz
tar zxf xz-5.2.2.tar.gz
pushd xz-5.2.2
cp ${TOP_DIR}/plr_src/concourse/scripts/xz.patch ./src/liblzma/liblzma.map
./configure --prefix=/usr/local/lib64/xz
make -j
make install
export LD_LIBRARY_PATH=/usr/local/lib64/xz/lib:$LD_LIBRARY_PATH
export CFLAGS="$CFLAGS -I/usr/local/lib64/xz/include"
popd
popd

# PCRE dependency
wget ftp://ftp.pcre.org/pub/pcre/pcre-8.39.tar.gz
tar zxf pcre-8.39.tar.gz
pushd pcre-8.39
./configure --enable-utf --enable-unicode-properties --enable-jit --disable-cpp --prefix=/usr/local/lib64/pcre
make -j
make install
export LD_LIBRARY_PATH=/usr/local/lib64/pcre/lib:$LD_LIBRARY_PATH
export CFLAGS="$CFLAGS -I/usr/local/lib64/pcre/include"
popd

# Texinfo for building documentation
wget http://ftp.gnu.org/gnu/texinfo/texinfo-6.1.tar.gz
tar zxf texinfo-6.1.tar.gz
pushd texinfo-6.1
./configure --prefix=/usr/local/lib64/texinfo
make -j
make install
popd
export PATH=/usr/local/lib64/texinfo/bin/:$PATH

if [ "$OSVER" == "suse11" ]; then
    # Neon to make SVN work in SUSE
    wget  --no-check-certificate https://src.fedoraproject.org/repo/pkgs/neon/neon-0.30.0.tar.gz/fb60b3a124eeec441937a812c456fd94/neon-0.30.0.tar.gz
    tar zxf neon-0.30.0.tar.gz
    pushd neon-0.30.0
    ./configure --prefix=/usr/local/lib64/neon --enable-shared --with-ssl=openssl
    make -j
    make install
    popd
    export LD_LIBRARY_PATH=/usr/local/lib64/neon/lib:$LD_LIBRARY_PATH

    # Curl
    wget --no-check-certificate http://curl.askapache.com/download/curl-7.54.1.tar.gz
    tar zxf curl-7.54.1.tar.gz
    pushd curl-7.54.1
    ./configure --prefix=/usr/local/lib64/curl --disable-ldap --disable-ldaps
    make -j
    make install
    popd
    export LD_LIBRARY_PATH=/usr/local/lib64/curl/lib:$LD_LIBRARY_PATH
    export PATH=/usr/local/lib64/curl/bin/:$PATH
fi

export LIBRARY_PATH=$LD_LIBRARY_PATH

wget --no-check-certificate https://cran.r-project.org/src/base/R-3/R-3.3.3.tar.gz
tar -zxf R-3.3.3.tar.gz
pushd R-3.3.3
source ${TOP_DIR}/plr_src/gppkg/release.mk
DOENLOADRVER=`cat VERSION`
if [ "$R_VER" == "$DOENLOADRVER" ]; then
	echo "R verion match, require $R_VER, current is $DOENLOADRVER"
else
	echo "R version is not match, require $R_VER, current is $DOENLOADRVER "
	exit 1
fi
./tools/rsync-recommended
./configure --prefix=/usr/lib64/R --with-x=no --with-readline=no --enable-R-shlib --disable-rpath
make -j
make install
popd

# Magic to make it work from any directory it is installed into
# given the fact R_HOME is set

if [ "$OSVER" == "ubuntu18" ]; then
    sed -i 's/\/usr\/lib64\/R\/lib\/R/${R_HOME}/g' /usr/lib64/R/bin/R
    sed -i 's/\/usr\/lib64\/R\/lib\/R/${R_HOME}/g' /usr/lib64/R/lib/R/bin/R
else
    sed -i 's/\/usr\/lib64\/R\/lib64\/R/${R_HOME}/g' /usr/lib64/R/bin/R
    sed -i 's/\/usr\/lib64\/R\/lib64\/R/${R_HOME}/g' /usr/lib64/R/lib64/R/bin/R
fi

mkdir /usr/lib64/R/lib64/R/extlib
cp /usr/local/lib64/zlib/lib/libz.so.1      /usr/lib64/R/lib64/R/extlib
cp /usr/local/lib64/xz/lib/liblzma.so.5     /usr/lib64/R/lib64/R/extlib
cp /usr/local/lib64/pcre/lib/libpcre.so.1   /usr/lib64/R/lib64/R/extlib

case $OSVER in
    centos6)
        cp /usr/local/lib64/bzip2/lib/libbz2.so.1.0 /usr/lib64/R/lib64/R/extlib
#        cp /usr/local/curl/lib/libcurl.so.4         /usr/lib64/R/lib64/R/extlib
        cp /usr/lib64/libgomp.so.1                  /usr/lib64/R/lib64/R/extlib
        cp /usr/lib64/libgfortran.so.3              /usr/lib64/R/lib64/R/extlib
#        cp /usr/lib64/libssl.so.10                  /usr/lib64/R/lib64/R/extlib
#        cp /usr/lib64/libcrypto.so.10               /usr/lib64/R/lib64/R/extlib
    ;;
    centos7)
        cp /usr/local/lib64/bzip2/lib/libbz2.so.1.0 /usr/lib64/R/lib64/R/extlib
#        cp /usr/local/curl/lib/libcurl.so.4         /usr/lib64/R/lib64/R/extlib
        cp /usr/lib64/libgomp.so.1                  /usr/lib64/R/lib64/R/extlib
        cp /usr/lib64/libgfortran.so.3              /usr/lib64/R/lib64/R/extlib
#        cp /usr/lib64/libssl.so.10                  /usr/lib64/R/lib64/R/extlib
#        cp /usr/lib64/libcrypto.so.10               /usr/lib64/R/lib64/R/extlib
        cp /usr/lib64/libquadmath.so.0              /usr/lib64/R/lib64/R/extlib
    ;;
    suse*)
        cp /usr/local/lib64/bzip2/lib/libbz2.so.1   /usr/lib64/R/lib64/R/extlib
 #       cp /usr/local/lib64/curl/lib/libcurl.so.4   /usr/lib64/R/lib64/R/extlib
        cp /usr/lib64/libgomp.so.1        /usr/lib64/R/lib64/R/extlib
        cp /usr/lib64/libgfortran.so.3    /usr/lib64/R/lib64/R/extlib
#        cp /lib64/libssl.so.1.0.0                   /usr/lib64/R/lib64/R/extlib
#        cp /lib64/libcrypto.so.1.0.0                /usr/lib64/R/lib64/R/extlib
    ;;
esac

pushd /usr/lib64
tar zcvf bin_r_$OSVER.tar.gz ./R
popd
cp /usr/lib64/bin_r_$OSVER.tar.gz $TOP_DIR/bin_r/
