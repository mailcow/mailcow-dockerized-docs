### Restore
#### Variables for backup/restore script
##### Multithreading
With the 2022-10 update it is possible to run the script with multithreading support. This can be used for backups as well as for restores.

To start the backup/restore with multithreading you have to add `THREADS` as an environment variable in front of the command to execute the script.

```
THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore
```
The number after the `=` character indicates the number of threads. Please keep your core count -2 to leave enough CPU power for mailcow itself.

##### Backup path
The script will ask you for a backup location. Inside of this location it will create folders in the format "mailcow_DATE".
You should not rename those folders to not break the restore process.

To run a backup unattended, define MAILCOW_BACKUP_LOCATION as environment variable before starting the script:

```bash
MAILCOW_BACKUP_LOCATION=/opt/backup /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore
```

!!! tip
    Both variables mentioned above can also be combined! Ex:
    ```bash
    MAILCOW_BACKUP_LOCATION=/opt/backup THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore
    ```

#### Restoring Data

!!! danger
    **Please do not copy this script to another location.**

!!! warning
    To restore a backup on a new system, **mailcow must be initialized and running!** Therefore, reinstall mailcow according to the instructions and wait to proceed with the restoration until mailcow is up and running in an empty state.

!!! danger "Danger for older installations"
    Before restoring your mailcow system on a new server and a clean mailcow-dockerized folder, please check if the value `MAILDIR_SUB` is set in your mailcow.conf. If this value is not set, do not set it in your new mailcow or remove it, otherwise **NO** emails will be displayed. Dovecot loads emails from the mentioned subfolder of the Maildir volume under `$DOCKER_VOLUME_PATH/mailcowdockerized_vmail-vol-1` and if there is any change compared to the original state, no emails will be available there.

To run a restore, **start mailcow**, use the script with "restore" as first parameter.

```
# Syntax:
# ./helper-scripts/backup_and_restore.sh restore

```

The script will ask you for a backup location containing the mailcow_DATE folders:

``` { .bash .no-copy }
Backup location (absolute path, starting with /): /opt/backup
```

All available backups in the specified folder (in our example `/opt/backup`) are then displayed:

``` { .bash .no-copy }
Found project name mailcowdockerized
[ 1 ] - /opt/backup/mailcow-2023-12-11-13-27-14/
[ 2 ] - /opt/backup/mailcow-2023-12-11-14-02-06/
```

Now you can enter the number of your backup that you want to restore, in this example the 2nd backup:

``` { .bash .no-copy }
Select a restore point: 2
```

The script will now display all the backed up components that you can restore, in our case we have selected `all` for the backup process, so this will now appear here:

``` { .bash .no-copy }
[ 0 ] - all
[ 1 ] - Crypt data
[ 2 ] - Rspamd data
[ 3 ] - Mail directory (/var/vmail)
[ 4 ] - Redis DB
[ 5 ] - Postfix data
[ 6 ] - SQL DB
```

Again, we select the component that we want to restore. Option 0 restores **EVERYTHING**.

??? warning "If you want to restore to a different architecture..."
    If you have made the backup on a different architecture, e.g. x86, and now want to restore this backup to ARM64, the backup of Rspamd is displayed as incompatible and cannot be selected individually. When restoring with the 0 key, the restoration of Rspamd is also skipped.

    Example of incompatible Rspamd backup in the selection menu:

    ``` { .bash .no-copy } 
    [...]
    [ NaN ] - Rspamd data (incompatible Arch, cannot restore it)
    [...]
    ```

Now mailcow will restore the backups you have selected. Please note that the restoration may take some time, depending on the size of the backups.