#!/bin/sh -e
TESTDIR=$1
RESULTS=$2
shift 2
TMPLIST=$(mktemp)
find "$TESTDIR" -type f -printf "%p\n" | sort -R | head $* > $TMPLIST
hyperfine --export-json "$RESULTS" -p "echo 3 > /proc/sys/vm/drop_caches; sleep 1" "cat $TMPLIST | xargs cat > /dev/null"
