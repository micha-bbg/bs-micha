#!/bin/sh

################################################################
#                                                              #
#      install_neutrino, v 1.00 29.08.2013 by micha-bbg        #
#                                                              #
################################################################

UPDATE_FILE=neutrino-hd*.opk
UPDATE_PATH=/tmp/__UPDATE__

if [ ! -e /tmp/$UPDATE_FILE ]; then
	echo "Kein Update File vorhanden, exit..."
	exit 1
fi

rm -fr $UPDATE_PATH
mkdir -p $UPDATE_PATH/data
cd $UPDATE_PATH

mv /tmp/$UPDATE_FILE $UPDATE_PATH

echo ""
echo "ar -x $UPDATE_FILE"
ar -x $UPDATE_FILE
rm $UPDATE_FILE

echo "tar -C $UPDATE_PATH/data -xf data.tar.gz"
tar -C $UPDATE_PATH/data -xf data.tar.gz

rm -f control.tar.gz
rm -f data.tar.gz
rm -f debian-binary

rm -f $UPDATE_PATH/data/.version
rm -f $UPDATE_PATH/data/var/tuxbox/config/nhttpd.conf
rm -fr $UPDATE_PATH/data/var/tuxbox/config/zapit
rm -fr $UPDATE_PATH/data/var/tuxbox/config/initial
rm -fr $UPDATE_PATH//data/share/fonts
mv $UPDATE_PATH/data/share/tuxbox/neutrino/httpd/index.html $UPDATE_PATH/data/share/tuxbox/neutrino/httpd/index.org.html
sync

cd $UPDATE_PATH/data

echo "killall neutrino"
killall ash
killall neutrino
sleep 1

if [ -e bin/neutrino ]; then
	echo "rm -f /bin/neutrino"
	rm -f /bin/neutrino
	sync
fi

echo "copy data..."
cp -frd share/* /share
rm -fr share
sync
cp -frd * /
sync

echo ""
echo -n "Fattich, reboot"
sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo "."
reboot -d 1 &
exit
