#!/bin/sh

if [ ! -e /tmp/.no_internet ]; then
#    ntpdate time.fu-berlin.de
    rdate time.fu-berlin.de
fi
