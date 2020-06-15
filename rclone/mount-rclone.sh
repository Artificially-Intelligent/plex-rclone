#!/usr/bin/with-contenv bash
if ! [[ $RCLONE == "FALSE" || $RCLONE == "false" || $RCLONE == "0" || $RCLONE == "False" ]] ; then 
	if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
		export RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
		echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
	fi

	if [[ $RCLONE_GUI == "TRUE" || $RCLONE_GUI == "true" || $RCLONE_GUI == "1" || $RCLONE_GUI == "True" ]]; then	
		if [ -z "${RCLONE_GUI_PORT}" ]; then
			RCLONE_GUI_PORT=13668
			echo "note: RCLONE_GUI_PORT env variable not defined. Assigning default port: $RCLONE_GUI_PORT"
		fi
		
		if [ -z "${RCLONE_SERVE_GUI_PORT}" ]; then
			RCLONE_SERVE_GUI_PORT=13669
			echo "note: RCLONE_SERVE_GUI_PORT env variable not defined. Assigning default port: $RCLONE_SERVE_GUI_PORT"
		fi

		if [ -z "${RCLONE_GUI_USER}" ]; then
			RCLONE_GUI_USER=rclone
			echo "note: RCLONE_GUI_USER env variable not defined. Assigning default user: $RCLONE_GUI_USER"
		fi

		if [ -z "${RCLONE_GUI_PASSWORD}" ]; then
			RCLONE_GUI_PASSWORD=rclone
			echo "note: RCLONE_GUI_PASSWORD env variable not defined. Assigning default password: $RCLONE_GUI_PASSWORD"
		fi
		RCLONE_GUI_CONFIG=" --rc --rc-web-gui --rc-addr :$RCLONE_GUI_PORT --rc-user=$RCLONE_GUI_USER --rc-pass=$RCLONE_GUI_PASSWORD --rc-serve "
		RCLONE_SERVE_GUI_CONFIG=" --rc --rc-web-gui --rc-addr :$RCLONE_SERVE_GUI_PORT --rc-user=$RCLONE_GUI_USER --rc-pass=$RCLONE_GUI_PASSWORD --rc-serve "
	fi

	if [ -z "${RCLONE_MOUNT_OPTIONS}" ]; then
		if [[ $PLEXDRIVE == "TRUE" || $PLEXDRIVE == "true" || $PLEXDRIVE == "1" || $PLEXDRIVE == "True" ]]; then
			# set default values to use for rclone crypt over plexdrive mount
			export RCLONE_MOUNT_OPTIONS=" --max-read-ahead 131072 --read-only "

			if ! [ -z "${PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH}" ]; then
				#allows users to define a different RCLONE_MOUNT_REMOTE_PATH for plexdrive so 
				#config can be changed to plexdrive by changing only PLEXDRIVE==TRUE anloter value
				export RCLONE_MOUNT_REMOTE_PATH=$PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH
				echo "note: PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH env variable is defined and PLEXDRIVE == $PLEXDRIVE . Assigning PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH value $RCLONE_MOUNT_REMOTE_PATH to RCLONE_MOUNT_REMOTE_PATH"
			fi
		else
			# set default values to use for rclone
			export RCLONE_MOUNT_OPTIONS=" --read-only --acd-templink-threshold 0 --buffer-size 1G --timeout 5s --contimeout 5s --log-level INFO --stats 60s --use-json-log --dir-cache-time 24h "
		fi
		echo "note: RCLONE_MOUNT_OPTIONS env variable not defined. Assigning default options: $RCLONE_MOUNT_OPTIONS"
	fi

	if [ -z "${RCLONE_CONFIG}" ]; then
		export RCLONE_CONFIG=/config/rclone/rclone.conf
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

	if [ ! -f "${RCLONE_CONFIG}" ]; then
		echo "warning: Rclone config file $RCLONE_CONFIG doesn't exist. Mount a volume containing one and/or setup your own by running the command below (replacing plex-rclone with your container name if different) ' docker exec -it plex-rclone rclone config --config $RCLONE_CONFIG ' Create a 'new remote' named $RCLONE_MOUNT_REMOTE_PATH  (without the : and any text following it), or add the name you chose followed by : to enviroment variable RCLONE_MOUNT_REMOTE_PATH"
	fi

	if [ -z "${RCLONE_MOUNT_REMOTE_PATH}" ]; then
		export RCLONE_MOUNT_REMOTE_PATH="REMOTE:"
		echo "warning: RCLONE_MOUNT_REMOTE_PATH env variable not defined. Assigning default value: $RCLONE_MOUNT_REMOTE_PATH"	
	fi

	mkdir -p "$RCLONE_MOUNT_CONTAINER_PATH";
	chown -R abc:abc $RCLONE_MOUNT_CONTAINER_PATH;

	# start rclone
	if [ -z "${RCLONE_COMMAND}" ]; then
		RCLONE_COMMAND="mount $RCLONE_MOUNT_REMOTE_PATH $RCLONE_MOUNT_CONTAINER_PATH --allow-other --config $RCLONE_CONFIG $RCLONE_MOUNT_OPTIONS $RCLONE_GUI_CONFIG"
	fi

	# start rclone
	echo "Starting rclone: rclone $RCLONE_COMMAND"
	rclone $RCLONE_COMMAND &
