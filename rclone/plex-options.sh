#!/usr/bin/with-contenv bash

PREFNAME="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Preferences.xml"
if [ ! -f "${PREFNAME}" ]; then
	echo "warning: $PREFNAME doesn't exist. Plex options not applied"
fi

add_if_missing()
{
  PREF=$1
  PREF_VAL_NAME=$PREF
  [ -z "$2" ] || PREF_VAL_NAME=$2
  PREF_VAL=${!PREF_VAL_NAME}

  if !  grep -qs "$PREF" "$PREFNAME" && ! [ -z "$PREF_VAL" ] ; then
	echo "$PREF defined, adding $PREF=${PREF_VAL} to $PREFNAME"
	sed -i "s|/>| $PREF=\"${PREF_VAL}\"\/>|g" "${PREFNAME}"
  fi
}

PREF_LIST='FriendlyName allowedNetworks autoEmptyTrash ButlerStartHour ButlerEndHour ButlerTaskDeepMediaAnalysis ButlerTaskUpgradeMediaAnalysis ButlerTaskRefreshLibraries DlnaEnabled GenerateChapterThumbBehavior LoudnessAnalysisBehavior ScheduledLibraryUpdateInterval ScheduledLibraryUpdatesEnabled TranscoderTempDirectory LanNetworksBandwidth TreatWanIpAsLocal RelayEnabled customConnections GenerateIntroMarkerBehavior allowMediaDeletion'

for PREF in $PREF_LIST
do
    add_if_missing $PREF
done

add_if_missing customConnections ADVERTISE_IP
