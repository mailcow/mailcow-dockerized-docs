### Foreword

!!! danger "Warning"

    The syntax of the backup script has drastically changed with the 2024-09 update as part of the script's redevelopment. If automated backup processes are running on your system, please adjust them accordingly.

    Important to note is the relocation of the `--delete-days` parameter to the new and separately executable function `-d`.

    Also important: the new `--yes` variable, which is used for automation.

    Please refer to this documentation for the updated syntax.

### Manual

You can use the provided script `helper-scripts/backup_and_restore.sh` to backup mailcow automatically.

!!! danger
    **Please do not copy this script to another location.**

To run a backup, use flag "-b" or "--backup" along with "/path/to/backup/folder", also pass "-c" or "--component"
to select the component(s) which you want to backup.

```
# For syntax and usage help:
# ./helper-scripts/backup_and_restore.sh --help

# Backup all components to "/opt/backups" folder with no prompts (good for automation):
./helper-scripts/backup_and_restore.sh --backup /opt/backups --component all --yes

# Also, there's short version of the flags:
./helper-scripts/backup_and_restore.sh -b /opt/backups -c all

# Backup vmail, crypt and mysql data
./helper-scripts/backup_and_restore.sh -b /opt/backups -c vmail -c crypt -c mysql

# Backup vmail
./helper-scripts/backup_and_restore.sh -b /opt/backups -c vmail

```

#### Variables for backup/restore script
##### Multithreading
To start the backup/restore with multithreading you have to add `--threads <num>` or short one `-t <num>` flag.

```
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -b /opt/backups -c all -t 14
```
Please keep your core count -2 to leave enough CPU power for mailcow itself, such as if you have 16 cores, then pass `-t 14`.

##### Backup path
You should pass the backup path right after `-b`|`--backup` flag, Inside of this location it will create folders in the format "mailcow_DATE".
You should not rename those folders to not break the restore process.

To run a backup unattended, define MAILCOW_BACKUP_LOCATION as environment variable before starting the script:

```
MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all --yes
```

!!! danger
    Please look closeley: The variable here is called `MAILCOW_BACKUP_LOCATION`

!!! tip
    Both variables mentioned above can also be combined! Ex:

    ```bash
    MAILCOW_BACKUP_LOCATION=/opt/backups MAILCOW_BACKUP_RESTORE_THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all --yes
    ```

!!! tip
        Please note: If you specified `MAILCOW_BACKUP_LOCATION` environment variable then there's no need to pass the `-b`|`--backup` flag

#### Cronjob

You can run the backup script regularly via cronjob. Make sure `MAILCOW_BACKUP_LOCATION` exists:

```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --backup -c mysql -c crypt -c redis --yes
```

Per default cron sends the full result of each backup operation by email. If you want cron to only mail on error (non-zero exit code) you may want to use the following snippet. Pathes need to be modified according to your setup (this script is a user contribution).

This following script may be placed in `/etc/cron.daily/mailcow-backup` - do not forget to mark it as executable via `chmod +x`:

```
#!/bin/sh

# Backup mailcow Docs
# https://docs.mailcow.email/backup_restore/b_n_r-backup/

set -e

OUT="$(mktemp)"
export MAILCOW_BACKUP_LOCATION="/opt/backup"
export MAILCOW_BACKUP_RESTORE_THREADS="2"
SCRIPT="/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh"
PARAMETERS=(-c all)
OPTIONS=(--yes)

# run command
set +e
"${SCRIPT}" "${PARAMETERS[@]}" "${OPTIONS[@]}" 2>&1 > "$OUT"
RESULT=$?

if [ $RESULT -ne 0 ]; then
  echo "${SCRIPT} ${PARAMETERS[@]} ${OPTIONS[@]} encounters an error:"
  echo "RESULT=$RESULT"
  echo "STDOUT / STDERR:"
  cat "$OUT"
fi
```

# Backup strategy with rsync and mailcow backup script

Create the destination directory for mailcows helper script:
```
mkdir -p /external_share/backups/backup_script
```

Create cronjobs:
```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
25 1 * * * rsync -aH --delete /opt/mailcow-dockerized /external_share/backups/mailcow-dockerized
40 2 * * * rsync -aH --delete /var/lib/docker/volumes /external_share/backups/var_lib_docker_volumes
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/external_share/backups/backup_script /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c mysql -c crypt -c redis --yes
5 4 * * * cd /opt/mailcow-dockerized/; /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --delete /external_share/backups/backup_script 3 --yes
# If you want to, use the acl util to backup permissions of some/all folders/files: getfacl -Rn /path
```

On the destination (in this case `/external_share/backups`) you may want to have snapshot capabilities (ZFS, Btrfs etc.). Snapshot daily and keep for n days for a consistent backup.
Do **not** rsync to a Samba share, you need to keep the correct permissions!

To restore you'd simply need to run rsync the other way round and restart Docker to re-read the volumes. Run:

=== "docker compose (Plugin)"

    ``` bash
    docker compose pull
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose pull
    docker-compose up -d
    ```

If you are lucky Redis and MariaDB can automatically fix the inconsistent databases (if they _are_ inconsistent).
In case of a corrupted database you'd need to use the helper script to restore the inconsistent elements. If a restore fails, try to extract the backups and copy the files back manually. Keep the file permissions!
