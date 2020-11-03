#!/bin/bash

# if -check flag set run check to see if its needed before reauthenticating
[ -z $1 ] || [ $1 != -check ] || ( [ "$(ls -A $MEDIA_MOUNT_CONTAINER_PATH)"  ] || [ "$(ls -A /plex/media/)" ] ) && echo "already authenticated" && exit 0

if [ -z "${RCLONE_CONFIG}" ]; then
    export RCLONE_CONFIG=/config/rclone/rclone.conf
    echo "note: RCLONE_CONFIG env variable not defined. Assigning default path: $RCLONE_CONFIG"
fi

RCLONE_CONFIG_DIR=${RCLONE_CONFIG%/*}
mkdir -p $RCLONE_CONFIG_DIR

if [ ! -f "${RCLONE_CONFIG}" ]; then
    RCLONE_CONFIG=/root/.config/rclone/rclone.conf
fi

if ! [ -z "${RCLONE_CONFIG_PASS}" ] || ! [ -z "${OP}" ] ; then
    if [ -z "${RCLONE_CONFIG_PASS}" ] ; then
        export RCLONE_CONFIG_PASS=$(rclone reveal $OP)
    fi
    RCLONE_CONFIG_EXPORT=$(rclone config show --config /root/.config/rclone/rclone.conf)
fi

if [ -z "${RCLONE_CONFIG_PASS}" ] && ! [ -z "${OP}" ] ; then
    export RCLONE_CONFIG_PASS=$(rclone reveal $OP)
    RCLONE_CONFIG_EXPORT=$(rclone config show --config /root/.config/rclone/rclone.conf)
fi


parse_config_updates(){

# wait for the  config file to be modified
while read i; do echo $i; if [ "$i" = $RCLONE_CONFIG ]; then break; fi; done \
   < <(inotifywait -m $RCLONE_CONFIG -e create -e move_self -e delete_self --format '%w' --quiet )

RCLONE_CONFIG_EXPORT=$(rclone config show --config $RCLONE_CONFIG)
echo $RCLONE_CONFIG_EXPORT | grep team_drive | sed -e 's#.*team_drive = \(\)#\1#' | cut -d' ' -f 1 > ${RCLONE_CONFIG_DIR}/team_drive.id
echo $RCLONE_CONFIG_EXPORT | grep token      | sed -e 's#.*token = \(\)#\1#'      | cut -d' ' -f 1 > ${RCLONE_CONFIG_DIR}/token.json
echo "${RCLONE_CONFIG_DIR}/token.json contents:"
cat ${RCLONE_CONFIG_DIR}/token.json
export RCLONE_CONFIG_PASS=

# remove files if they are empty
[ -s ${RCLONE_CONFIG_DIR}/team_drive.id ] || rm ${RCLONE_CONFIG_DIR}/team_drive.id
[ -s ${RCLONE_CONFIG_DIR}/token.json ]    || rm ${RCLONE_CONFIG_DIR}/token.json

#( [ -s ${RCLONE_CONFIG_DIR}/team_drive.id ]  && [ -s ${RCLONE_CONFIG_DIR}/team_drive.id ] &&  ) || ( echo "Authentication failed. Retrying" && $@ )

kill 1

}

parse_config_updates &
echo 
echo "********************************* Authentication Instructions ********************************* "
echo 
echo "To generate rcloen/plexdrive authenticationb token please do the folowing the steps: "
echo "1. When asked 'Use auto config?'"
echo "                        Answer: No"
echo "2. When to Please go to the following link: "
echo "                        Action: Cut and paste the URL into a browser an follow the steps until given a verificatiopn code"
echo "3. When you have the verificaion code in the browser window: "
echo "                        Action: Copy the code and paste it as the response to prompt 'Enter verification code:'"
echo "4. When asked 'Change current team drive ID ?' "
echo "                        Answer: No"


rclone config reconnect REMOTE: --config $RCLONE_CONFIG

