#!/usr/bin/with-contenv bash

PREFNAME="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Preferences.xml"
if [ ! -f "${PREFNAME}" ]; then
	echo "warning: $PREFNAME doesn't exist. Plex options not applied"
fi
echo "$PREFNAME contents:"
echo "__________________________________________________________________________"
cat "$PREFNAME"
echo "__________________________________________________________________________"