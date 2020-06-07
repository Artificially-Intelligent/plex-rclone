#!/usr/bin/with-contenv bash
if [[ $PLEXDRIVE == "TRUE" || $PLEXDRIVE == "true" || $PLEXDRIVE == "1" || $PLEXDRIVE == "True" ]] ; then 
    echo "PLEXDRIVE == TRUE - plexdrive mount will be attempted prior to rclone"

    if [ -z "${PLEXDRIVE_MOUNT_CONTAINER_PATH}" ]; then
        PLEXDRIVE_MOUNT_CONTAINER_PATH=/mnt/plexdrive
        echo "note: PLEXDRIVE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $PLEXDRIVE_MOUNT_CONTAINER_PATH"
    fi

    if [ -z "${PLEXDRIVE_MOUNT_OPTIONS}" ]; then
        PLEXDRIVE_MOUNT_OPTIONS=" -o read_only -v 3 --max-chunks=10 --chunk-size=20M --chunk-check-threads=20 --chunk-load-threads=3 --chunk-load-ahead=4 "
        echo "note: PLEXDRIVE_MOUNT_OPTIONS env variable not defined. Assigning default options: $PLEXDRIVE_MOUNT_OPTIONS"
    fi
    

    if [ -z "${PLEXDRIVE_CONFIG_PATH}" ]; then
        PLEXDRIVE_CONFIG_PATH=/config/plexdrive/
        echo "note: PLEXDRIVE_CONFIG_PATH env variable not defined. Assigning default path: $PLEXDRIVE_CONFIG_PATH"
    fi

    if ! [[ $PLEXDRIVE_CONFIG_PATH == "/root/.plexdrive"]] ; then 
        #Link to default plexdrive config path
        ln -s $PLEXDRIVE_CONFIG_PATH /root/.plexdrive
    fi

    if [ ! -f "${PLEXDRIVE_CONFIG_PATH}/config.json" ]; then
        echo "warning: PLEXDRIVE config file ${PLEXDRIVE_CONFIG_PATH}/config.json doesn't exist. Please create one and"
    fi
    if [ ! -f "${PLEXDRIVE_CONFIG_PATH}/token.json" ]; then
        echo "warning: PLEXDRIVE config file ${PLEXDRIVE_CONFIG_PATH}/token.json doesn't exist. Please create one and"
    fi

    mkdir -p "$PLEXDRIVE_MOUNT_CONTAINER_PATH";
    chown -R abc:abc $PLEXDRIVE_MOUNT_CONTAINER_PATH;

    # start PLEXDRIVE
    if [ -z "${PLEXDRIVE_COMMAND}" ]; then
        PLEXDRIVE_COMMAND="mount $PLEXDRIVE_MOUNT_OPTIONS $PLEXDRIVE_MOUNT_CONTAINER_PATH"
    fi

    # start PLEXDRIVE
    echo "Starting PLEXDRIVE: PLEXDRIVE $PLEXDRIVE_COMMAND"
    plexdrive $PLEXDRIVE_COMMAND &
fi