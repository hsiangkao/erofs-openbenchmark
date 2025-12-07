#!/bin/sh -e

DEBIAN_TAG="trixie-20251117"
DEBIAN_DIR=".dataset/debian"
DEBIAN_EROFS=".dataset/debian.erofs"

if [ ! -d $DEBIAN_DIR ]; then
	mkdir -p .dataset
	mkfs.erofs --oci=platform=linux/amd64,layer=0 -Uclear -T0 --mkfs-time $DEBIAN_EROFS debian:$DEBIAN_TAG
        fsck.erofs --extract=$DEBIAN_DIR $DEBIAN_EROFS
	rm -rf "$DEBIAN_EROFS"
fi

FSTYP="$1"
OUTPUT_IMG="$2"

shift 2
echo NAME=$OUTPUT_IMG
echo SECS=$(/bin/time -f'%e' scripts/genimage $FSTYP $OUTPUT_IMG $DEBIAN_DIR "$*" 2>&1)
echo SIZE=$(stat -c%s $OUTPUT_IMG)
