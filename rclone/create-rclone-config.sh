#!/usr/bin/with-contenv bash

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
    GENERIC_RCLONE_CONFIG=/root/.config/rclone/rclone.conf
    echo "note: Rclone config file $RCLONE_CONFIG doesn't exist, generating a generic file $GENERIC_RCLONE_CONFIG to be used instead. Configurations for use with this file need to be configured using environment variables. See https://rclone.org/crypt/ and detailed instructions links at https://rclone.org/docs/ for details."
    RCLONE_CONFIG=$GENERIC_RCLONE_CONFIG
    RCLONE_CONFIG_DIR=${RCLONE_CONFIG%/*}
    mkdir -p $RCLONE_CONFIG_DIR
    
    if ! [ -z "${RCLONE_CONFIG_ENCRYPTED}" ]  && ( ! [ -z "${RCLONE_CONFIG_PASS}" ] || ! [ -z "${OP}" ]  )  ; then
        cat << EOT > $RCLONE_CONFIG
# Encrypted rclone configuration File

RCLONE_ENCRYPT_V0:
EOT
        echo "$RCLONE_CONFIG_ENCRYPTED" >> $RCLONE_CONFIG
        echo "note: RCLONE_CONFIG_ENCRYPTED env variable defined. Applying overwriting rclone config $RCLONE_CONFIG with encrypted config"
    else
        cat << EOT > $RCLONE_CONFIG
[REMOTE]
type = drive

[CRYPT]
type = crypt
remote = REMOTE:

[PLEXDRIVE_CRYPT]
type = crypt
EOT
        if [ -z "${PLEXDRIVE_MOUNT_CONTAINER_PATH}" ]; then
            # duplicated from mount-plexdrive.sh as changes made there not accessible
            PLEXDRIVE_MOUNT_CONTAINER_PATH=/mnt/plexdrive/
        fi
        echo "remote = $PLEXDRIVE_MOUNT_CONTAINER_PATH" >> $RCLONE_CONFIG
        
cat << EOT > $RCLONE_CONFIG
[PLEXDRIVE_BB_CRYPT]
type = crypt
EOT
        echo "remote = /mnt/plexdrive_bigbuf/" >> $RCLONE_CONFIG

        echo "note: generic rclone config file $RCLONE_CONFIG contents:"
        cat $RCLONE_CONFIG
        echo "If you want to replace this with a different file, mount a volume containing a rclong.conf file and/or setup a new rclone.conf by running the command (replacing plex-rclone with your container name if different) ' docker exec -it plex-rclone rclone config --config $RCLONE_CONFIG ' Create a 'new remote' named $RCLONE_MOUNT_REMOTE_PATH  (without the : and any text following it), or add the name you choose followed by : to enviroment variable RCLONE_MOUNT_REMOTE_PATH"

    fi

fi