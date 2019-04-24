#!/bin/sh -e
TESTDIR=$1
RESULTS=$2
hyperfine --export-json "$RESULTS" -p "echo 3 > /proc/sys/vm/drop_caches; sleep 1" "tar cf - $TESTDIR | cat > /dev/null"
