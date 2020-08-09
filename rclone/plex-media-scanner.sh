#!/usr/bin/with-contenv bash

SWAP_MOUNT_SCRIPT=`find "/etc/cont-init.d/" -name *link-to-active-mount*`

# Set media mount to use rclone, plexdrive setup for read ahead is very wastefull during library scans
eval "$SWAP_MOUNT_SCRIPT --rclone"

# if swap mount successful
if ls -la /plex/media | grep -qs rclone ; then

    # create a scanner file to track active scanners
    scanner_folder=/plex/scanners
    mkdir -p $scanner_folder
    scanner_file="$scanner_folder/Plex_Media_Scanner-"$(date +"%s")
    echo "$@" > $scanner_file

    # Run Plex Media Scanner with all arguments
    echo "running command: /usr/lib/plexmediaserver/Plex\ Media\ Scanner-real $@"
    /usr/lib/plexmediaserver/Plex\ Media\ Scanner-real $@ || {
        echo "Plex Media Scanner finished with error"
        rm $scanner_file
        [ "$(ls -A $scanner_folder)" ] && echo "mount remaining linked to rclone, a scanner is still running" || eval "$SWAP_MOUNT_SCRIPT"
    }
    rm $scanner_file
else
    echo "scanner was skipped because link to rclone was not active. scanner args: $@"
fi

find $scanner_folder -type f -mmin +240 -exec rm -f {} \;

# Set media mount to use default
[ "$(ls -A $scanner_folder)" ] && echo "mount remaining linked to rclone, a scanner is still running" || eval "$SWAP_MOUNT_SCRIPT"
