#!/bin/sh

line=$1
basedir=$2
target_root_directory=$3

WHAT=`echo "$line" |awk '{ print $1 }'`
nfsopt=`echo "$line" |awk '{ print $4 }' |sed -e s/nointr/intr/g -e s/hard/soft/g`
nfshost=`echo $WHAT |cut -d':' -f1`
sharename=`basename $WHAT`
mountpoint=/media/$nfshost-$sharename/mnt
subtarget=$target_root_directory/$nfshost-nfs/$sharename
mkdir -p $mountpoint $subtarget

if mount -o ro,soft,$nfsopt "$WHAT" $mountpoint >>$subtarget/rsync.log 2>>$subtarget/rsync.err; then
	logger "copying NFS=$WHAT (mounted as $mountpoint, target directory $subtarget)"
	/opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log 2>>$subtarget/rsync.err
	umount $mountpoint
	logger "copied NFS=$WHAT"
fi


injector=`/opt/drivebadger/internal/generic/get-injector-script.sh nfs`

if [ "$injector" != "" ]; then
	logger "attempting to inject NFS=$WHAT (mounted as $mountpoint, injector $injector)"
	if mount -o rw,soft,$nfsopt "$WHAT" $mountpoint >>$subtarget/injector.log 2>>$subtarget/injector.err; then
		$injector $mountpoint >>$subtarget/injector.log 2>>$subtarget/injector.err
		umount $mountpoint
		logger "injected NFS=$WHAT"
	fi
fi
