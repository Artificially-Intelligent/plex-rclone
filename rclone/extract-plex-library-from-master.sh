#!/usr/bin/with-contenv bash

if ! [ -z "${PLEX_LIBRARY_MASTER_PATH}" ] ; then
    #wait a few seconds for mount to be active

    echo "note: PLEX_LIBRARY_MASTER_PATH $PLEX_LIBRARY_MASTER_PATH detected. Checking if new version is present"
    if [ -f "$PLEX_LIBRARY_MASTER_PATH/tag" ]; then
        LIBRARY_VERSION_TAG=`cat $PLEX_LIBRARY_MASTER_PATH/tag`
    else
        LIBRARY_VERSION_TAG=1
    fi

    CLOUD_LIBRARY_VERSION_TAG=$(date -d "`stat -c %y "$PLEX_LIBRARY_MASTER_PATH"`" +%s)

    if [ -z "${RCLONE_CONFIG}" ]; then
        RCLONE_CONFIG=/config/rclone/rclone.conf
    fi

    if [ $CLOUD_LIBRARY_VERSION_TAG -ge $LIBRARY_VERSION_TAG ]; then
        echo "note: Newer master library version ($CLOUD_LIBRARY_VERSION_TAG) detected. Overwriting library (version: $LIBRARY_VERSION_TAG)"
        rclone copy $PLEX_LIBRARY_MASTER_PATH /config/plex-library.tar.gz --config $RCLONE_CONFIG --bwlimit 6M

        mkdir -p /config/Library_new
        tar -C /config/Library_new -zxvf /config/plex-library.tar.gz

        if [ $? -eq 0 ] ; then
            rm -r $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
            mv "/config/Library_new/Application Support" $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
            echo CLOUD_LIBRARY_VERSION_TAG > $PLEX_LIBRARY_MASTER_PATH/tag
            echo "done!"
        fi
        rm -f  /config/plex-library.tar.gz
        rm -rf /config/Library_new
    fi
fi
