#!/bin/sh -e

LOCALSRV=$1
OUTPUT=$3
SNAPSHOTTER=$4

ARGS=""
[ 'x'$SNAPSHOTTER != 'x' ] && ARGS="--snapshotter $SNAPSHOTTER"

prefix=`basename $0`
MATRIX_LOG=`mktemp -q /tmp/${prefix}.XXXXXX`
while IFS= read -r url; do
	TMPFILE=`mktemp -q /tmp/${prefix}.XXXXXX`
	hyperfine -r6 --export-json $TMPFILE -p "nerdctl rmi -f $LOCALSRV/${url##*/}; echo 3 > /proc/sys/vm/drop_caches" \
		"nerdctl run $ARGS -q --rm $LOCALSRV/${url##*/} /bin/sh -c true"
	nerdctl rmi -f "$LOCALSRV/${url##*/}" > /dev/null
	MEAN=$(cat "$TMPFILE" | jq .results[0].mean)
	STDDEV=$(cat "$TMPFILE" | jq .results[0].stddev)
	echo "{\"name\": \"${url##*/}\", \"mean\": $MEAN, \"stddev\": $STDDEV}" | tee -a $MATRIX_LOG
done < $2

echo "[" > $OUTPUT
cat $MATRIX_LOG | sed '2~1 s/^/,/' >> $OUTPUT
echo "]" >> $OUTPUT
{ rm $OUTPUT; jq -c > $OUTPUT; } < $OUTPUT
