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
		"nerdctl run $ARGS --entrypoint /bin/sh -q --rm $LOCALSRV/${url##*/} -c true"
	SIZE="$(nerdctl image ls --format '{{.BlobSize}}' $LOCALSRV/${url##*/})"
	nerdctl rmi -f "$LOCALSRV/${url##*/}" > /dev/null
	MEAN=$(cat "$TMPFILE" | jq .results[0].mean)
	STDDEV=$(cat "$TMPFILE" | jq .results[0].stddev)
	echo "{\"name\": \"${url##*/}\", \"size\": \"$SIZE\", \"mean\": $MEAN, \"stddev\": $STDDEV}" | tee -a $MATRIX_LOG
done < $2

echo "[" > $OUTPUT
cat $MATRIX_LOG | sed '2~1 s/^/,/' >> $OUTPUT
echo "]" >> $OUTPUT
{ rm $OUTPUT; jq -c > $OUTPUT; } < $OUTPUT
