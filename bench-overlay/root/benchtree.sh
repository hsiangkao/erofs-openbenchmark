#!/bin/sh -e
TESTDIR=$1
RESULTS=$2
TMPLIST=$(mktemp)
shift 2
find "$TESTDIR" -type f -printf "%p\n" | sort -R > $TMPLIST
hyperfine $* --export-json "$RESULTS" -p "echo 3 > /proc/sys/vm/drop_caches; sleep 1; echo 3 > /proc/sys/vm/drop_caches; sleep 1"\
	"tar cf - $TESTDIR | cat > /dev/null"\
	"tar cf /dev/null $TESTDIR"\
	"cat $TMPLIST | xargs cat > /dev/null"\
	"cat $TMPLIST | xargs stat"
