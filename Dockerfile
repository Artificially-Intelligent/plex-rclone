FROM  linuxserver/plex:latest

RUN \
 echo "**** install fuse & rclone ****" && \
 apt-get update && \
 apt-get install -y \
  perl \
  wget \
  rclone \
  ca-certificates \
  fuse && \
  echo "user_allow_other" >> /etc/fuse.conf && \
  mkdir /mnt/rclone

RUN echo "**** install plexdrive ****" && \
  wget https://github.com/plexdrive/plexdrive/releases/download/5.1.0/plexdrive-linux-amd64 && \
  mv ./plexdrive-linux-amd64 /usr/bin/plexdrive && \
  chmod +x /usr/bin/plexdrive

 # Copy gdrive file downloader script
COPY gdown.pl /usr/bin/gdown.pl

  # Copy rcone startup script to init.d
COPY 41-mount-plexdrive.sh /etc/cont-init.d/41-mount-plexdrive
COPY 42-mount-rclone.sh /etc/cont-init.d/42-mount-rclone
RUN  chmod +x /etc/cont-init.d/* /usr/bin/gdown.pl

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
