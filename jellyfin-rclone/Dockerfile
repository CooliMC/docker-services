FROM linuxserver/jellyfin:latest

LABEL maintainer="CooliMC"

ARG RCLONE_VERSION="v1.53.3"
ARG OVERLAY_VERSION="v1.22.1.0"
ARG OVERLAY_ARCH="amd64"

ENV DEBUG="false" \
    GOPATH="/go" \
    GO111MODULE="on" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName="rclone.conf" \
    MountCommands="--allow-other --allow-non-empty"

## Ubuntu with Go Git
RUN echo "Download and install packages" \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
#        rclone \
        golang \
        git \
        gnupg \
    && echo "Download and compile rclone" \
    && go get -v github.com/rclone/rclone@${RCLONE_VERSION} \
	&& echo "Show LS of /go/bin/rclone" \
	&& echo $(ls -1 /go/bin/rclone) \
    && cp /go/bin/rclone /usr/sbin/ \
	&& echo "Show LS of /usr/sbin/" \
	&& echo $(ls -1 /usr/sbin/) \
    && rm -rf /go || true \
    && apt-get purge -y golang git gnupg \
	&& apt-get autoremove -y \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*
	
COPY root/ /
