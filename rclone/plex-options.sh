#!/usr/bin/with-contenv bash

PREFNAME="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Preferences.xml"


if !  grep -qs "allowedNetworks" "$PREFNAME" && ! [ -z "$allowedNetworks" ] ; then
	echo "allowedNetworks defined, adding allowedNetworks=$allowedNetworks to $PREFNAME"
	sed -i "s|/>| allowedNetworks=\"${allowedNetworks}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "autoEmptyTrash" "$PREFNAME" && ! [ -z "$autoEmptyTrash" ] ; then
	echo "autoEmptyTrash defined, adding autoEmptyTrash=$autoEmptyTrash to $PREFNAME"
	sed -i "s/\/>/ autoEmptyTrash=\"${autoEmptyTrash}\"\/>/g" "${PREFNAME}"
fi
if ! grep -qs "ButlerEndHour" "$PREFNAME" && ! [ -z "$ButlerEndHour" ] ; then
	echo "ButlerEndHour defined, adding ButlerEndHour=$ButlerEndHour to $PREFNAME"
	sed -i "s/\/>/ ButlerEndHour=\"${ButlerEndHour}\"\/>/g" "${PREFNAME}"
fi
if ! grep -qs "ButlerStartHour" "$PREFNAME" && ! [ -z "$ButlerStartHour" ]; then
	echo "ButlerStartHour defined, adding ButlerStartHour=$ButlerStartHour to $PREFNAME"
	sed -i "s/\/>/ ButlerStartHour=\"${ButlerStartHour}\"\/>/g" "${PREFNAME}"
fi
if ! grep -qs "ButlerTaskDeepMediaAnalysis" "$PREFNAME" && ! [ -z "$ButlerTaskDeepMediaAnalysis" ]; then
	echo "ButlerTaskDeepMediaAnalysis defined, adding ButlerTaskDeepMediaAnalysis=$ButlerTaskDeepMediaAnalysis to $PREFNAME"
	sed -i "s/\/>/ ButlerTaskDeepMediaAnalysis=\"${ButlerTaskDeepMediaAnalysis}\"\/>/g" "${PREFNAME}"
fi
if ! grep -qs "ButlerTaskUpgradeMediaAnalysis" "$PREFNAME" && ! [ -z "$ButlerTaskUpgradeMediaAnalysis" ]; then
	echo "ButlerTaskUpgradeMediaAnalysis defined, adding ButlerTaskUpgradeMediaAnalysis=$ButlerTaskUpgradeMediaAnalysis to $PREFNAME"
	sed -i "s/\/>/ ButlerTaskUpgradeMediaAnalysis=\"${ButlerTaskUpgradeMediaAnalysis}\"\/>/g" "${PREFNAME}"
fi
if ! grep -qs "DlnaEnabled" "$PREFNAME" && ! [ -z "$DlnaEnabled" ]; then
	echo "DlnaEnabled defined, adding DlnaEnabled=$DlnaEnabled to $PREFNAME"
	sed -i "s/\/>/ DlnaEnabled=\"${DlnaEnabled}\"\/>/g" "${PREFNAME}"
fi
