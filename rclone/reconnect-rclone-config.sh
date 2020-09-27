#!/bin/bash

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
   < <(inotifywait -m $RCLONE_CONFIG -e create -e moved_to -e close_write --format '%w' --quiet )

RCLONE_CONFIG_EXPORT=$(rclone config show --config $RCLONE_CONFIG)
echo $RCLONE_CONFIG_EXPORT | grep team_drive | sed -e 's#.*team_drive = \(\)#\1#' | cut -d' ' -f 1 > ${RCLONE_CONFIG_DIR}/team_drive.id
echo $RCLONE_CONFIG_EXPORT | grep token      | sed -e 's#.*token = \(\)#\1#'      | cut -d' ' -f 1 > ${RCLONE_CONFIG_DIR}/token.json
echo "${RCLONE_CONFIG_DIR}/token.json contents:"
cat ${RCLONE_CONFIG_DIR}/token.json
export RCLONE_CONFIG_PASS=
}

parse_config_updates &

rclone config reconnect REMOTE: --config $RCLONE_CONFIG





