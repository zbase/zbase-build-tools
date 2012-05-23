#!/bin/sh
export MEMCACHED_CID=membase-1.7.1.1-3-g185ce38
export EP_ENGINE_CID=1.7.3r-23
export VBUCKETMIGRATOR_CID=0fdc96cafc7227d52cbf4682ba7462923b773dae

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
