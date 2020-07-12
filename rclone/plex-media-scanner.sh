#!/usr/bin/with-contenv bash

SWAP_MOUNT_SCRIPT=`find "/etc/cont-init.d/" -name *link-to-active-mount*`

# Set media mount to use rclone, plexdrive setup for read ahead is very wastefull during library scans
eval "$SWAP_MOUNT_SCRIPT --rclone"

# Run Plex Media Scanner with all arguments
echo "running command: /usr/lib/plexmediaserver/Plex\ Media\ Scanner-real $@"
{/usr/lib/plexmediaserver/Plex\ Media\ Scanner-real $@ } || {
    echo "Plex Meia Scanner finised with error"
    eval "$SWAP_MOUNT_SCRIPT"
}

# Set media mount to use default
eval "$SWAP_MOUNT_SCRIPT"
