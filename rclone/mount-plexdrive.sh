#!/usr/bin/with-contenv bash


while [ "$1" != "" ]; do
    case $1 in
        -p | --mount-plexdrive )    MOUNT_PLEXDRIVE=TRUE
                                ;;
        -c | --mount-crypt )    MOUNT_CRYPT=TRUE
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo_and_run() { echo "$*" ; "$@" ; }


if [ -z "${PLEXDRIVE_CONFIG_PATH}" ]; then
    PLEXDRIVE_CONFIG_PATH=/config/plexdrive/
    echo "note: PLEXDRIVE_CONFIG_PATH env variable not defined. Assigning default path: $PLEXDRIVE_CONFIG_PATH"
fi

if [ -f "${PLEXDRIVE_CONFIG_PATH}/team_drive.id" ]; then
    PLEXDRIVE_DRIVE_TEAM_DRIVE=$(cat ${PLEXDRIVE_CONFIG_PATH}/team_drive.id)
    PLEXDRIVE_TEAM_DRIVE_OPTIONS=" --drive-id=$PLEXDRIVE_DRIVE_TEAM_DRIVE "
    echo "note: ${PLEXDRIVE_CONFIG_PATH}/team_drive.id found defined. Adding $PLEXDRIVE_TEAM_DRIVE_OPTIONS to plexdrive options"
fi

if [ -z "${PLEXDRIVE_MOUNT_CONTAINER_PATH}" ]; then
    PLEXDRIVE_MOUNT_CONTAINER_PATH=/mnt/plexdrive
    echo "note: PLEXDRIVE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $PLEXDRIVE_MOUNT_CONTAINER_PATH"
fi

