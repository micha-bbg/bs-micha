#!/bin/sh

PATH=/var/bin:/bin:/usr/bin:/var/sbin:/sbin:/usr/sbin
. /etc/init.d/functions

echo "Running mknod now..."

create_node "KAL"
create_node "notifyq"
create_node "platform"
create_node "content"
create_node "standby"
create_node "video"
create_node "audio"
create_node "pvr"
create_node "ci"
create_node "cs_control"
#create_node "cs_display"
create_node "cs_ir"
create_node_dir "fb"
create_node "FrontEnd"
create_node "ipfe"
create_node "pvrsrvkm"
create_node "vss_bc"

#ln -sf /dev/cs_display /dev/display
ln -sf /dev/cs_ir /dev/input/nevis_ir
ln -sf /dev/cs_ir /dev/input/input0
