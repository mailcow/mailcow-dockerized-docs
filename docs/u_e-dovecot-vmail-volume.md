## The "new" way

**WARNING**: Newer Docker versions seem to complain about existing volumes. You can fix this temporarily by removing the existing volume and start mailcow with the override file. But it seems to be problematic after a reboot (needs to be confirmed).

An easy, dirty, yet stable workaround is to stop mailcow (`docker-compose down`), remove `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data` and create a new link to your remote filesystem location, for example:

```
mv /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data_backup
ln -s /mnt/volume-xy/vmail_data /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data
```

Start mailcow afterwards.

---

## The "old" way

If you want to use another folder for the vmail-volume, you can create a `docker-compose.override.yml` file and add the following content:

```
version: '2.1'
volumes:
  vmail-vol-1:
    driver_opts:
      type: none
      device: /data/mailcow/vmail	
      o: bind
```

### Moving an existing vmail folder:

- Locate the current vmail folder by its "Mountpoint" attribute: `docker volume inspect mailcowdockerized_vmail-vol-1`

``` hl_lines="10"
[
    {
        "CreatedAt": "2019-06-16T22:08:34+02:00",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "mailcowdockerized",
            "com.docker.compose.version": "1.23.2",
            "com.docker.compose.volume": "vmail-vol-1"
        },
        "Mountpoint": "/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data",
        "Name": "mailcowdockerized_vmail-vol-1",
        "Options": null,
        "Scope": "local"
    }
]
```

- Copy the content of the `Mountpoint` folder to the new location (e.g. `/data/mailcow/vmail`) using `cp -a`, `rsync -a` or a similar non strcuture breaking copy command
- Stop mailcow by executing `docker-compose down` from within your mailcow root folder (e.g. `/opt/mailcow-dockerized`)
- Create the file `docker-compose.override.yml`, edit the device path accordingly
- Delete the current vmail folder: `docker volume rm mailcowdockerized_vmail-vol-1`
- Start mailcow by executing `docker-compose up -d` from within your mailcow root folder (e.g. `/opt/mailcow-dockerized`)
