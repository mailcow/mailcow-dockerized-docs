# Cold-standby backup

mailcow offers an easy way to create a consistent copy of itself to be rsync'ed to a remote location without downtime.

This may also be used to transfer your mailcow to a new server.

## You should know

The provided script will work on default installations.

It may break when you use unsupported volume overrides. We don't support that and we will not include hacks to support that. Please run and maintain a fork if you plan to keep your changes.

The script will use **the same paths** as your default mailcow installation. That is the mailcow base directory - for most users `/opt/mailcow-dockerized` - as well as the mountpoints.

To find the paths of your source volumes we use `docker inspect` and read the destination directory of every volume related to your mailcow compose project. This means we will also transfer volumes you may have added in an override file. Local bind mounts may or may not work.

The script uses rsync with the `--delete` flag. The destination will be an exact copy of the source.

`mariabackup` is used to create a consistent copy of the SQL data directory.

After rsync'ing the data we will run the command below (depending on your set  docker compose type in mailcow.conf) and remove old image tags from the destination:

=== "docker compose (Plugin)"

    ``` bash
    docker compose pull
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose pull
    ```

Your source will not be changed at any time.

**You may want to make sure to use the same `/etc/docker/daemon.json` on the remote target.**

You should not run disk snapshots (e.g. via ZFS, LVM etc.) on the target at the very same time as this script is run.

Versioning is not part of this script, we rely on the destination (snapshots or backups). You may also want to use any other tool for that.

## Prepare

You will need an SSH-enabled destination and a keyfile to connect to said destination. The key should not be protected by a password for the script to work unattended.

In your mailcow base directory, e.g. `/opt/mailcow-dockerized` you will find a file `create_cold_standby.sh`.

Edit this file and change the exported variables:

```
export REMOTE_SSH_KEY=/path/to/keyfile
export REMOTE_SSH_PORT=22
export REMOTE_SSH_HOST=mailcow-backup.host.name
```

The key must be owned and readable by root only.

Both the source and destination require `rsync` >= v3.1.0.
The destination must have Docker and docker compose **v2** available.

The script will detect errors automatically and exit.

You may want to test the connection by running `ssh mailcow-backup.host.name -p22 -i /path/to/keyfile`.

??? warning "Important for switching to a different architecture"

    If you plan to use the Cold Standby script to migrate from x86 to ARM64 or vice versa, simply let the script run normally. The script will automatically recognize whether there are differences between the source and the target in terms of architecture and will behave accordingly and omit affected volumes from the sync.

    The reason for this is that Rspamd compiles regexp entries from our configurations to the corresponding platform and these cache files cannot be read when changing platforms. Rspamd would then crash and make it impossible to use mailcow in a meaningful way. We therefore omit the Rspamd volume when activating this variable.

    **Don't worry!** Rspamd will still work correctly after the migration as it generates these cache files automatically for the new platform.

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

## Automated backups with cron

First make sure that the `cron` service is enabled and running:

```
systemctl enable cron.service && systemctl start cron.service
```

To automate the backups to the cold-standby server you can use a cron job. To edit the cron jobs for the root user run:

```
crontab -e
```

Add the following lines to synchronize the cold standby server daily at 03:00. In this example errors of the last execution are logged into a file.

```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

0 3 * * * bash /opt/mailcow-dockerized/create_cold_standby.sh 2> /var/log/mailcow-coldstandby-sync.log
```

If saved correctly, the cron job should be shown by typing:

```
crontab -l
```