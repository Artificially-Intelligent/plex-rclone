FROM  linuxserver/plex:latest

# Copy rcone startup script to init.d
COPY 40-mount-rclone /etc/cont-init.d/40-mount-rclone

RUN \
 echo "**** install fuse & rclone ****" && \
 chmod +x /etc/cont-init.d/40-mount-rclone && \
 apt-get update && \
 apt-get install -y \
  rclone \
  ca-certificates \
  fuse && \
  echo "user_allow_other" >> /etc/fuse.conf && \
  mkdir /mnt/rclone

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
