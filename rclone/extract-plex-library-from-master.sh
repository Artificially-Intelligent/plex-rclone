#!/usr/bin/with-contenv bash

if ! [ -z "${PLEX_LIBRARY_MASTER_PATH}" ] &&  [ -f "$PLEX_LIBRARY_MASTER_PATH" ]; then
    echo "note: PLEX_LIBRARY_MASTER_PATH $PLEX_LIBRARY_MASTER_PATH detected. Checking if new version is present"
    if [ -f "/config/Library/tag" ]; then
        LIBRARY_VERSION_TAG=`cat /config/Library/tag`
    else
        LIBRARY_VERSION_TAG=1
    fi

    CLOUD_LIBRARY_VERSION_TAG=$(date -d "`stat -c %y "$PLEX_LIBRARY_MASTER_PATH"`" +%s)
    
    if [ $CLOUD_LIBRARY_VERSION_TAG -ge $LIBRARY_VERSION_TAG ]; then
        echo "note: Newer master library version ($CLOUD_LIBRARY_VERSION_TAG) detected. Overwriting library (version: $LIBRARY_VERSION_TAG)"    
        tar xvzf $PLEX_LIBRARY_MASTER_PATH /config/Library_new
		if [ $? -eq 0 ]; then
			rm -r $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
			mv "/config/Library_new/Application Support" $PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR
			echo CLOUD_LIBRARY_VERSION_TAG > /config/Library/tag
			echo "done!"
		fi
		rm -rf /config/Library_new
    fi  
fi