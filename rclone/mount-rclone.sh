#!/usr/bin/with-contenv bash

while [ "$1" != "" ]; do
    case $1 in
        -o | --mount-options )           shift
                                RCLONE_MOUNT_OPTIONS=$1
                                ;;
        -p | --container-path )           shift
                                RCLONE_MOUNT_CONTAINER_PATH=$1
                                ;;
        -r | --remote-path)           shift
                                RCLONE_MOUNT_REMOTE_PATH=$1
                                ;;
        -g | --gui-port )           shift
                                RCLONE_GUI_PORT=$1
                                ;;
        -p | --serve-port )           shift
                                RCLONE_SERVE_PORT=$1
                                ;;
        -s | --serve-gui-port )           shift
                                RCLONE_SERVE_GUI_PORT=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if ! [[ $RCLONE == "FALSE" || $RCLONE == "false" || $RCLONE == "0" || $RCLONE == "False" ]] ; then 
	if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
		export RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
		echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
	fi

	if [[ $RCLONE_GUI == "TRUE" || $RCLONE_GUI == "true" || $RCLONE_GUI == "1" || $RCLONE_GUI == "True" ]]; then	
		if [ -z "${RCLONE_GUI_PORT}" ]; then
			RCLONE_GUI_PORT=13666
			echo "note: RCLONE_GUI_PORT env variable not defined. Assigning default port: $RCLONE_GUI_PORT"
		fi
		
		if [ -z "${RCLONE_SERVE_GUI_PORT}" ]; then
			RCLONE_SERVE_GUI_PORT=13667
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

	if ! [ -z "${RCLONE_CONFIG_PASS}" ] || ! [ -z "${OP}" ] ; then
		RCLONE_CONFIG_OPTIONS=" --ask-password "
		if [ -z "${RCLONE_CONFIG_PASS}" ] ; then
			RCLONE_CONFIG_OPTIONS=' --ask-password --password-command "rclone reveal $OP" '
		fi
	fi
	

    if [ -z "${RCLONE_MOUNT_OPTIONS}" ]; then
        # set default values to use for rclone

        export RCLONE_MOUNT_OPTIONS=" --read-only --acd-templink-threshold 0 --buffer-size 1G --timeout 5s --contimeout 5s --dir-cache-time 24h --multi-thread-streams=20 $ASSIGN_PUID $ASSIGN_PGID "
        echo "note: RCLONE_MOUNT_OPTIONS env variable not defined. Assigning default options: $RCLONE_MOUNT_OPTIONS"
    fi
	
	if [ ! -z "${PUID}" ]; then
		# mount as plex user
		export RCLONE_MOUNT_OPTIONS="$RCLONE_MOUNT_OPTIONS --uid $PUID "
	fi
	if [ ! -z "${PGID}" ]; then
		# mount as plex user group
		export RCLONE_MOUNT_OPTIONS="$RCLONE_MOUNT_OPTIONS --gid $PGID "
	fi

	if [ -z "${RCLONE_CONFIG}" ]; then
		export RCLONE_CONFIG=/config/rclone/rclone.conf
		echo "note: RCLONE_CONFIG env variable not defined. Assigning default path: $RCLONE_CONFIG"
	fi
	RCLONE_CONFIG_DIR=${RCLONE_CONFIG%/*}
	mkdir -p $RCLONE_CONFIG_DIR

    if [ ! -f "${RCLONE_CONFIG}" ]; then
		GENERIC_RCLONE_CONFIG=/root/.config/rclone/rclone.conf
		echo "note: Rclone config file $RCLONE_CONFIG doesn't exist, using a generic file $GENERIC_RCLONE_CONFIG instead. Configurations for use with this file need to be configured using environment variables. See https://rclone.org/crypt/ and detailed instructions links at https://rclone.org/docs/ for details."
		RCLONE_CONFIG=$GENERIC_RCLONE_CONFIG
    fi

	if [ -z "${RCLONE_MOUNT_REMOTE_PATH}" ]; then
		export RCLONE_MOUNT_REMOTE_PATH="CRYPT:"
		echo "warning: RCLONE_MOUNT_REMOTE_PATH env variable not defined. Assigning default value: $RCLONE_MOUNT_REMOTE_PATH"	
	fi

	mkdir -p "$RCLONE_MOUNT_CONTAINER_PATH";
	chown -R abc:abc $RCLONE_MOUNT_CONTAINER_PATH;

	# start rclone
	if [ -z "${RCLONE_COMMAND}" ]; then
		RCLONE_COMMAND="mount $RCLONE_MOUNT_REMOTE_PATH $RCLONE_MOUNT_CONTAINER_PATH --allow-other --config $RCLONE_CONFIG $RCLONE_MOUNT_OPTIONS $RCLONE_GUI_CONFIG $RCLONE_CONFIG_OPTIONS"
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
        RCLONE_SERVE_PROTOCOL=sftp
        echo "note: RCLONE_SERVE_PROTOCOL env variable not defined. Assigning default password: $RCLONE_SERVE_PROTOCOL. (options: dlna, ftp, http, restic, sftp, webdav) see https://rclone.org/commands/rclone_serve/ for more info"
    fi

    if ! [[ $RCLONE_SERVE_PROTOCOL == "dlna" ]]; then
        if [ -z "${RCLONE_SERVE_USER}" ]; then
            RCLONE_SERVE_USER=$RCLONE_GUI_USER
            echo "note: RCLONE_SERVE_USER env variable not defined. Assigning default user: $RCLONE_SERVE_USER"
        fi

        if [ -z "${RCLONE_SERVE_PASSWORD}" ]; then
            RCLONE_SERVE_PASSWORD=$RCLONE_GUI_PASSWORD
            echo "note: RCLONE_SERVE_PASSWORD env variable not defined. Assigning default password: $RCLONE_SERVE_PASSWORD"
        fi
    fi
	if [[ $RCLONE_SERVE_PROTOCOL == "http" || $RCLONE_SERVE_PROTOCOL == "ftp" || $RCLONE_SERVE_PROTOCOL == "sftp" ]]; then
		RCLONE_SERVE_AUTH_CONFIG=" --user $RCLONE_SERVE_USER --pass $RCLONE_SERVE_PASSWORD "
	fi


    if [ -z "${RCLONE_SERVE_COMMAND}" ]; then
    # $RCLONE_GUI_CONFIG
        RCLONE_SERVE_COMMAND="serve $RCLONE_SERVE_PROTOCOL $RCLONE_MOUNT_REMOTE_PATH --config $RCLONE_CONFIG $RCLONE_MOUNT_OPTIONS --addr :$RCLONE_SERVE_PORT $RCLONE_SERVE_GUI_CONFIG $RCLONE_SERVE_AUTH_CONFIG "
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
echo "Plex URL: http://localhost:32400/web"
echo "RCLONE Management GUI for Plex: http://localhost:$RCLONE_GUI_PORT"
echo " "
if ! [ -z "${RCLONE_SERVE_PORT}" ]; then
	echo " "
	if [[ $RCLONE_SERVE_PROTOCOL == "webdav" ]]; then
		echo "RCLONE Network Drive: http://localhost:$RCLONE_SERVE_PORT"
		echo "Instructions for mounting as network drive in windows: https://www2.le.ac.uk/offices/itservices/ithelp/my-computer/files-and-security/work-off-campus/webdav/webdav-on-windows-10"
	fi
	if [[ $RCLONE_SERVE_PROTOCOL == "dlna" ]]; then
		echo "RCLONE Network Drive: http://localhost:$RCLONE_SERVE_PORT"
	fi
	if [[ $RCLONE_SERVE_PROTOCOL == "http" ]]; then
		echo "RCLONE Network Drive: http://$RCLONE_GUI_USER:$RCLONE_GUI_PASSWORD@localhost:$RCLONE_SERVE_PORT"
	fi
	if [[ $RCLONE_SERVE_PROTOCOL == "ftp" ]]; then
		echo "RCLONE Network Drive: ftp://$RCLONE_GUI_USER:$RCLONE_GUI_PASSWORD@localhost:$RCLONE_SERVE_PORT"
	fi
	if [[ $RCLONE_SERVE_PROTOCOL == "sftp" ]]; then
		echo "RCLONE Network Drive: sftp://$RCLONE_GUI_USER:$RCLONE_GUI_PASSWORD@localhost:$RCLONE_SERVE_PORT"
	fi
	echo "RCLONE Management GUI for Network Drive: http://localhost:$RCLONE_SERVE_GUI_PORT"
fi
echo " "
echo -------------------------------------