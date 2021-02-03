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
	&& apt-get upgrade \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
		rclone \
#		golang \
#        git \
#	    gnupg \
#	 && echo "Download and compile rclone" \
#    && go get -v github.com/rclone/rclone@${RCLONE_VERSION} \
#    && cp /go/bin/rclone /usr/sbin/ \
#    && rm -rf /go || true \
    && apt-get purge golang git gnupg -y \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*
	
COPY root/ /
