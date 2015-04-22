#!/sbin/sh

# clean init.d scripts
INITD_DIR=/system/etc/init.d

# slim
rm -rf $INITD_DIR/01mpdecision

# remove the binaries as they are no longer needed. (kernel handled)
if [ -e /system/bin/mpdecision ] ; then
	busybox mv /system/bin/mpdecision /system/bin/mpdecision_bck
fi
