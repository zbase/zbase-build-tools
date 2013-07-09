#!/bin/bash -xe

#   Copyright 2013 Zynga inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

specfile=zbase-zynga.spec
topdir=`pwd`/zbase-build
buildtmp=$topdir/BUILD
export prefix=/opt/zbase
export PREFIX=$buildtmp/$prefix
export LDFLAGS="-L${PREFIX}/lib -Wl,-rpath=$prefix/lib/:$prefix/lib/memcached/"

if [ -d $topdir ];then
    sudo rm -rf $topdir
fi

mkdir -p $topdir/{SRPMS,RPMS,BUILD,SOURCES,SPECS}

if [ -f $specfile ];then
    cp $specfile $topdir/SPECS
    specfile="$topdir/SPECS/$specfile"
else
    echo "No spec file...so exiting"
    exit 1
fi

cd $topdir/SOURCES
if [ -f ../../build.sh ];then
    cp ../../build.sh .
    cp ../../checkout .
    bash -xe ./build.sh
    version=`sed -n "s/#define PACKAGE_VERSION \"\(.*\)\"/\1/p" ep-engine/config.h` 
else
    echo "No build script...so exiting";
    exit 1;
fi

cd ../../
cp scripts/kvstoreconfig.json $PREFIX/
cp scripts/vbucketmigrator.sh $PREFIX/bin/
mkdir -p $buildtmp/etc/init.d/
cp -r scripts/init.d/* $buildtmp/etc/init.d/

echo "Building rpm ..." && \
rpmbuild --define="version $version" --define="buildpath $buildtmp" --define="_topdir $topdir" -ba $specfile --buildroot $buildtmp
