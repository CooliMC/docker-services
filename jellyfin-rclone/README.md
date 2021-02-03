# Jellyfin-Rclone - Jellyfin with an internal Rclone mount

This mod adds the rclone package for internal network/cloud storage mount to the Jellyfin Docker container.

## Merges Images

This mod merges the [linuxserver/docker-jellyfin](https://github.com/linuxserver/docker-jellyfin) and [mumie/rclone-mount](https://github.com/Mumie-hub/docker-services/tree/master/rclone-mount) docker images for internal network and cloud storage mount via the rclone application to the containers file system. The reason for this mod is to prevent the use of mounted host paths with complicated `bind/bind-propagation:shared` volumes to easily share the rclone mounted media libaries with the jellyfin server.

## Docker compose
The docker-compose file needs a `devices` entry for rclone fuse filesystem.
```
---
version: "3.5"
services:
  jellyfin_rclone:
    image: coolimc/jellyfin-rclone
    container_name: jellyfin_rclone
    ports:
      - 8096:8096
      - 8920:8920 #optional
      - 7359:7359/udp #optional
      - 1900:1900/udp #optional
    volumes:
      - /path/to/rclone_config:/rconfig
      - /path/to/jellyfin_config:/config
      - /path/to/tvseries:/data/tvshows #optional
      - /path/to/movies:/data/movies #optional
      - /opt/vc/lib:/opt/vc/lib #optional
    security_opt:
      - apparmor:unconfined
    cap_add:
      - SYS_ADMIN
    environment:
      - RemotePath=mediaefs:/
      - MountPoint=/mnt/mediaefs
      - ConfigDir=/rconfig
      - ConfigName=rclone.conf
      - MountCommands="--allow-other --allow-non-empty" #optional
      - PUID=1000
      - PGID=1000
      - TZ=Europe/London
      - UMASK_SET=<022> #optional
      - JELLYFIN_PublishedServerUrl=192.168.2.1 #optional
    devices:
      # FUSE Device
      - /dev/fuse
      # GPU Devices
      - /dev/dri:/dev/dri #optional
      - /dev/vcsm:/dev/vcsm #optional
      - /dev/vchiq:/dev/vchiq #optional
      - /dev/video10:/dev/video10 #optional
      - /dev/video11:/dev/video11 #optional
      - /dev/video12:/dev/video12 #optional
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
