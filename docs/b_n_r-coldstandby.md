# Cold-standby backup

mailcow offers an easy way to create a consistent copy of itself to be rsync'ed to a remote location without downtime.

This may also be used to transfer your mailcow to a new server.

## You should know

The provided script will work on default installations.

It may break when you use unsupported volume overrides. We don't support that and we will not include hacks to support that. Please run and maintain a fork if you plan to keep your changes.

The script will use **the same pathes** as your default mailcow installation. That is the mailcow base directory - for most users `/opt/mailcow-dockerized` - as well as the mountpoints.

To find the pathes of your source volumes we use `docker inspect` and read the destination directory of every volume related to your mailcow compose project. This means we will also transfer volumes you may have added in a override file. Local bind mounts may or may not work.

The use rsync with the `--delete` flag. The destination will be an exact copy of the source.

`mariabackup` is used to create a consistent copy of the SQL data directory.

After rsync'ing the data we will run `docker-compose pull` and remove old image tags from the destination.

Your source will not be changed at any time.

**You may want to make sure to use the same `/etc/docker/daemon.json` on the remote target.**

You should not run disk snapshots (e.g. via ZFS, LVM etc.) on the target at the very same time as this script is run.

Versioning is not part of this script, we rely on the destination (snapshots or backups). You may also want to use any other tool for that.

## Prepare

You will need a SSH-enabled destination and a keyfile to connect to said destination. The key should not be protected by a password for the script to work unattended.

In your mailcow base directory, e.g. `/opt/mailcow-dockerized` you will find a file `create_cold_standby.sh`.

Edit this file and change the exported variables:

```
export REMOTE_SSH_KEY=/path/to/keyfile
export REMOTE_SSH_PORT=22
export REMOTE_SSH_HOST=mailcow-backup.host.name
```

The key must be owned and readable by root only.

Both the source and destination require `rsync` >= v3.1.0.
The destination must have Docker and docker-compose **v1** available.

The script will detect errors automatically and exit.

You may want to test the connection by running `ssh mailcow-backup.host.name -p22 -i/path/to/keyfile`.

## Backup and refresh the cold-standby

Run the first backup, this may take a while depending on the connection:

```
bash /opt/mailcow-dockerized/create_cold_standby.sh
```

That was easy, wasn't it?

Updating your cold-standby is just as easy:

```
bash /opt/mailcow-dockerized/create_cold_standby.sh
```

It's the same command.

