#!/usr/bin/with-contenv bash
if ! [[ $RCLONE == "FALSE" || $RCLONE == "false" || $RCLONE == "0" || $RCLONE == "False" ]] ; then 
	if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
		RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
		echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
	fi

	if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
		RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone/
		echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
	fi

	if [[ $RCLONE_GUI == "TRUE" || $RCLONE_GUI == "true" || $RCLONE_GUI == "1" || $RCLONE_GUI == "True" ]]; then	
		if [ -z "${RCLONE_GUI_PORT}" ]; then
			RCLONE_GUI_PORT=13668
			echo "note: RCLONE_GUI_PORT env variable not defined. Assigning default port: $RCLONE_GUI_PORT"
		fi
		
		if [ -z "${RCLONE_GUI_USER}" ]; then
			RCLONE_GUI_USER=admin
			echo "note: RCLONE_GUI_USER env variable not defined. Assigning default user: $RCLONE_GUI_USER"
		fi

		if [ -z "${RCLONE_GUI_PASSWORD}" ]; then
			RCLONE_GUI_PASSWORD=1234
			echo "note: RCLONE_GUI_PASSWORD env variable not defined. Assigning default password: $RCLONE_GUI_PASSWORD"
		fi
		RCLONE_GUI_CONFIG=" --rc --rc-web-gui --rc-addr :$RCLONE_GUI_PORT --rc-user=$RCLONE_GUI_USER --rc-pass=$RCLONE_GUI_PASSWORD --rc-serve "
	fi

	if [ -z "${RCLONE_MOUNT_OPTIONS}" ]; then
		if [[ $PLEXDRIVE == "TRUE" || $PLEXDRIVE == "true" || $PLEXDRIVE == "1" || $PLEXDRIVE == "True" ]]; then
			# set default values to use for rclone crypt over plexdrive mount
			RCLONE_MOUNT_OPTIONS=" --allow-other --max-read-ahead 131072 --read-only "

			if ! [ -z "${PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH}" ]; then
				#allows users to define a different RCLONE_MOUNT_REMOTE_PATH for plexdrive so 
				#config can be changed to plexdrive by changing only PLEXDRIVE==TRUE anloter value
				RCLONE_MOUNT_REMOTE_PATH=$PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH
				echo "note: PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH env variable is defined and PLEXDRIVE == $PLEXDRIVE . Assigning PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH value $RCLONE_MOUNT_REMOTE_PATH to RCLONE_MOUNT_REMOTE_PATH"
			fi
		else
			# set default values to use for rclone
			RCLONE_MOUNT_OPTIONS=" --read-only --allow-other --acd-templink-threshold 0 --buffer-size 1G --timeout 5s --contimeout 5s --log-level INFO --stats 60s --use-json-log "
		fi
		echo "note: RCLONE_MOUNT_OPTIONS env variable not defined. Assigning default options: $RCLONE_MOUNT_OPTIONS"
	fi

	if [ -z "${RCLONE_CONFIG}" ]; then
		RCLONE_CONFIG=/config/rclone/rclone.conf
		echo "note: RCLONE_CONFIG env variable not defined. Assigning default path: $RCLONE_CONFIG"
	fi
	RCLONE_CONFIG_DIR=${RCLONE_CONFIG%/*}
	mkdir -p $RCLONE_CONFIG_DIR

	if ! [ -z "$RCLONE_CONFIG_URL" ] ; then
        echo "RCLONE_CONFIG_URL defined. Attempting to download latest config file"
        curl -L -o ./rclone.conf $RCLONE_CONFIG_URL 
        # /usr/bin/gdown.pl $RCLONE_CONFIG_URL ./rclone.conf
        
        if [ -f "./rclone.conf" ]; then
            echo "note: rclone.conf downloaded sucessfully. Overwriting $RCLONE_CONFIG with dowloaded config file."
            mv ./rclone.conf $RCLONE_CONFIG
		else
			echo "note: rclone.conf download not found."
			ls -la ./
        fi
    fi

	if [ -z "${RCLONE_CONFIG}" ]; then
		RCLONE_CONFIG=/config/rclone/rclone.conf
		echo "note: RCLONE_CONFIG env variable not defined. Assigning default path: $RCLONE_CONFIG"
	fi

	if [ ! -f "${RCLONE_CONFIG}" ]; then
		echo "warning: Rclone config file $RCLONE_CONFIG doesn't exist. Mount a volume containing one and/or setup your own by running the command below (replacing plex-rclone with your container name if different) ' docker exec -it plex-rclone rclone config --config $RCLONE_CONFIG ' Create a 'new remote' named $RCLONE_MOUNT_REMOTE_PATH  (without the : and any text following it), or add the name you chose followed by : to enviroment variable RCLONE_MOUNT_REMOTE_PATH"
	fi

	if [ -z "${RCLONE_MOUNT_REMOTE_PATH}" ]; then
		RCLONE_MOUNT_REMOTE_PATH="REMOTE:"
		echo "warning: RCLONE_MOUNT_REMOTE_PATH env variable not defined. Assigning default value: $RCLONE_MOUNT_REMOTE_PATH"	
	fi

	mkdir -p "$RCLONE_MOUNT_CONTAINER_PATH";
	chown -R abc:abc $RCLONE_MOUNT_CONTAINER_PATH;

	# start rclone
	if [ -z "${RCLONE_COMMAND}" ]; then
		RCLONE_COMMAND="mount $RCLONE_MOUNT_REMOTE_PATH $RCLONE_MOUNT_CONTAINER_PATH -config $RCLONE_CONFIG $RCLONE_MOUNT_OPTIONS $RCLONE_GUI_CONFIG"
	fi

	# start rclone
	echo "Starting rclone: rclone $RCLONE_COMMAND"
	rclone $RCLONE_COMMAND &
fi