mount_drive()
{
    if ! [ -z "$1" ]; then
        export PLEXDRIVE_MOUNT_CONTAINER_PATH=$1
        echo "note: PLEXDRIVE_MOUNT_CONTAINER_PATH env variable set: $PLEXDRIVE_MOUNT_CONTAINER_PATH"
    fi

    if ! [ -z "$2" ]; then
        export PLEXDRIVE_CHUNK_SIZE=$2
        echo "note: PLEXDRIVE_CHUNK_SIZE env variable set: $PLEXDRIVE_CHUNK_SIZE"
        
        att=chunk-size
        value=${PLEXDRIVE_CHUNK_SIZE}M
        PLEXDRIVE_MOUNT_OPTIONS=$(echo $PLEXDRIVE_MOUNT_OPTIONS | sed "s|$att\=[^\ ]*\"|$att=$value|g")
    fi

    if ! [ -z "$3" ]; then
        export PLEXDRIVE_CACHE_OPTIONS="--cache-file=$3"
        cp "${PLEXDRIVE_CONFIG_PATH}cache.bolt" $3
        echo "note: plexdrive options cache set: $PLEXDRIVE_CACHE_OPTIONS"

        PLEXDRIVE_COMMAND="mount $PLEXDRIVE_MOUNT_OPTIONS $PLEXDRIVE_TEAM_DRIVE_OPTIONS $PLEXDRIVE_CACHE_OPTIONS $PLEXDRIVE_MOUNT_CONTAINER_PATH"
    fi
    
    if ! [ -d "${PLEXDRIVE_MOUNT_CONTAINER_PATH}" ]; then
        mkdir -p "$PLEXDRIVE_MOUNT_CONTAINER_PATH";
        chown -R abc:abc $PLEXDRIVE_MOUNT_CONTAINER_PATH;
    fi

    if [ -z "${PLEXDRIVE_CHUNK_SIZE}" ]; then
        PLEXDRIVE_CHUNK_SIZE=20
        echo "note: PLEXDRIVE_CHUNK_SIZE env variable not defined. Assigning default chunk size: $PLEXDRIVE_CHUNK_SIZE M (Total buffer size: $((4*$PLEXDRIVE_CHUNK_SIZE))M)" 
    fi

    if [ -z "${PLEXDRIVE_MOUNT_OPTIONS}" ]; then
        PLEXDRIVE_MOUNT_OPTIONS=" -o read_only -v 2 --max-chunks=10 --chunk-size=$(echo $PLEXDRIVE_CHUNK_SIZE)M --chunk-check-threads=20 --chunk-load-threads=4 --chunk-load-ahead=5 "
        echo "note: PLEXDRIVE_MOUNT_OPTIONS env variable not defined. Assigning default options: $PLEXDRIVE_MOUNT_OPTIONS"
    fi

    if [ -z "${PLEXDRIVE_COMMAND}" ]; then
        PLEXDRIVE_COMMAND="mount $PLEXDRIVE_MOUNT_OPTIONS $PLEXDRIVE_TEAM_DRIVE_OPTIONS $PLEXDRIVE_CACHE_OPTIONS $PLEXDRIVE_MOUNT_CONTAINER_PATH -c $PLEXDRIVE_CONFIG_PATH "
    fi

    #start PLEXDRIVE
    echo "Starting PLEXDRIVE: plexdrive $PLEXDRIVE_COMMAND"
    ! [ -z "${PLEXDRIVE_MOUNT_CONTAINER_PATH}" ] && $(mount | grep -q "${PLEXDRIVE_MOUNT_CONTAINER_PATH}") && echo "unmounting ${PLEXDRIVE_MOUNT_CONTAINER_PATH}" && fusermount -uz "$PLEXDRIVE_MOUNT_CONTAINER_PATH"
    plexdrive $PLEXDRIVE_COMMAND
}

    # att=chunk-size
    # value=50M
    # PLEXDRIVE_LARGE_BUFFER_MOUNT_OPTIONS=$(echo $PLEXDRIVE_MOUNT_OPTIONS | sed "s|$att\=[^\ ]*\"|$att=$value|g")
    # PLEXDRIVE_LARGE_BUFFER_MOUNT_CONTAINER_PATH="$PLEXDRIVE_MOUNT_CONTAINER_PATH-large-buffer"

    # mkdir -p "$PLEXDRIVE_LARGE_BUFFER_MOUNT_CONTAINER_PATH";
    # chown -R abc:abc $PLEXDRIVE_LARGE_BUFFER_MOUNT_CONTAINER_PATH;

    # if [ -z "${PLEXDRIVE_COMMAND}" ]; then
    #     PLEXDRIVE_COMMAND="mount $PLEXDRIVE_LARGE_BUFFER_MOUNT_OPTIONS $PLEXDRIVE_TEAM_DRIVE_OPTIONS $PLEXDRIVE_LARGE_BUFFER_MOUNT_CONTAINER_PATH"
    # fi
    # export RCLONE_CONFIG_PASS=
    # #start PLEXDRIVE
    # echo "Starting PLEXDRIVE: plexdrive $PLEXDRIVE_COMMAND"
    # plexdrive $PLEXDRIVE_COMMAND &

    ############ Decrypt Plexdrive with RCLONE #####################

	# set default values to use for rclone crypt over plexdrive mount

    if [ -z "${PLEXDRIVE_RCLONE_MOUNT_OPTIONS}" ]; then

		# if [ ! -z "${PUID}" ]; then
		# 	# mount as plex user
		# 	ASSIGN_PUID=" --uid $PUID "
		# fi
		# if [ ! -z "${PGID}" ]; then
		# 	# mount as plex user group
		# 	ASSIGN_PGID=" --gid $PGID "
		# fi

        PLEXDRIVE_RCLONE_MOUNT_OPTIONS=" --read-only $ASSIGN_PUID $ASSIGN_PGID "
        echo "note: PLEXDRIVE_RCLONE_MOUNT_OPTIONS env variable not is defined. Assigning default value PLEXDRIVE_RCLONE_MOUNT_OPTIONS=$PLEXDRIVE_RCLONE_MOUNT_OPTIONS"
    fi


