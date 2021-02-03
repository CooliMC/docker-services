# Jellyfin-Rclone - Docker mode for Jellyfin with an internal rclone mount

This mod adds the rclone package for internal network/cloud storage mount to the Jellyfin Docker container.

## Merges Images

This mode merges the [linuxserver/docker-jellyfin](https://github.com/linuxserver/docker-jellyfin) and [mumie/rclone-mount](https://github.com/Mumie-hub/docker-services/tree/master/rclone-mount) docker images for internal network and cloud storage mount via the rclone application to the containers file system. The reason for this mod is to prevent the use of mounted host paths with complicated `bind/bind-propagation:shared` volumes to share the rclone mounted media libaries with the jellyfin server.

## Docker compose
The docker-compose file needs a `devices` entry for jellyfin ([Official Documentation](https://jellyfin.org/docs/general/administration/hardware-acceleration.html))
```
---
version: "2.1"
services:
  jellyfin:
    image: linuxserver/jellyfin
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - UMASK_SET=<022> #optional
    volumes:
      - /path/to/library:/config
      - /path/to/tvseries:/data/tvshows
      - /path/to/movies:/data/movies
      - /opt/vc/lib:/opt/vc/lib #optional
    ports:
      - 8096:8096
      - 8920:8920 #optional
      - 7359:7359/udp #optional
      - 1900:1900/udp #optional
    devices:
      # VAAPI Devices
      - "/dev/dri/renderD128:/dev/dri/renderD128"
      - "/dev/dri/card0:/dev/dri/card0"
    restart: unless-stopped
```

## Docker cli
```
docker run -d \
  --name=jellyfin \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e UMASK_SET=<022> `#optional` \
  -p 8096:8096 \
  -p 8920:8920 `#optional` \
  -p 7359:7359/udp `#optional` \
  -p 1900:1900/udp `#optional` \
  -v /path/to/library:/config \
  -v /path/to/tvseries:/data/tvshows \
  -v /path/to/movies:/data/movies \
  -v /opt/vc/lib:/opt/vc/lib `#optional` \
  --device /dev/dri/renderD128:/dev/dri/renderD128 \
  --device /dev/dri/card0:/dev/dri/card0 \
  --restart unless-stopped \
  linuxserver/jellyfin
```

## Settings in Jellyfin
Under server administration in `Server > Playback` the `Hardware acceleration` can be set to `Video Acceleration API (VAAPI)` and the `VA API Device` has to be set to the device given in the Docker configuration. For example `/dev/dri/renderD128`.

## Building the image
```
docker build --no-cache -t pascalminder/jellyfin-amd .
```

```
docker tag pascalminder/jellyfin-amd pascalminder/jellyfin-amd:latest
```

```
docker push pascalminder/jellyfin-amd:latest
```
