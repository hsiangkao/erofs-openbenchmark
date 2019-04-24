#!/bin/sh -e

cpus=$(nproc --all)
mem="768M"
if [ -e /dev/kvm ]; then
echo Trying to use KVM...
kvm="--enable-kvm -cpu host"
else
kvm="--accel tcg,thread=multi"
fi

KERNEL=$1
VMROOTFS=$2
TESTDEV=$3
FSTYP=$4
OUTDIR=$5
shift 5
TESTCMDS=$*

fallocate -l 11g logdev.ext4 && mkfs.ext4 -O ^has_journal,^uninit_bg,^ext_attr,^huge_file,^64bit -q logdev.ext4
sync
qemu-system-x86_64 -nographic -serial mon:stdio -m $mem -smp $cpus $kvm -kernel "$KERNEL" \
	-drive file="$VMROOTFS",index=0,readonly=on,media=cdrom \
	-hdb logdev.ext4 -hdc "$TESTDEV" -net nic,model=e1000 -net user \
	-append "net.ifnames=0 root=/dev/sr0 console=ttyS0 qemubench.fstyp=$FSTYP qemubench.cmd='$TESTCMDS'"

(mkdir -p mnt && sudo mount -o loop logdev.ext4 mnt && find mnt -maxdepth 1 -type f -exec cp '{}' $OUTDIR \; && sudo umount mnt)
rm -f logdev.ext4
{ [ -f $OUTDIR/exitstatus ] && [ "x`cat $OUTDIR/exitstatus`" = "x0" ]; }
