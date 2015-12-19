export LD_LIBRARY_PATH=/var/lib
export PATH=${PATH}:/var/bin:/var/plugins

USE_GDB=0

echo ""
service camd restart

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
	/bin/dt -t"No panic!"
	echo "No panic!"
#	sleep 15
#	/sbin/reboot -f
fi
