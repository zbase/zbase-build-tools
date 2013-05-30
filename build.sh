#!/bin/bash -xe
echo "prefix is $PREFIX"
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=$C_INCLUDE_PATH
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath=$prefix/lib/:$prefix/lib/memcached/"
export LD_LIBRARY_PATH=${PREFIX}/lib/
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

echo "Using $PREFIX for staging the build. Cleaning it up.."
/bin/rm -rf $PREFIX


echo "Building google-perftools for tcmalloc"
wget --no-check-certificate http://gperftools.googlecode.com/files/gperftools-2.0.tar.gz
tar -xvf gperftools-2.0.tar.gz
pushd gperftools-2.0
./configure --prefix=$PREFIX --enable-minimal
make
make install-am
popd
sudo /sbin/ldconfig -n $PREFIX/lib

echo "Building jemalloc"
wget --no-check-certificate http://www.canonware.com/download/jemalloc/jemalloc-3.2.0.tar.bz2
bunzip2 jemalloc-3.2.0.tar.bz2
tar -xvf jemalloc-3.2.0.tar
pushd jemalloc-3.2.0
./configure --prefix=$PREFIX
make
make install
popd
sudo /sbin/ldconfig -n $PREFIX/lib

echo "Building libevent"
wget --no-check-certificate https://github.com/downloads/libevent/libevent/libevent-2.0.16-stable.tar.gz
tar -xvf libevent-2.0.16-stable.tar.gz
pushd libevent-2.0.16-stable
./configure --prefix=$PREFIX
make
make install
popd
sudo /sbin/ldconfig -n $PREFIX/lib

export LIBS='-ljemalloc -levent'
echo "Linking to the newly built jemalloc and libevent for all executables built from now on"

echo "Build curl"
wget http://curl.haxx.se/download/curl-7.24.0.tar.gz
tar -xvf curl-7.24.0.tar.gz
pushd curl-7.24.0
./configure --prefix=$PREFIX --with-check=no
make
make install
popd
sudo /sbin/ldconfig -n $PREFIX/lib

echo "Building memached"
git clone git@github-ca.corp.zynga.com:$MEMCACHED_REPO/memcached.git
pushd memcached
git checkout $MEMCACHED_CID
git clean -xfd
./config/autorun.sh
./configure --prefix=$PREFIX --enable-isasl --with-libevent=$PREFIX --no-create --no-recursion
./config.status
make
make install
popd
sudo /sbin/ldconfig -n $PREFIX/lib

echo "Building ep-engine"
git clone git@github-ca.corp.zynga.com:$EP_ENGINE_REPO/ep-engine.git
pushd ep-engine 
git checkout $EP_ENGINE_CID
git clean -xfd
./config/autorun.sh
./configure --prefix=$PREFIX --with-memcached=$PREFIX --no-create --no-recursion
./config.status
make
make install
popd
sudo /sbin/ldconfig -n $PREFIX/lib

echo "Building vbucketmigrator"
git clone git@github-ca.corp.zynga.com:$VBUCKETMIGRATOR_REPO/vbucketmigrator.git
pushd vbucketmigrator 
git checkout $VBUCKETMIGRATOR_CID
git clean -xfd
./config/autorun.sh
LIBS="" ./configure --prefix=$PREFIX --with-memcached=$PREFIX --with-sasl=no --disable-sasl
./config.status
make
make install
popd
sudo /sbin/ldconfig -n $PREFIX/lib

echo "Building libmemcached"
git clone git@github-ca.corp.zynga.com:membase/libmemcached.git
pushd libmemcached 
git clean -xfd
./config/autorun.sh
./configure --prefix=$PREFIX --enable-isasl --with-libevent=$PREFIX --with-memcached=$PREFIX/bin/memcached
./config.status
make
make install
popd
sudo /sbin/ldconfig -n $PREFIX/lib
