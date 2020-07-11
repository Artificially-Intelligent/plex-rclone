#!/usr/bin/with-contenv bash

while [ "$1" != "" ]; do
    case $1 in
        -r | --rclone )           shift
                                PLEXDRIVE=0
                                ;;
        -p | --plexdrive )           shift
                                PLEXDRIVE=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [[ $PLEXDRIVE == "TRUE" || $PLEXDRIVE == "true" || $PLEXDRIVE == "1" || $PLEXDRIVE == "True" ]] ; then 
    
    if [ -z "${PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH}" ]; then
        PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH=/mnt/plexdrive_decrypted
        # echo "note: PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH"
    fi
    DRIVE_MOUNT_CONTAINER_PATH=$PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH
else
    if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
		RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
		# echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
	fi
    DRIVE_MOUNT_CONTAINER_PATH=$RCLONE_MOUNT_CONTAINER_PATH
fi


if [ -z "${MEDIA_MOUNT_CONTAINER_PATH}" ]; then
    export MEDIA_MOUNT_CONTAINER_PATH=/mnt/media
    echo "note: MEDIA_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $MEDIA_MOUNT_CONTAINER_PATH"
fi

path_found=$( ls -la $MEDIA_MOUNT_CONTAINER_PATH | grep -ic $DRIVE_MOUNT_CONTAINER_PATH )
if [ $path_found -eq 1 ]
then
  echo "Already linked from $DRIVE_MOUNT_CONTAINER_PATH to $MEDIA_MOUNT_CONTAINER_PATH"
else 
    if [ -d "${MEDIA_MOUNT_CONTAINER_PATH}" ]; then
        echo "removing symbolic link from $MEDIA_MOUNT_CONTAINER_PATH"
        rm -f $MEDIA_MOUNT_CONTAINER_PATH
    else
        echo "use $MEDIA_MOUNT_CONTAINER_PATH for plex library. This allow source mount to be changed with just a change to the symbolic link, helpful if you want to change from plex drive to rclone mounts during library scans"
    fi

    echo "creating symbolic link from $DRIVE_MOUNT_CONTAINER_PATH to $MEDIA_MOUNT_CONTAINER_PATH"
    ln -sf $DRIVE_MOUNT_CONTAINER_PATH $MEDIA_MOUNT_CONTAINER_PATH
fi