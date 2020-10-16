#!/usr/bin/with-contenv bash

# if [ -z "${PLEXDRIVE_MOUNT_CONTAINER_PATH}" ]; then
#     PLEXDRIVE_MOUNT_CONTAINER_PATH=/mnt/plexdrive/
# fi
# mkdir -p "$PLEXDRIVE_MOUNT_CONTAINER_PATH"
# chmod +rwx "$PLEXDRIVE_MOUNT_CONTAINER_PATH"

if [ -z "${PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH}" ]; then
    export PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH=/mnt/plexdrive_decrypted
    echo "note: PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH"
fi
mkdir -p "$PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH"
chmod +rwx "$PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH"

if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
    export RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
    echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
fi
mkdir -p "$RCLONE_MOUNT_CONTAINER_PATH"
chmod +rwx "$RCLONE_MOUNT_CONTAINER_PATH"

/usr/bin/link-to-active-mount