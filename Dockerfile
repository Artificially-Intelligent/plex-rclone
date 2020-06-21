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

 
  # Copy rcone startup script to init.d
COPY rclone/mount-plexdrive.sh /etc/cont-init.d/30-mount-plexdrive
COPY rclone/mount-rclone.sh /etc/cont-init.d/31-mount-rclone
COPY rclone/plex-options.sh /etc/cont-init.d/46-plex-options
COPY rclone/plex-library-from-master.sh /etc/cont-init.d/47-plex-library-from-master

RUN  chmod +x /etc/cont-init.d/* /usr/bin/gdown.pl

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
ENV RCLONE_MOUNT_CONTAINER_PATH=/mnt/rclone
ENV RCLONE_GUI_PORT=13668
ENV RCLONE_SERVE_GUI_PORT=13669
ENV RCLONE_GUI_USER=rclone
ENV RCLONE_GUI_PASSWORD=rclone