ARG SOURCE_IMAGE=linuxserver/plex
ARG SOURCE_TAG=latest
FROM  $SOURCE_IMAGE:$SOURCE_TAG


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
COPY rclone/mount-plexdrive.sh /etc/cont-init.d/41-mount-plexdrive
COPY rclone/mount-rclone.sh /etc/cont-init.d/42-mount-rclone
RUN  chmod +x /etc/cont-init.d/* /usr/bin/gdown.pl


# # Copy FTP config
# ENV FTP_USER rclone
# ENV FTP_PASS rclone
# ENV PASV_ADDRESS REQUIRED
# COPY ftp/run-vsftpd.sh /etc/cont-init.d/43-run-vsftpd.sh
# COPY ftp/vsftpd.conf /etc/vsftpd/vsftpd.conf
# COPY ftp/vsftpd_virtual /etc/pam.d/vsftpd_virtual

# RUN chmod +x /etc/cont-init.d/43-run-vsftpd.sh && \
# 		mkdir -p /var/run/vsftpd/empty

WORKDIR /data
ENV XDG_CONFIG_HOME=/config
