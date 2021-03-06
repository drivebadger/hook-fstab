#!/bin/sh

base=$1
target_root_directory=$2

if [ -f "$base/etc/fstab" ]; then
	logger "found $base/etc/fstab, processing possible nfs/cifs filesystems"
	grep -v "^#" "$base/etc/fstab" |grep -v ^$ |grep -v swap |grep -v tmpfs |grep -v UUID= |grep -v ^/dev/ |while read line; do
		FS=`echo "$line" |awk '{ print $3 }'`

		if [ "$FS" = "cifs" ] || [ "$FS" = "smbfs" ]; then
			nohup /opt/drives/hooks/fstab/handle-cifs.sh "$line" "$base" $target_root_directory &
		elif [ "$FS" = "nfs" ] || [ "$FS" = "nfs4" ]; then
			nohup /opt/drives/hooks/fstab/handle-nfs.sh "$line" "$base" $target_root_directory &
		else
			logger "skipping FS=$FS (not implemented: $line)"
		fi
	done
fi
