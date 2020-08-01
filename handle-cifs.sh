#!/bin/sh

line=$1
basedir=$2
remote_directory=$3

WHAT=`echo "$line" |awk '{ print $1 }'`
cifsopt=`echo "$line" |awk '{ print $4 }' |sed -e s/rw,/ro,/g -e s/hard/soft/g -e "s#credentials=#credentials=$basedir#g"`
cifshost=`echo $WHAT |cut -d'/' -f3`
sharename=`echo $WHAT |cut -d'/' -f4- |tr -d '$' |tr '/' '_'`
src=/media/$cifshost-$sharename/mnt
subtarget=$remote_directory/$cifshost-cifs/$sharename
mkdir -p $src $subtarget

if mount -t cifs -o ro,soft,$cifsopt "$WHAT" $src >>$subtarget/rsync.log; then
	logger "copying CIFS=$WHAT (mounted as $src, target directory $subtarget)"
	/opt/drives/internal/rsync-partition.sh $src $subtarget >>$subtarget/rsync.log
fi
