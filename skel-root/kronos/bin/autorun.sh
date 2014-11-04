export LD_LIBRARY_PATH=/var/lib

paths="/var/sbin /sbin /usr/sbin /var/bin /bin /usr/bin /var/plugins /var/tuxbox/plugins /lib/tuxbox/plugins /usr/lib/tuxbox/plugins"
P=
for i in $paths ;do
	if [ -d $i ]; then
		if [ "$P" = "" ]; then
			P=$i
		else
			P=$P:$i
		fi
	fi
done
export PATH=$P

USE_GDB=0

echo ""
camd_start.sh first_start

if [ "$USE_GDB" = "1" ]; then
	echo ""
	echo "Neutrino debugging with GDB"
	echo ""
	gdbserver :5555 neutrino
	exit 0
fi

echo ""
echo "### Starting NEUTRINO ###"
cd /tmp
/bin/neutrino

/bin/sync
/bin/sync

if [ -e /tmp/.reboot ] ; then
	/bin/dt -t"Rebooting..."
	/sbin/reboot -f
else
	/bin/dt -t"Panic..."
	echo "Panic..."
#	sleep 15
#	/sbin/reboot -f
fi
