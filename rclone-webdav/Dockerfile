FROM alpine:latest

ARG RCLONE_VERSION="v1.53.3"
ARG OVERLAY_VERSION="v1.22.1.0"
ARG OVERLAY_ARCH="amd64"

ENV DEBUG="false" \
    GOPATH="/go" \
    GO111MODULE="on" \
    RemotePath="mediaefs:" \
    ConfigDir="/config" \
    ConfigName="rclone.conf" \
	ReadOnly="true" \
	WebdavAddr="0.0.0.0" \
	WebdavPort="8080" \
	CacheDir="/rcache" \
    ExtendedCommands="--vfs-cache-mode off --no-checksum"
	
## Alpine with Go Git
RUN apk --no-cache upgrade \
    && apk add --no-cache --update alpine-sdk ca-certificates go git fuse fuse-dev gnupg \
    && echo "Installing S6 Overlay" \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
    && curl https://keybase.io/justcontainers/key.asc | gpg --import \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xfz /tmp/s6-overlay.tar.gz -C / \
    && echo "Download and compile rclone" \
    && go get -v github.com/rclone/rclone@${RCLONE_VERSION} \
    && cp /go/bin/rclone /usr/sbin/ \
    && rm -rf /go || true \
    && apk del alpine-sdk go git gnupg \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

ENTRYPOINT ["/init"]

# Use this docker options for caching
# -e ExtendedCommands="--vfs-cache-mode minimal|writes|full"
# -v /path/to/cache:/rcache
