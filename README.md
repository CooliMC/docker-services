# Container services:

## Services that are based on alpine image to be lightweight
All services are build for a graceful shutdown/restart with S6 overlay or a small init script.
- [jellyfin-rclone](jellyfin-rclone)
- [rclone-webdav](rclone-webdav)

## Services that are modified to fit some special needs or usecases
- [scanservjs-epson-perfection](scanservjs-epson-perfection)
