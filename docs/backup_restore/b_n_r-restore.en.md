### Restore
#### Variables for backup/restore script
##### Multithreading
To start the backup/restore with multithreading you have to add `--threads <num>` or short one `-t <num>` flag.

```
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -r /opt/backups -c all -t 14
```
!!! info
    The number after the `-t` character indicates the number of threads. Please keep your core count -2 to leave enough CPU power for mailcow itself.

##### Backup path
You should pass the path of the backup directory right after `-r`|`--restore` flag, It will search through the directory to find all backups,
and then it will prompt you to choose the backup you want to restore.

To run a restore unattended, define MAILCOW_RESTORE_LOCATION as environment variable before starting the script:

```bash
MAILCOW_RESTORE_LOCATION=/opt/backup /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all
```

!!! danger
    Please look closeley: The variable here is called `MAILCOW_RESTORE_LOCATION`

Or, pass `-r`|`--restore` with the restore path as argument to the script:

```bash
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -r /opt/backup -c all
```

!!! tip
    Both variables mentioned above can also be combined! Ex:
    ```bash
    MAILCOW_RESTORE_LOCATION=/opt/backup MAILCOW_BACKUP_RESTORE_THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all
    ```

!!! tip
    You should specify the component(s) you want to restore with `-c` or `--component`, or just `-c all`! Ex:
    ```bash
    MAILCOW_RESTORE_LOCATION=/opt/backup MAILCOW_BACKUP_RESTORE_THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c vmail -c crypt -c mysql
    ```

#### Restoring Data

!!! danger
    **Please do not copy this script to another location.**

!!! danger "Danger for older installations"
    Before restoring your mailcow system on a new server and a clean mailcow-dockerized folder, please check if the value `MAILDIR_SUB` is set in your mailcow.conf. If this value is not set, do not set it in your new mailcow or remove it, otherwise **NO** emails will be displayed. Dovecot loads emails from the mentioned subfolder of the Maildir volume under `$DOCKER_VOLUME_PATH/mailcowdockerized_vmail-vol-1` and if there is any change compared to the original state, no emails will be available there.

To run a restore, **start mailcow**, use the script with "--restore" or "-r" with path to backups directory:

```bash
# Syntax:
./helper-scripts/backup_and_restore.sh -r /opt/backup -c all
```

All available backups in the specified folder (in our example `/opt/backup`) are then displayed:

``` { .bash .no-copy }
Found project name mailcowdockerized
Using /opt/backup as restore location...
[ 1 ] - /opt/backup/mailcow-2023-12-11-13-27-14/
[ 2 ] - /opt/backup/mailcow-2023-12-11-14-02-06/
```

Now you can enter the number of your backup that you want to restore, in this example the 2nd backup:

``` { .bash .no-copy }
Select a restore point: 2
```

The script will now display all the backed up components that the script will restore them.
in our case we have selected `all` for the backup process, so this will now appear here:

``` { .bash .no-copy }
Matching available components to restore:
[ 1 ] - Crypt data
[ 2 ] - Rspamd data
[ 3 ] - Mail directory (/var/vmail)
[ 4 ] - Redis DB
[ 5 ] - Postfix data
[ 6 ] - SQL DB


Restoring will start in 5 seconds. Press Ctrl+C to stop.
```

Now, wait 5 seconds before the above components will be restored! If you want to abort
press `Ctrl+C` to stop the restore process.

??? warning "If you want to restore to a different architecture..."
    If you have made the backup on a different architecture, e.g. x86, and now want to restore this backup to ARM64, the backup of Rspamd is displayed as incompatible and cannot be selected individually. When restoring all components, the restoration of Rspamd is also skipped.

    Example of incompatible Rspamd backup in the selection menu:

    ``` { .bash .no-copy }
    [...]
    [ NaN ] - Rspamd data (incompatible Arch, cannot restore it)
    [...]
    ```

Now mailcow will restore the backups you have selected. Please note that the restoration may take some time, depending on the size of the backups.
