#!/usr/bin/with-contenv bash

PREFNAME="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Preferences.xml"

if !  grep -qs "FriendlyName" "$PREFNAME" && ! [ -z "$FriendlyName" ] ; then
	echo "FriendlyName defined, adding FriendlyName=$FriendlyName to $PREFNAME"
	sed -i "s|/>| FriendlyName=\"${FriendlyName}\"\/>|g" "${PREFNAME}"
fi
if !  grep -qs "allowedNetworks" "$PREFNAME" && ! [ -z "$allowedNetworks" ] ; then
	echo "allowedNetworks defined, adding allowedNetworks=$allowedNetworks to $PREFNAME"
	sed -i "s|/>| allowedNetworks=\"${allowedNetworks}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "autoEmptyTrash" "$PREFNAME" && ! [ -z "$autoEmptyTrash" ] ; then
	echo "autoEmptyTrash defined, adding autoEmptyTrash=$autoEmptyTrash to $PREFNAME"
	sed -i "s|/>| autoEmptyTrash=\"${autoEmptyTrash}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "ButlerEndHour" "$PREFNAME" && ! [ -z "$ButlerEndHour" ] ; then
	echo "ButlerEndHour defined, adding ButlerEndHour=$ButlerEndHour to $PREFNAME"
	sed -i "s|/>| ButlerEndHour=\"${ButlerEndHour}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "ButlerStartHour" "$PREFNAME" && ! [ -z "$ButlerStartHour" ]; then
	echo "ButlerStartHour defined, adding ButlerStartHour=$ButlerStartHour to $PREFNAME"
	sed -i "s|/>| ButlerStartHour=\"${ButlerStartHour}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "ButlerTaskDeepMediaAnalysis" "$PREFNAME" && ! [ -z "$ButlerTaskDeepMediaAnalysis" ]; then
	echo "ButlerTaskDeepMediaAnalysis defined, adding ButlerTaskDeepMediaAnalysis=$ButlerTaskDeepMediaAnalysis to $PREFNAME"
	sed -i "s|/>| ButlerTaskDeepMediaAnalysis=\"${ButlerTaskDeepMediaAnalysis}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "ButlerTaskUpgradeMediaAnalysis" "$PREFNAME" && ! [ -z "$ButlerTaskUpgradeMediaAnalysis" ]; then
	echo "ButlerTaskUpgradeMediaAnalysis defined, adding ButlerTaskUpgradeMediaAnalysis=$ButlerTaskUpgradeMediaAnalysis to $PREFNAME"
	sed -i "s|/>| ButlerTaskUpgradeMediaAnalysis=\"${ButlerTaskUpgradeMediaAnalysis}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "DlnaEnabled" "$PREFNAME" && ! [ -z "$DlnaEnabled" ]; then
	echo "DlnaEnabled defined, adding DlnaEnabled=$DlnaEnabled to $PREFNAME"
	sed -i "s|/>| DlnaEnabled=\"${DlnaEnabled}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "GenerateChapterThumbBehavior" "$PREFNAME" && ! [ -z "$GenerateChapterThumbBehavior" ]; then
	echo "GenerateChapterThumbBehavior defined, adding GenerateChapterThumbBehavior=$GenerateChapterThumbBehavior to $PREFNAME"
	sed -i "s|/>| GenerateChapterThumbBehavior=\"${GenerateChapterThumbBehavior}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "LoudnessAnalysisBehavior" "$PREFNAME" && ! [ -z "$LoudnessAnalysisBehavior" ]; then
	echo "LoudnessAnalysisBehavior defined, adding LoudnessAnalysisBehavior=$LoudnessAnalysisBehavior to $PREFNAME"
	sed -i "s|/>| LoudnessAnalysisBehavior=\"${LoudnessAnalysisBehavior}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "ScheduledLibraryUpdateInterval" "$PREFNAME" && ! [ -z "$ScheduledLibraryUpdateInterval" ]; then
	echo "ScheduledLibraryUpdateInterval defined, adding ScheduledLibraryUpdateInterval=$ScheduledLibraryUpdateInterval to $PREFNAME"
	sed -i "s|/>| ScheduledLibraryUpdateInterval=\"${ScheduledLibraryUpdateInterval}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "ScheduledLibraryUpdatesEnabled" "$PREFNAME" && ! [ -z "$ScheduledLibraryUpdatesEnabled" ]; then
	echo "ScheduledLibraryUpdatesEnabled defined, adding ScheduledLibraryUpdatesEnabled=$ScheduledLibraryUpdatesEnabled to $PREFNAME"
	sed -i "s|/>| ScheduledLibraryUpdatesEnabled=\"${ScheduledLibraryUpdatesEnabled}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "ButlerTaskRefreshLibraries" "$PREFNAME" && ! [ -z "$ButlerTaskRefreshLibraries" ]; then
	echo "ButlerTaskRefreshLibraries defined, adding ButlerTaskRefreshLibraries=$ButlerTaskRefreshLibraries to $PREFNAME"
	sed -i "s|/>| ButlerTaskRefreshLibraries=\"${ButlerTaskRefreshLibraries}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "TranscoderTempDirectory" "$PREFNAME" && ! [ -z "$TranscoderTempDirectory" ]; then
	echo "TranscoderTempDirectory defined, adding TranscoderTempDirectory=$TranscoderTempDirectory to $PREFNAME"
	sed -i "s|/>| TranscoderTempDirectory=\"${TranscoderTempDirectory}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "LanNetworksBandwidth" "$PREFNAME" && ! [ -z "$LanNetworksBandwidth" ]; then
	echo "LanNetworksBandwidth defined, adding LanNetworksBandwidth=$LanNetworksBandwidth to $PREFNAME"
	sed -i "s|/>| LanNetworksBandwidth=\"${LanNetworksBandwidth}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "TreatWanIpAsLocal" "$PREFNAME" && ! [ -z "$TreatWanIpAsLocal" ]; then
	echo "TreatWanIpAsLocal defined, adding TreatWanIpAsLocal=$TreatWanIpAsLocal to $PREFNAME"
	sed -i "s|/>| TreatWanIpAsLocal=\"${TreatWanIpAsLocal}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "RelayEnabled" "$PREFNAME" && ! [ -z "$RelayEnabled" ]; then
	echo "RelayEnabled defined, adding RelayEnabled=$RelayEnabled to $PREFNAME"
	sed -i "s|/>| RelayEnabled=\"${RelayEnabled}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "customConnections" "$PREFNAME" && ! [ -z "$customConnections" ]; then
	echo "customConnections defined, adding customConnections=$customConnections to $PREFNAME"
	sed -i "s|/>| customConnections=\"${customConnections}\"\/>|g" "${PREFNAME}"
fi
if ! grep -qs "customConnections" "$PREFNAME" && ! [ -z "$ADVERTISE_IP" ]; then
	echo "ADVERTISE_IP defined, adding customConnections=$ADVERTISE_IP to $PREFNAME"
	sed -i "s|/>| customConnections=\"${ADVERTISE_IP}\"\/>|g" "${PREFNAME}"
fi

echo "$PREFNAME contents:"
echo "__________________________________________________________________________"
cat $PREFNAME
echo "__________________________________________________________________________"