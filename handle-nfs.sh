#!/bin/sh

line=$1
basedir=$2
target_root_directory=$3

WHAT=`echo "$line" |awk '{ print $1 }'`
nfsopt=`echo "$line" |awk '{ print $4 }' |sed -e s/nointr/intr/g -e s/hard/soft/g`
nfshost=`echo $WHAT |cut -d':' -f1`
sharename=`basename $WHAT`
src=/media/$nfshost-$sharename/mnt
subtarget=$target_root_directory/$nfshost-nfs/$sharename
mkdir -p $src $subtarget

if mount -o ro,soft,$nfsopt "$WHAT" $src >>$subtarget/rsync.log; then
	logger "copying NFS=$WHAT (mounted as $src, target directory $subtarget)"
	/opt/drivebadger/internal/generic/rsync-partition.sh $src $subtarget >>$subtarget/rsync.log
fi
