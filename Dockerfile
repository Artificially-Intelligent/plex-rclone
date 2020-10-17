ARG SOURCE_IMAGE=linuxserver/plex
ARG SOURCE_TAG=latest
FROM  $SOURCE_IMAGE:$SOURCE_TAG

ARG BLD_DATE
ARG MAINTAINER=slink42
ARG SOURCE_REPO=Artificially-Intelligent/plex-rclone
ARG SOURCE_BRANCH=master
ARG SOURCE_COMMIT=XXXXXXXX
ARG DEST_IMAGE="ArtificiallyIntelligent/plex-rclone"

ENV SOURCE_DOCKER_IMAGE=$SOURCE_IMAGE:$SOURCE_TAG
ENV SOURCE_REPO=$SOURCE_REPO
ENV SOURCE_BRANCH=$SOURCE_BRANCH
ENV SOURCE_COMMIT=$SOURCE_COMMIT
ENV DOCKER_IMAGE=$DEST_IMAGE
ENV BUILD_DATE=$BUILD_DATE

# add image labels
LABEL build_version="$DOCKER_IMAGE version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL build_source="$SOURCE_BRANCH - https://github.com/${SOURCE_REPO}/commit/${SOURCE_COMMIT}"
LABEL maintainer="$MAINTAINER"

RUN \
 echo "**** install rclone / plexdrive dependencies ****" && \
 apt-get update && \
 apt-get install -y \
  # setup / install / config script dependencies
  perl \
  wget \
  unzip \
  inotify-tools \
  # rclone dependencies
  ca-certificates \
  fuse \
  # rclone gui dependency
  xdg-utils \
  #nfs server
  nfs-kernel-server \
  && \
  echo "user_allow_other" >> /etc/fuse.conf 
 
RUN echo "**** install latest rclone ****" && \
  wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
  dpkg -i rclone-current-linux-amd64.deb && \
  rm rclone-current-linux-amd64.deb && \
  mkdir -p /root/.cache/rclone/webgui/

# # Copy rclone webgui to rclone cache
# ADD https://github.com/rclone/rclone-webui-react/releases/download/v0.1.0/currentbuild.zip /root/.cache/rclone/webgui/v0.1.0.zip
# RUN  unzip /root/.cache/rclone/webgui/v0.1.0.zip 'build/*' -d /root/.cache/rclone/webgui/current/ && \
#   echo 'v0.1.0' > /root/.cache/rclone/webgui/tag

RUN echo "**** install rclone-webui v0.1.0 - latest available 2020-06-10 ****" && \
  wget https://github.com/rclone/rclone-webui-react/releases/download/v0.1.0/currentbuild.zip && \ 
  unzip currentbuild.zip 'build/*' -d /root/.cache/rclone/webgui/current/ && \
  echo 'v0.1.0' > /root/.cache/rclone/webgui/tag && \
  rm currentbuild.zip

RUN echo "**** install plexdrive 5.1.0 - latest available 2020-06-10 ****" && \
  wget https://github.com/plexdrive/plexdrive/releases/download/5.1.0/plexdrive-linux-amd64 && \
  mv ./plexdrive-linux-amd64 /usr/bin/plexdrive && \
  chmod +x /usr/bin/plexdrive

 # Copy gdrive file downloader script
COPY gdown.pl /usr/bin/gdown.pl

 # Copy plex_media_scanner.sh into place ready for /etc/cont-init.d/48-replace-plex-media-scanner
COPY rclone/plex-media-scanner.sh /usr/bin/plex_media_scanner.sh

# Copy rcone startup script to init.d
COPY rclone/create-rclone-config.sh /etc/cont-init.d/30-create-rclone-config
COPY rclone/create-plexdrive-config.sh /etc/cont-init.d/31-create-plexdrive-config
COPY rclone/setup-rclone-folders.sh /etc/cont-init.d/32-setup-rclone-folders

COPY rclone/plex-options.sh /etc/cont-init.d/43-plex-options
COPY rclone/plex-library-from-master.sh /etc/cont-init.d/47-plex-library-from-master

COPY rclone/replace-plex-media-scanner.sh /etc/cont-init.d/61-replace-plex-media-scanner
COPY rclone/plex-profiles.sh /etc/cont-init.d/62-plex-profiles

COPY rclone/print_plex_prefrences.sh /etc/cont-init.d/99-print_plex_prefrences

COPY rclone/reconnect-rclone-config.sh /usr/bin/authenticate
COPY rclone/mount-plexdrive.sh /usr/bin/mount-plexdrive
COPY rclone/mount-rclone.sh /usr/bin/mount-rclone
COPY rclone/link-to-active-mount.sh /usr/bin/link-to-active-mount

ADD rclone/services.d /etc/services.d.inactive

RUN  chmod -R +x /etc/cont-init.d/* /etc/services.d.inactive/* /usr/bin/gdown.pl /usr/bin/plex_media_scanner.sh /usr/bin/authenticate /usr/bin/mount-plexdrive /usr/bin/mount-rclone /usr/bin/link-to-active-mount

ADD https://raw.githubusercontent.com/Artificially-Intelligent/plex-profiles/master/Chromecast.xml /root/.plex/custom_profiles/Chromecast.xml

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
ENV RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
ENV RCLONE_GUI_PORT=13668
ENV RCLONE_SERVE_GUI_PORT=13669
ENV RCLONE_GUI_USER=rclone
ENV RCLONE_GUI_PASSWORD=rclone
ENV DO_HEALTH_CHECK=true
ENV HEALTH_CHECK_KILL=false

# Check to see if active rclone or plexdrive mount is connected properly by checking MEDIA_MOUNT_CONTAINER_PATH for if any files are present
HEALTHCHECK --interval=5m --timeout=3s \
  CMD ! $DO_HEALTH_CHECK || [ "$(ls -A $MEDIA_MOUNT_CONTAINER_PATH)"  ] || [ "$(ls -A /plex/media/)" ]  || ! echo "Health Check Failed" || ( $HEALTH_CHECK_KILL && echo "Stopping Container" && kill 1 ) || exit 1
