#!/bin/bash -e

set +x

echo 4 > /proc/sys/vm/drop_caches
mount -t tmpfs tmpfs /mnt
mkdir -p /mnt/{test,log}
mount /dev/sda /mnt/log

FSTYP="erofs"
CMD="true"

function escape_args {
  local str=''
  local opt=''
  for c in $1; do
    if [[ "$c" =~ ^[[:alnum:]\.]+=[\"|\'] ]]; then
      if [[ "${c: -1}" =~ [\"|\']  ]]; then
        str="$str $( echo $c | xargs )"
      else
        # first opt chunk
        # entering collector
        opt="$c"
      fi
    else
      if [ -z "$opt" ]; then
        # not inside collector
        str="$str $c"
      else
        # inside collector
        if [[ "${c: -1}" =~ [\"|\']  ]]; then
          # last opt chunk
          # adding collected chunks and this last one to str
          str="$str $( echo "$opt\0040$c" | xargs )"
          # leaving collector
          opt=''
        else
          # middle opt chunk
          opt="$opt\0040$c"
        fi
      fi
    fi
  done
  echo "$str"
}

for x in $(escape_args "`cat /proc/cmdline`"); do
	case "$x" in
		qemubench.fstyp=*)
			FSTYP="${x//qemubench.fstyp=}";;
		qemubench.cmd=*)
			CMD="$(echo -e ${x//qemubench.cmd=})";;
	esac
done

echo "Benchmarking $FSTYP in QEMU..."
mount -t "$FSTYP" -oro /dev/sdb /mnt/test

echo 100000000 > /proc/sys/fs/nr_open
ulimit -n 100000000

sleep 3

set -e
$CMD 1> >(tee /mnt/log/stdout ) 2> >(tee /mnt/log/stderr >&2 ) || \
	{ sync; exit; }
echo 0 > /mnt/log/exitstatus
sync
umount /mnt/log
