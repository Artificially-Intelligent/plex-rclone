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

    # #Rclone default options for use with plexdrive mounts
    # if [ -z "${RCLONE_MOUNT_OPTIONS}" ]; then
	# 	export RCLONE_MOUNT_OPTIONS=" --allow-other --max-read-ahead 131072 --read-only "
	# 	echo "note: RCLONE_MOUNT_OPTIONS env variable not defined. Assigning default options: $RCLONE_MOUNT_OPTIONS"
	# fi
    
    if [ -z "${PLEXDRIVE_CONFIG_PATH}" ]; then
        PLEXDRIVE_CONFIG_PATH=/config/plexdrive/
        echo "note: PLEXDRIVE_CONFIG_PATH env variable not defined. Assigning default path: $PLEXDRIVE_CONFIG_PATH"
    fi

    mkdir -p "$PLEXDRIVE_CONFIG_PATH";

    if ! [ -z "$PLEXDRIVE_CONFIG_URL_TOKEN" ] && ! [ -z "$PLEXDRIVE_CONFIG_URL_CONFIG" ] ; then
        echo "PLEXDRIVE_CONFIG_URL_TOKEN and PLEXDRIVE_CONFIG_URL_CONFIG defined. Attempting to download latest config files"
        curl -L -o ./token.json $PLEXDRIVE_CONFIG_URL_TOKEN 
        curl -L -o ./config.json $PLEXDRIVE_CONFIG_URL_CONFIG 
        # /usr/bin/gdown.pl $PLEXDRIVE_CONFIG_URL_TOKEN ./token.json
        # /usr/bin/gdown.pl $PLEXDRIVE_CONFIG_URL_CONFIG ./config.json
        
        if [ -f "./token.json" ] &&  [ -f "./config.json" ]; then
            echo "note: token.json & config.json downloaded sucessfully. Overwriting folder contents with dowloaded config files."
            mv -f ./token.json ${PLEXDRIVE_CONFIG_PATH}token.json
            mv -f ./config.json ${PLEXDRIVE_CONFIG_PATH}config.json
        fi
        if ! [ -z "$PLEXDRIVE_CONFIG_URL_CACHE" ] && ! [ -f ${PLEXDRIVE_CONFIG_PATH}cache.bolt ] ; then
            echo "PLEXDRIVE_CONFIG_URL_CACHE defined. Attempting to download latest cache file"
            # curl -L -o ./cache.bolt $PLEXDRIVE_CONFIG_URL_CACHE
            /usr/bin/gdown.pl $PLEXDRIVE_CONFIG_URL_CACHE ./cache.bolt
            
            if [ -f "./cache.bolt" ]; then
                echo "note: cache.bolt download found. Overwriting existing plexdrive cache.bolt file."
                mv ./cache.bolt ${PLEXDRIVE_CONFIG_PATH}cache.bolt
            fi
        fi
    fi

    if ! [[ $PLEXDRIVE_CONFIG_PATH == "/root/.plexdrive" ]]; then 
        #Link to default plexdrive config path
        ln -s $PLEXDRIVE_CONFIG_PATH /root/.plexdrive
    fi

    if [ ! -f "${PLEXDRIVE_CONFIG_PATH}config.json" ]; then
        echo "warning: PLEXDRIVE config file ${PLEXDRIVE_CONFIG_PATH}config.json doesn't exist. Please create one and place in folder mounted to /config/plexdrive"
    fi
    if [ ! -f "${PLEXDRIVE_CONFIG_PATH}token.json" ]; then
        echo "warning: PLEXDRIVE config file ${PLEXDRIVE_CONFIG_PATH}token.json doesn't exist. Please create one and place in folder mounted to /config/plexdrive"
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