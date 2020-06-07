#!/usr/bin/with-contenv bash
if ! [[ $RCLONE == "FALSE" || $RCLONE == "false" || $RCLONE == "0" || $RCLONE == "False" ]] ; then 
	if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
		RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
		echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
	fi

	if [ -z "${RCLONE_MOUNT_REMOTE_PATH}" ]; then
		RCLONE_MOUNT_REMOTE_PATH="REMOTE:"
		echo "warning: RCLONE_MOUNT_REMOTE_PATH env variable not defined. Assigning default value: $RCLONE_MOUNT_REMOTE_PATH"	
	fi

	if [ -z "${RCLONE_MOUNT_CONTAINER_PATH}" ]; then
		RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone/
		echo "note: RCLONE_MOUNT_CONTAINER_PATH env variable not defined. Assigning default path: $RCLONE_MOUNT_CONTAINER_PATH"
	fi

	if [ -z "${RCLONE_MOUNT_OPTIONS}" ]; then
		RCLONE_MOUNT_OPTIONS=" --read-only --allow-other --acd-templink-threshold 0 --stats 1s --buffer-size 1G --timeout 5s --contimeout 5s "
		echo "note: RCLONE_MOUNT_OPTIONS env variable not defined. Assigning default options: $RCLONE_MOUNT_OPTIONS"
	fi

	if [ -z "${RCLONE_CONFIG}" ]; then
		RCLONE_CONFIG=/config/rclone/rclone.conf
		echo "note: RCLONE_CONFIG env variable not defined. Assigning default path: $RCLONE_CONFIG"
	fi

	if [ ! -f "${RCLONE_CONFIG}" ]; then
		echo "warning: Rclone config file $RCLONE_CONFIG doesn't exist. Mount a volume containing one and/or setup your own by running the command below (replacing plex-rclone with your container name if different) ' docker exec -it plex-rclone rclone config --config $RCLONE_CONFIG ' Create a 'new remote' named $RCLONE_MOUNT_REMOTE_PATH  (without the : and any text following it), or add the name you chose followed by : to enviroment variable RCLONE_MOUNT_REMOTE_PATH"
	fi

	mkdir -p "$RCLONE_MOUNT_CONTAINER_PATH";
	chown -R abc:abc $RCLONE_MOUNT_CONTAINER_PATH;

	# start rclone
	if [ -z "${RCLONE_COMMAND}" ]; then
		RCLONE_COMMAND="mount $RCLONE_MOUNT_REMOTE_PATH $RCLONE_MOUNT_CONTAINER_PATH --config $RCLONE_CONFIG $RCLONE_MOUNT_OPTIONS"
	fi

	# start rclone
	echo "Starting rclone: rclone $RCLONE_COMMAND"
	rclone $RCLONE_COMMAND &
fi
