#!/bin/bash

# Delete rclone / plexdrive tokens and Plex Preferences.xml

rm /config/Library/Application\ Support/Plex\ Media\ Server/Preferences.xml
rm /config/plexdrive/*.json
rm /config/plexdrive/*.id
rm /config/rclone/*

