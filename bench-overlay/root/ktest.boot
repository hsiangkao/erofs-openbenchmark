#!/bin/bash -e

set +x

echo 4 > /proc/sys/vm/drop_caches
mount -t tmpfs tmpfs /mnt
mkdir -p /mnt/{test,log}
mount /dev/sda /mnt/log

FSTYP="erofs"
CMD="true"
for x in `cat /proc/cmdline`; do
	case $x in
		qemubench.fstype=*)
			FSTYP="${x//qemubench.fstype=}";;
		qemubench.cmd=*)
			CMD="${x//qemubench.cmd=}";;
	esac
done

printf "Benchmarking $FSTYP in QEMU..."
mount -t "$FSTYP" -oro /dev/sdb /mnt/test

echo 100000000 > /proc/sys/fs/nr_open
ulimit -n 100000000

set -e
timeout -k30 $TIMEOUT stdbuf -o0 -e0 "$CMD" 1> >(tee /mnt/log/stdout ) 2> >(tee /mnt/log/stderr >&2 ) || \
	[ $? -ne 124 ] && { sync; exit; }
echo 0 > /mnt/log/exitstatus
sync
umount /mnt/log
