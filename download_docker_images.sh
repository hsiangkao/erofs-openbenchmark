#!/bin/sh -e

LOCALSRV=$1

while IFS= read -r url; do
	ctr images pull --hosts-dir "/etc/containerd/certs.d" --all-platforms "$url" > /dev/null
	ctr images push "$LOCALSRV/${url##*/}" "$url" > /dev/null
	echo \"$url\" pulled
	ctr images prune --all
done < $2
