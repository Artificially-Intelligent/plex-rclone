#!/usr/bin/with-contenv bash

if [ -z "${PLEX_LIBRARY_MASTER_PATH}" ] &&  [ -f "$PLEX_LIBRARY_MASTER_PATH" ]; then
    echo "note: PLEX_LIBRARY_MASTER_PATH $PLEX_LIBRARY_MASTER_PATH detected. Checking if new version is present"
    if [ -f "$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/tag" ]; then
        LIBRARY_VERSION_TAG=`cat $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/tag`
    else
        LIBRARY_VERSION_TAG=1
    fi

    CLOUD_LIBRARY_VERSION_TAG=0
    rclone copy CRYPT:Storage/plex-library.tar.gz /config/ --config /root/.config/rclone/rclone.conf  --bwlimit 5M
    if [ $CLOUD_LIBRARY_VERSION_TAG -ge $LIBRARY_VERSION_TAG ]; then
        echo "note: Newer master library version ($CLOUD_LIBRARY_VERSION_TAG) detected. Overwriting library (version: $LIBRARY_VERSION_TAG)"    
        tar xvzf $PLEX_LIBRARY_MASTER_PATH /config/Library_new
        if [ $? -eq 0 ]; then
            rm -r $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
            
            mv "/config/Library_new/Application Support" $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
            rm -r /config/Library_new
            echo CLOUD_LIBRARY_VERSION_TAG > $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/tag
            echo "done!"
        else
            echo "error: tar extraction returned non zero status, leaving exisiting library in place"
            rm -rf /config/Library_new
        fi
    fi  
fi