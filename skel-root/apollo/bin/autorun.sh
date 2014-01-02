export LD_LIBRARY_PATH=/var/lib
export PATH=${PATH}:/var/bin:/var/plugins

USE_GDB=0

echo ""
if [ -x /bin/oscam ]; then
	echo "Starting oscam..."
	/bin/oscam -b -c /var/keys -w 0
fi

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
#    sleep 15
#    /sbin/reboot -f
fi
