#!/bin/sh

PACKAGE_NAME=systemlibs-dummy

OPKG_DIR=/var/lib/opkg
STATUS=${OPKG_DIR}/status
STATUS_TMP=${STATUS}.tmp001
CONTROL_FILE=${OPKG_DIR}/info/${PACKAGE_NAME}.control
PACKAGE="Package: ${PACKAGE_NAME}"
PROVIDES="Provides:"
LASTLINE="Install"
PROV=

[ ! -e $STATUS ] && exit

LIBS=$(ls /usr/lib/*.so.* -1)
for lib in $LIBS; do
	lib=$(echo $lib | sed 's#^/usr/lib/##')
	if [ "$PROV" = "" ]; then
		PROV=$lib
	else
		PROV="$PROV, $lib"
	fi
done

LIBS=$(ls /lib/*.so.* -1)
for lib in $LIBS; do
	lib=$(echo $lib | sed 's#^/lib/##')
	if [ "$PROV" = "" ]; then
		PROV=$lib
	else
		PROV="$PROV, $lib"
	fi
done

makeStatus()
{
	TMP_DIR=$(pwd)
	cd ${OPKG_DIR}
	rm -f $STATUS_TMP
	FOUND=
	REPLACE=
	while read line
	do
		echo $line | grep "$PACKAGE"  > /dev/null 2>&1
		RET=$?
		if [ "$FOUND" = "1" -a "$REPLACE" = "" ]; then
			echo $line | grep "$PROVIDES"  > /dev/null 2>&1
			if [ $? = 0 ]; then
				echo "Provides: $PROV" >> $STATUS_TMP
				REPLACE=1
			else
				echo $line | grep "$LASTLINE"  > /dev/null 2>&1
				if [ $? = 0 ]; then
					echo "Provides: $PROV" >> $STATUS_TMP
					REPLACE=1
				fi
				echo "$line" >> $STATUS_TMP
			fi
		else
			[ $RET = 0 ] && FOUND=1
			echo "$line" >> $STATUS_TMP
		fi
	done < $STATUS
	sed "s/Provides:.*/Provides: $PROV/g" ${CONTROL_FILE} > ${CONTROL_FILE}.tmp && mv ${CONTROL_FILE}.tmp ${CONTROL_FILE}
	cd $TMP_DIR
}

{ sleep 6; makeStatus; sleep 1; rm -f $STATUS; mv -f $STATUS_TMP $STATUS; exit 0; } &

exit 0
