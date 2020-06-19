#!/usr/bin/with-contenv bash

if ! [ -z "${PLEX_LIBRARY_MASTER_PATH}" ] ; then
    #wait a few seconds for mount to be active

    [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 2
    [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 5
    [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 13
    [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 40

    if [ -f "${PLEX_LIBRARY_MASTER_PATH}" ] ; then
        PLEX_LIBRARY_MASTER_TAR=`basename $PLEX_LIBRARY_MASTER_PATH`
        echo "note: PLEX_LIBRARY_MASTER_PATH $PLEX_LIBRARY_MASTER_PATH detected. Checking if new version is present"
        if [ -f "$PLEX_LIBRARY_MASTER_PATH/tag" ]; then
            LIBRARY_VERSION_TAG=`cat $PLEX_LIBRARY_MASTER_PATH/tag`
        else
            LIBRARY_VERSION_TAG=1
        fi

        CLOUD_LIBRARY_VERSION_TAG=$(date -d "`stat -c %y "$PLEX_LIBRARY_MASTER_PATH"`" +%s)

        if [ $CLOUD_LIBRARY_VERSION_TAG -ge $LIBRARY_VERSION_TAG ]; then
            echo "note: Newer master library version ($CLOUD_LIBRARY_VERSION_TAG) detected. Overwriting library (version: $LIBRARY_VERSION_TAG)"
            
            cp $PLEX_LIBRARY_MASTER_PATH /tmp/
            # rclone copy $PLEX_LIBRARY_MASTER_PATH /tmp --config $RCLONE_CONFIG --bwlimit 6M

            mkdir -p /tmp/
            tar -C /tmp/ -zxvf /tmp/$PLEX_LIBRARY_MASTER_TAR

            if [ $? -eq 0 ] ; then
                mkdir -p  "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
                rm -r "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
                mv "/tmp/Library/Application Support" "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
                echo "$CLOUD_LIBRARY_VERSION_TAG" > "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/tag"
                echo "done!"
            fi
            rm -f  /tmp/$PLEX_LIBRARY_MASTER_TAR
            rm -rf /tmp/Library
        fi
    fi
fi