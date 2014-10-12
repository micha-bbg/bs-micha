#!/bin/sh

#################################################################
#                                                               #
#  flash-read.sh, v 3.02 27.08.2013 by M. Liebmann (micha-bbg)  #
#                                                               #
#################################################################

#BOX=Tank
BOX=Trinity

if [ "$BOX" = "Tank" ]; then
	# Tank
	ERASEBLOCK=0x40000
else
	# Trinity
	ERASEBLOCK=0x20000
fi



MK_SUM=1

WITH_KERNEL=0
WITH_LOG=1

COPY_MOD=cp
#COPY_MOD=rsync

[ "$COPY_MOD" = "" ] && COPY_MOD=cp

rm -f /tmp/CS-*.im*

UPDATE_DIR=$(sed -e "/^update_dir/!d;{s/.*=//g;}" /var/tuxbox/config/neutrino.conf)

if [ "$WITH_LOG" = "1" ]; then
	if [ -d $UPDATE_DIR ]; then
		LOGFILE=$UPDATE_DIR/image.log
	else
		LOGFILE=/tmp/image.log
	fi
	rm -f $LOGFILE
	touch $LOGFILE
fi

CopyKernel()
{
	DEV=$(grep -i kernel /proc/mtd | cut -f 0 -s -d :)
	if [ "$DEV" = "" ]; then
		echo "Kein Kernel-MTD gefunden..."
		return
	else
		echo "Copy Kernel..."
		echo "dd if=/dev/$DEV of=$KRNL_IMG bs=1024"
		dd if=/dev/$DEV of=$KRNL_IMG bs=1024
	fi
}

WriteLog()
{
	if [ "$WITH_LOG" = "1" ]; then
		DATE="$(date +%d.%m.%Y) - $(date +%H:%M:%S)"
		echo "$1"$DATE >> $LOGFILE
	fi
}

cutParam1()
{
	RET=$1
}

