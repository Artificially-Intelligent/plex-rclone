#!/usr/bin/with-contenv bash

if [ -z "${RCLONE_CONFIG}" ]; then
    RCLONE_CONFIG=/config/rclone/rclone.conf
    if [ ! -f "${RCLONE_CONFIG}" ]; then
        RCLONE_CONFIG=/root/.config/rclone/rclone.conf
    fi
fi

if ! [ -z "${PLEX_LIBRARY_MASTER_PATH}" ] ; then
    echo "Testing $PLEX_LIBRARY_MASTER_PATH for new plex library version"

    export RCLONE_CONFIG_PASS=$(rclone reveal $OP)
    RCLONE_LS=$(rclone ls "$PLEX_LIBRARY_MASTER_PATH"  --config /root/.config/rclone/rclone.conf --ask-password=false)
    if echo $RCLONE_LS | grep -q failed ; then
        echo "rclone ls failed. Testing $PLEX_LIBRARY_MASTER_PATH as local path"

        #wait a few seconds for mount to be active
        
        [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 2
        [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 5
        [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 13
        [ "$(ls -A $RCLONE_MOUNT_CONTAINER_PATH)" ] || sleep 40
    fi

    if [ -f "${PLEX_LIBRARY_MASTER_PATH}" ] || ! [ -z "${RCLONE_LS}" ] ; then
        PLEX_LIBRARY_MASTER_TAR=`basename $PLEX_LIBRARY_MASTER_PATH`
        echo "note: PLEX_LIBRARY_MASTER_PATH $PLEX_LIBRARY_MASTER_PATH detected. Checking if new version is present"
        if [ -f "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/tag" ]; then
            LIBRARY_VERSION_TAG=`cat "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/tag"`
        else
            LIBRARY_VERSION_TAG=1
        fi

        if ! [ -z "${RCLONE_LS}" ] ; then
            read CLOUD_LIBRARY_VERSION_TAG _ <<< "$RCLONE_LS"
        else
            CLOUD_LIBRARY_VERSION_TAG=$(date -d "`stat -c %y "$PLEX_LIBRARY_MASTER_PATH"`" +%s)
        fi
        
        if [ $CLOUD_LIBRARY_VERSION_TAG -gt $LIBRARY_VERSION_TAG ]; then
            echo "note: Newer master library version ($CLOUD_LIBRARY_VERSION_TAG) detected. Overwriting library (version: $LIBRARY_VERSION_TAG)"

            if ! [ -z "${RCLONE_LS}" ] ; then
                rclone sync "$PLEX_LIBRARY_MASTER_PATH" /config --config "$RCLONE_CONFIG" --bwlimit 6M --progress --stats 30s --retries 10 --ask-password=false
            else
                cp "$PLEX_LIBRARY_MASTER_PATH" /config/
            fi
            
            mkdir -p /tmp/
            tar -C /tmp/ -zxf "/config/$PLEX_LIBRARY_MASTER_TAR"

            echo "note: $PLEX_LIBRARY_MASTER_TAR untar to /tmp complete"

            if [ $? -eq 0 ] ; then
                mv  "/tmp/Library/Application Support/Plex Media Server/Preferences.xml" "/tmp/Library/Application Support/Plex Media Server/Preferences-master.xml"
                cp  "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Preferences.xml" "/tmp/Library/Application Support/Plex Media Server/Preferences.xml"
                chown -R abc:abc /tmp/Library
                rm -r "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
                mv "/tmp/Library/Application Support" "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
                echo "$CLOUD_LIBRARY_VERSION_TAG" > "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/tag"
                echo "-----------------------------------------------------------------"
                echo "-----------------------------------------------------------------"
                echo "------------------- library replacement done! -------------------"
                echo "-----------------------------------------------------------------"
                echo "-----------------------------------------------------------------"
            fi
            rm -f  "/config/$PLEX_LIBRARY_MASTER_TAR"
            rm -rf /tmp/Library
        else
            echo "note: Master library version ($CLOUD_LIBRARY_VERSION_TAG) matched local version library (version: $LIBRARY_VERSION_TAG)"
        fi
    fi
    export RCLONE_CONFIG_PASS=
fi

# check Library permissions
PUID=${PUID:-911}
if [ ! "$(stat -c %u "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR")" = "$PUID" ]; then
    echo "Change in ownership detected, please be patient while we chown existing files"
    echo "This could take some time"
    chown abc:abc -R \
    "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR"
fi