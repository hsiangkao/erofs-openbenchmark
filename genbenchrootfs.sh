#!/bin/sh -e
mkdir -p .output
scripts/genrootfs .output/vmrootfs.erofs ./bench-packages bench-overlay ""