SpezCopy()
{
	mkdir -p $IMG_ROOT_FS/dev
	mkdir -p $IMG_ROOT_FS/proc
	mkdir -p $IMG_ROOT_FS/sys
	mkdir -p $IMG_ROOT_FS/tmp

	mkdir -p $IMG_ROOT_FS/mnt/neutrino-update
	[ -d /mnt/nfs/Data2 ] && mkdir -p $IMG_ROOT_FS/mnt/nfs/Data2
	[ -d /mnt/nfs/c ]     && mkdir -p $IMG_ROOT_FS/mnt/nfs/c
	cp -fd /* $IMG_ROOT_FS > /dev/null 2>&1
	cp -fd /.* $IMG_ROOT_FS > /dev/null 2>&1
}

echo ""
echo " Erzeuge jffs2-Image ($BOX, Eraseblock $ERASEBLOCK)"
echo ""

WriteLog "Start Copy            : "

BOX_USER=$(sed -e "/^cheffe/!d;{s/.*=//g;}" /.version)
[ "$BOX_USER" = "" ] && BOX_USER=User

LDATE="$(date +%d.%m.%Y) - $(date +%H:%M:%S)"
IDATE="$(date +%Y-%m-%d)_$(date +%H-%M)"

if [ "$WITH_KERNEL" = "1" ]; then
	KRNL="+Krnl"
else
	KRNL=
fi
IMG_BODY_X="CS-${BOX_USER}_"
IMG_BODY=${IMG_BODY_X}"root0${KRNL}"
IMG_BODY_END=$IMG_BODY

IMG_BODY=${IMG_BODY}"_${IDATE}"
#IMG_BODY_END=${IMG_BODY_END}"_${IDATE}"

IMG_ROOT_FS=/tmp/IMG_BACKUP
IMG_TMP_PATH=/tmp/IMG_BACKUP_TMP
IMG_TMP_NAME=$IMG_TMP_PATH/${IMG_BODY}_tmp.img
if [ "$MK_SUM" = "1" ]; then
	IMG_BODY_END=${IMG_BODY_END}_sum"_${IDATE}"
else
	IMG_BODY_END=${IMG_BODY_END}"_${IDATE}"
fi
IMG_NAME=$IMG_TMP_PATH/${IMG_BODY}.img

UPDATE_DIR=$(sed -e "/^update_dir/!d;{s/.*=//g;}" /var/tuxbox/config/neutrino.conf)
if [ -d $UPDATE_DIR ]; then
	IMG_NAME_END=$UPDATE_DIR/${IMG_BODY_END}.img
	DO_COPY=cp
else
	IMG_NAME_END=/tmp/${IMG_BODY_END}.img
	DO_COPY=mv
fi


UPDATE_INFO=$IMG_ROOT_FS/FlashUpdate.info

KRNL_IMG=$IMG_ROOT_FS/var/update/vmlinux.ub.gz

cd /tmp
[ -e $IMG_ROOT_FS ] && rm -fr $IMG_ROOT_FS
mkdir -p $IMG_ROOT_FS
[ -e $IMG_TMP_PATH ] && rm -fr $IMG_TMP_PATH
mkdir -p $IMG_TMP_PATH

rm -f $IMG_NAME_END

echo ""
echo "Copy Files..."

if [ "$COPY_MOD" = "cp" ]; then
	COPY_X="cp -fdr"
elif [ "$COPY_MOD" = "rsync" ]; then
	COPY_X="rsync -lhr"
fi
echo "copy mit $COPY_X"

$COPY_X /bin $IMG_ROOT_FS
$COPY_X /etc $IMG_ROOT_FS
$COPY_X /lib $IMG_ROOT_FS
$COPY_X /root $IMG_ROOT_FS
$COPY_X /sbin $IMG_ROOT_FS
$COPY_X /share $IMG_ROOT_FS

$COPY_X /var $IMG_ROOT_FS
[ -d $IMG_ROOT_FS/var/epg ] && rm -f $IMG_ROOT_FS/var/epg/*

[ -d /debugfs ]   && $COPY_X /debugfs $IMG_ROOT_FS
[ -d /home ]      && $COPY_X /home $IMG_ROOT_FS
[ -d /include ]   && $COPY_X /include $IMG_ROOT_FS
[ -d /opt ]       && $COPY_X /opt $IMG_ROOT_FS
[ -d /perf ]      && $COPY_X /perf $IMG_ROOT_FS
[ -d /usr ]       && $COPY_X /usr $IMG_ROOT_FS
[ -d /video_app ] && $COPY_X /video_app $IMG_ROOT_FS

SpezCopy

[ "$WITH_KERNEL" = "1" ] && CopyKernel

sync
ls -R $IMG_ROOT_FS > /dev/null

cutParam1 $(du -sk $IMG_ROOT_FS)

echo "Image backup from $LDATE" 			 > $UPDATE_INFO
echo "" 						>> $UPDATE_INFO
echo "realsize filesystem : $RET KB" 			>> $UPDATE_INFO
echo "original filename   : $(basename $IMG_NAME)"	>> $UPDATE_INFO
sync

echo ""
echo "Filesystem: $RET KB"
echo ""
WriteLog "Ende Copy             : "

DEVTABLE=$IMG_TMP_PATH/devtable
echo "/dev/console c 0600 0 0 5 1 0 0 0" 	 > $DEVTABLE
echo "/dev/null c 0666 0 0 1 3 0 0 0" 		>> $DEVTABLE
echo "/dev/net d 0755 0 0 0 0 0 0 0" 		>> $DEVTABLE
echo "/dev/net/tun c 0600 0 0 10 200 0 0 0"	>> $DEVTABLE

MKFS_PARAMS="--readcount --no-cleanmarkers --eraseblock=$ERASEBLOCK --little-endian --squash-uids --devtable=$DEVTABLE --root=$IMG_ROOT_FS --output=$IMG_TMP_NAME"
SUM_PARAMS="--no-cleanmarkers --eraseblock=$ERASEBLOCK --little-endian --input=$IMG_TMP_NAME --output=$IMG_NAME"

echo "mkfs.jffs2 $MKFS_PARAMS"
mkfs.jffs2 $MKFS_PARAMS || exit 1
WriteLog "Ende Make Image       : "

if [ "$MK_SUM" = "1" ]; then
	echo "sumtool $SUM_PARAMS"
	sumtool $SUM_PARAMS || exit 1
else
	cp -f $IMG_TMP_NAME $IMG_NAME
fi

echo ""
echo "$DO_COPY -f $IMG_NAME $IMG_NAME_END"
$DO_COPY -f $IMG_NAME $IMG_NAME_END
sync

WriteLog "Ende sum Image        : "

if [ "$WITH_LOG" = "1" ]; then
	echo "" 		>> $LOGFILE
	echo "----------------"	>> $LOGFILE
	cat $UPDATE_INFO 	>> $LOGFILE
fi

rm -f $IMG_TMP_NAME
rm -f $DEVTABLE
rm -fr $IMG_ROOT_FS
rm -fr $IMG_TMP_PATH
sync

echo ""
echo "Fattich..."
