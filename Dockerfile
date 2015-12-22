# Latest Ubuntu LTS
FROM ubuntu:14.04

MAINTAINER  Erik Osterman "e@osterman.com"

ENV ETCD_HOST 172.17.42.1
ENV ETCD_PORT 4001
ENV CONFD_INTERVAL 60
ENV CONFD_VERSION 0.9.0
ENV CONFD_PREFIX /btsync
ENV CONFD_ONETIME false
ENV SUPERVISORD_ENABLED true

# Set Btsync environment variables (can be changed on docker run with -e)
ENV BTSYNC_STORAGE_PATH /btsync
ENV BTSYNC_SYNC_MAX_TIME_DIFF 20
ENV BTSYNC_MAX_FILE_SIZE_FOR_VERSIONING 1
ENV BTSYNC_FOLDER_RESCAN_INTERVAL 600
ENV BTSYNC_MAX_FILE_SIZE_DIFF_FOR_PATCHING 4
ENV BTSYNC_LOG /dev/stdout
ENV BTSYNC_CONF /etc/btsync/cluster.conf
ENV BTSYNC_SHARED_SECRET ABCDEFGHIKLMNOPQRSTUVWXYZ
ENV BTSYNC_SHARED_DIR /vol
ENV BTSYNC_USE_DHT false
ENV BTSYNC_USE_TRACKER false
ENV BTSYNC_SEARCH_LAN true
ENV BTSYNC_DISCOVERY ""
ENV BTSYNC_PORT 44444
ENV BTSYNC_KNOWN_HOSTS ""
ENV BTSYNC_USER btsync
ENV BTSYNC_GROUP btsync
ENV BTSYNC_UID 100
ENV BTSYNC_GID 100
ENV BTSYNC_DEBUG FFFFFFFF
ENV BTSYNC_VERSION 2.2.6

# debugging
# http://forum.bittorrent.com/topic/12658-if-you-have-sync-issue/

ADD https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64 /usr/bin/confd
ADD https://download-cdn.getsync.com/$BTSYNC_VERSION/linux-x64/BitTorrent-Sync_x64.tar.gz /usr/bin/btsync.tar.gz

# System 
ENV TIMEZONE Etc/UTC
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y locales m4 supervisor psmisc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    sed -i -r 's:^(serverurl):;\1:g' /etc/supervisor/supervisord.conf && \
    cd /usr/bin && tar -xzvf btsync.tar.gz && rm btsync.tar.gz && \
    chmod 755 /usr/bin/confd && \
    mkdir /empty

# Locale specific
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Configure timezone and locale
RUN locale-gen $LANGUAGE && \
      dpkg-reconfigure locales && \
      echo "$TIMEZONE" > /etc/timezone && \
      dpkg-reconfigure -f noninteractive tzdata && \
      mkdir -p /etc/btsync/ 

ADD start /start
ADD cluster.conf /etc/btsync/cluster.conf
ADD confd/ /etc/confd/
ADD supervisord.conf.m4 /etc/supervisor/conf.d/btsync.conf.m4

USER root
EXPOSE 44444
ENTRYPOINT ["/start"]