mount_crypt()
{    
    if ! [ -z "$1" ]; then
        export PLEXDRIVE_MOUNT_CONTAINER_PATH=$1
    fi

    if ! [ -z "$2" ]; then
        export PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH=$2
        export PLEXDRIVE_RCLONE_GUI_PORT=15671
        export PLEXDRIVE_RCLONE_SERVE_PORT=15672
        export PLEXDRIVE_RCLONE_SERVE_GUI_PORT=15673
    fi
    
    if ! [ -z "$3" ]; then
        export PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH=$3
    fi

    if [ -z "${PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH}" ]; then
        #allows users to define a different RCLONE_MOUNT_REMOTE_PATH for plexdrive so 
        #config can be changed to plexdrive by changing only PLEXDRIVE==TRUE anloter value
        PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH="PLEXDRIVE_CRYPT:"
        echo "note: PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH env variable not is defined. Assigning default value PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH=$PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH"
    fi

    if [ -z "${PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH}" ]; then
        export PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH=/mnt/plexdrive_decrypted
        echo "note: PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH"
    fi

    if [ -z "${PLEXDRIVE_RCLONE_GUI_PORT}" ]; then
        export PLEXDRIVE_RCLONE_GUI_PORT=13671
        echo "note: PLEXDRIVE_RCLONE_GUI_PORT env variable not defined. Assigning default port: $PLEXDRIVE_RCLONE_GUI_PORT"
    fi
    if [ -z "${PLEXDRIVE_RCLONE_SERVE_PORT}" ]; then
        export PLEXDRIVE_RCLONE_SERVE_PORT=13672
        echo "note: PLEXDRIVE_RCLONE_SERVE_PORT env variable not defined. Assigning default path: $PLEXDRIVE_RCLONE_SERVE_PORT"
    fi
    if [ -z "${PLEXDRIVE_RCLONE_SERVE_GUI_PORT}" ]; then
        export PLEXDRIVE_RCLONE_SERVE_GUI_PORT=13673
        echo "note: PLEXDRIVE_RCLONE_SERVE_GUI_PORT env variable not defined. Assigning default path: $PLEXDRIVE_RCLONE_SERVE_GUI_PORT"
    fi

    if ! [ -d "${PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH}" ]; then
        mkdir -p "$PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH";
        chown -R abc:abc $PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH;
    fi

    # export RCLONE_MOUNT_OPTIONS=$PLEXDRIVE_RCLONE_MOUNT_OPTIONS
    # export RCLONE_MOUNT_CONTAINER_PATH=$PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH
    # export RCLONE_MOUNT_REMOTE_PATH=$PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH
    # export RCLONE_GUI_PORT=$PLEXDRIVE_RCLONE_GUI_PORT
    # export RCLONE_SERVE_PORT=$PLEXDRIVE_RCLONE_SERVE_PORT
    # export RCLONE_SERVE_GUI_PORT=$PLEXDRIVE_RCLONE_SERVE_GUI_PORT

    RCLONE_MOUNT_SCRIPT=/usr/bin/mount-rclone
    RCLONE_MOUNT_SCRIPT_COMMAND="--mount-options '$PLEXDRIVE_RCLONE_MOUNT_OPTIONS' \
    --container-path '$PLEXDRIVE_RCLONE_MOUNT_CONTAINER_PATH' \
    --remote-path '$PLEXDRIVE_RCLONE_MOUNT_REMOTE_PATH' \
    --gui-port '$PLEXDRIVE_RCLONE_GUI_PORT' \
    --serve-port '$PLEXDRIVE_RCLONE_SERVE_PORT' \
    --serve-gui-port '$PLEXDRIVE_RCLONE_SERVE_GUI_PORT'"

    echo "starting script to setup rclone crypt for plexdrive mount. command: $RCLONE_MOUNT_SCRIPT $RCLONE_MOUNT_SCRIPT_COMMAND"
    eval $RCLONE_MOUNT_SCRIPT $RCLONE_MOUNT_SCRIPT_COMMAND
}

if ! [ -z "${MOUNT_PLEXDRIVE}" ] ; then
    mount_drive
fi
if ! [ -z "${MOUNT_CRYPT}" ] ; then
    mount_crypt
fi

# mount_drive /mnt/plexdrive_bigbuf 50 /root/.plexdrive/bigbuf_cache.bolt
# mount_crypt /mnt/plexdrive_bigbuf "PLEXDRIVE_BB_CRYPT:" /mnt/plexdrive_bigbuf_decrypted

