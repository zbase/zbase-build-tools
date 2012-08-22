#!/bin/bash -xe

if [ ! -f "checkout" ];then
echo "checkout file is missing";
exit 1;
fi

source checkout;

specfile=membase-zynga.spec
topdir=`pwd`/membase-build
buildtmp=$topdir/BUILD
export prefix=/opt/membase
export PREFIX=$buildtmp/$prefix

if [ -d $topdir ];then
sudo rm -rf $topdir
fi

mkdir -p $topdir/{SRPMS,RPMS,BUILD,SOURCES,SPECS}

if [ -f $specfile ];then
cp $specfile $topdir/SPECS
else
echo "No spec file...so exiting"
exit 1
fi

cd $topdir/SOURCES
if [ -f ../../build.sh ];then
cp ../../build.sh .
sh build.sh
version=`sed -n "s/#define PACKAGE_VERSION \"\(.*\)\"/\1/p" ep-engine/config.h` 
else
echo "No build script...so exiting";
exit 1;
fi

cd ..
echo "Building rpm ..." && \
rpmbuild --define="version $version" --define="buildpath $buildtmp" --define="_topdir $topdir" -ba SPECS/$specfile 
