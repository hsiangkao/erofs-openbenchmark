#!/bin/sh -e

SILESIA_ZIP=".dataset/silesia.zip"
SILESIA_DIR=".dataset/silesia"

if [ ! -d $SILESIA_DIR ]; then
	mkdir -p .dataset
	[ -f "$SILESIA_ZIP" ] || wget -O "$SILESIA_ZIP" https://mattmahoney.net/dc/silesia.zip || exit 1
	unzip "$SILESIA_ZIP" -d"$SILESIA_DIR"
	rm -rf "$SILESIA_ZIP"
fi

FSTYP="$1"
OUTPUT_IMG="$2"

shift 2
echo NAME=$OUTPUT_IMG
echo SECS=$(/bin/time -f'%e' scripts/genimage $FSTYP $OUTPUT_IMG $SILESIA_DIR "$*" 2>&1)
echo SIZE=$(stat -c%s $OUTPUT_IMG)
