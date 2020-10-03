#!/usr/bin/with-contenv bash

PREFNAME="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Preferences.xml"
if [ ! -f "${PREFNAME}" ]; then
	echo "warning: $PREFNAME doesn't exist. Plex options not applied"
fi

#!/usr/bin/with-contenv bash

CUSTOM_PROFILE_FOLDER= /root/.plex/custom_profiles

for PROFILE in $CUSTOM_PLEX_PROFILES
do
    if $(ls $CUSTOM_PROFILE_FOLDER | grep --ignore-case -q  $PROFILE) ; then 
        PROFILE_FILE=$CUSTOM_PROFILE_FOLDER/$(ls $CUSTOM_PROFILE_FOLDER | grep --ignore-case $PROFILE)
    else
        PROFILE_FILE=
    fi
if [ ! -f "${PROFILE_FILE}" ]; then
	echo "overwriting default $PROFILE profile with customised profile"
    cp $PROFILE_FILE /usr/lib/plexmediaserver/Resources/Profiles/
fi

done