fi



# start rclone serve
if ! [ -z "${RCLONE_SERVE_PORT}" ]; then
     echo "note: RCLONE_SERVE_PORT env variable is set ($RCLONE_SERVE_PORT), enabling relay server for rclone mount."

    # if [ -z "${RCLONE_SERVE_PORT}" ]; then
    #     RCLONE_SERVE_PORT=8080
    #     echo "note: RCLONE_SERVE_PORT env variable not defined. Assigning default port: $RCLONE_SERVE_PORT"
    # fi


    if [ -z "${RCLONE_SERVE_PROTOCOL}" ]; then
        RCLONE_SERVE_PROTOCOL=webdav
        echo "note: RCLONE_SERVE_PROTOCOL env variable not defined. Assigning default password: $RCLONE_SERVE_PROTOCOL. (options: dlna, ftp, http, restic, sftp, webdav) see https://rclone.org/commands/rclone_serve/ for more info"
    fi

    if ! [[ $RCLONE_SERVE_PROTOCOL == "dlna" ]]; then
        if [ -z "${RCLONE_SERVE_USER}" ]; then
            RCLONE_SERVE_USER=rclone
            echo "note: RCLONE_SERVE_USER env variable not defined. Assigning default user: $RCLONE_SERVE_USER"
        fi

        if [ -z "${RCLONE_SERVE_PASSWORD}" ]; then
            RCLONE_SERVE_PASSWORD=rclone
            echo "note: RCLONE_SERVE_PASSWORD env variable not defined. Assigning default password: $RCLONE_SERVE_PASSWORD"
        fi
    fi



    if [ -z "${RCLONE_SERVE_COMMAND}" ]; then
    # $RCLONE_GUI_CONFIG
        RCLONE_SERVE_COMMAND="serve $RCLONE_SERVE_PROTOCOL $RCLONE_MOUNT_REMOTE_PATH --config $RCLONE_CONFIG $RCLONE_MOUNT_OPTIONS --addr :$RCLONE_SERVE_PORT $RCLONE_SERVE_GUI_CONFIG "
    fi

    # start rclone serve
    echo "Starting relay server for rclone mount using command: rclone $RCLONE_SERVE_COMMAND"
    echo "To access open file browser / map network drive to on docker host machine to localhost:$RCLONE_SERVE_PORT . On other machines substitute use <host machine ip address or name>:$RCLONE_SERVE_PORT"
    rclone $RCLONE_SERVE_COMMAND &
fi

echo "Connection details"
echo -------------------------------------
echo "Substitute localhost with ip address of docker host machine to connect from other computers"
echo " "
echo "Plex URL: http://localhost:32400"
echo "RCLONE Management GUI for Plex: http://localhost:$RCLONE_GUI_PORT/web"
echo " "
if ! [ -z "${RCLONE_SERVE_PORT}" ]; then
	echo " "
	echo "RCLONE Network Drive: http://localhost:$RCLONE_SERVE_PORT"
	echo "RCLONE Management GUI for Network Drive: http://localhost:$RCLONE_SERVE_GUI_PORT"
	echo "Instructions for mounting as network drive in windows: https://www2.le.ac.uk/offices/itservices/ithelp/my-computer/files-and-security/work-off-campus/webdav/webdav-on-windows-10"
fi
echo " "
echo -------------------------------------
