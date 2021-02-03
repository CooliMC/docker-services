[rcloneurl]: https://rclone.org

[![rclone.org](https://rclone.org/img/rclone-120x120.png)][rcloneurl]

Modified fork of [Mumie-hub/rclone-mount](https://github.com/Mumie-hub/docker-services/tree/master/rclone-mount)
---

This is a modified fork of mumies rclone-mount docker image. Just swapped the mount for the webdav service.
Also thanks for all the work done by him including the s6 overlay and the basic rclone and alpine linux setup.

Rclone Webdav Container
---

Lightweight and simple Container Image (`alpine:latest - 160MB`) with compiled rclone (https://github.com/ncw/rclone master). Mount your cloudstorage like google drive inside a container and make it available via the integrated webdav server to other containers for like your Plex Server or on your hostsystem. You need a working rclone.conf (from another host or create it inside the container with entrypoint /bin/sh). all rclone remotes can be used.


The Container uses S6 Overlay, to handle docker stop/restart and also preparing the mountpoint.


# Usage Example:

    docker run -d --name rclone-webdav \
        --restart=unless-stopped \
        -e RemotePath="mediaefs:" \
        -e ReadOnly="true" \
        -e ExtendedCommands="--poll-interval 5m --buffer-size 256M" \
        -v /path/to/config:/config \
        coolimc/rclone-webdav

> needed volume mappings:

- -v /path/to/config:/config

> optional volume mappings:

- -v /path/to/cache:/rcache


# Environment Variables:

| Variable |  | Description |
|---|--------|----|
|`RemotePath`="mediaefs:path" | |remote name in your rclone config, can be your crypt remote: + path/foo/bar|
|`ConfigDir`="/config"| |#INSIDE Container: -v /path/to/config:/config|
|`ConfigName`="rclone.conf"| |#INSIDE Container: /config/rclone.conf|
|`CacheDir`="/rcache"| |#INSIDE Container: -v /path/to/cache:/rcache|
|`ReadOnly`="true"| |set the webdav network share to read-only mode|
|`WebdavAddr`="0.0.0.0"| |set the webdav network share address bind|
|`WebdavPort`="8080"| |set the webdav network share port bind|
|`ExtendedCommands`="--vfs-cache-mode off --no-checksum"| |default rclone commands, (if you not parse anything, defaults will be used)|


## Use your own RcloneCommands with:
To enable caching for the given RemotePath:
```vim
-e ExtendedCommands="--vfs-cache-mode full --dir-cache-time 48h --poll-interval 5m --buffer-size 256M"
```

To enable username/password authentication for the webdav server:
```vim
-e ExtendedCommands="--user USERNAME --pass PASSWORD"
```
```vim
-e ExtendedCommands="--htpasswd PASSWORD_FILE_PATH"
```

All Commands can be found at [https://rclone.org/commands/rclone_serve_webdav/](https://rclone.org/commands/rclone_serve_webdav/). Use `--buffer-size 256M` (dont go too high), when you encounter some "Direct Stream" problems on Plex Server for example.


Todo
----

* [ ] more settings
* [ ] Auto Update Function
* [ ] launch with specific USER_ID
