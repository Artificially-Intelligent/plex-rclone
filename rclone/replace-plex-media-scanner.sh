#!/usr/bin/with-contenv bash
plex_media_scanner_bin="/usr/lib/plexmediaserver/Plex Media Scanner"
moved_plex_media_scanner_bin="$plex_media_scanner_bin-real"

if ! [ -f "$moved_plex_media_scanner_bin" ]; then
    echo "moving Plex Media Scanner and replacing with mount script which passes though calls to new location"
    mv "$plex_media_scanner_bin" "$moved_plex_media_scanner_bin"
    cp /usr/bin/plex_media_scanner.sh "$plex_media_scanner_bin"
fi