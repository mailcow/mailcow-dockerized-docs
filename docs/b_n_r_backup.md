### Backup

#### Manual

You can use the provided script `helper-scripts/backup_and_restore.sh` to backup mailcow automatically.

Please do not copy this script to another location.

To run a backup, write "backup" as first parameter and either one or more components to backup as following parameters.
You can also use "all" as second parameter to backup all components. Append `--delete-days n` to delete backups older than n days.

```
# Syntax:
# ./helper-scripts/backup_and_restore.sh backup (vmail|crypt|redis|rspamd|postfix|mysql|all|--delete-days)

# Backup all, delete backups older than 3 days
./helper-scripts/backup_and_restore.sh backup all --delete-days 3

# Backup vmail, crypt and mysql data, delete backups older than 30 days
./helper-scripts/backup_and_restore.sh backup vmail crypt mysql --delete-days 30

# Backup vmail
./helper-scripts/backup_and_restore.sh backup vmail

```

The script will ask you for a backup location. Inside of this location it will create folders in the format "mailcow_DATE".
You should not rename those folders to not break the restore process.

To run a backup unattended, define MAILCOW_BACKUP_LOCATION as environment variable before starting the script:

```
MAILCOW_BACKUP_LOCATION=/opt/backup /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
```

#### Cronjob

You can run the backup script regularly via cronjob. Make sure `BACKUP_LOCATION` exists:

```
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/mnt/mailcow_backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup mysql crypt redis --delete-days 3
```

Per default cron sends the full result of each backup operation by email. If you want cron to only mail on error (non-zero exit code) you may want to use the following snippet. Pathes need to be modified according to your setup (this script is a user contribution).

This following script may be placed in `/etc/cron.daily/mailcow-backup` - do not forget to mark it as executable via `chmod +x`:

```
#!/bin/sh

# Backup mailcow data
# https://mailcow.github.io/mailcow-dockerized-docs/b_n_r_backup/

set -e

OUT="$(mktemp)"
export MAILCOW_BACKUP_LOCATION="/opt/backup"
SCRIPT="/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh"
PARAMETERS="backup all"
OPTIONS="--delete-days 30"

# run command
set +e
"${SCRIPT}" ${PARAMETERS} ${OPTIONS} 2>&1 > "$OUT"
RESULT=$?

if [ $RESULT -ne 0 ]
    then
            echo "${SCRIPT} ${PARAMETERS} ${OPTIONS} encounters an error:"
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
25 1 * * * rsync -aH --delete /opt/mailcow-dockerized /external_share/backups/mailcow-dockerized
40 2 * * * rsync -aH --delete /var/lib/docker/volumes /external_share/backups/var_lib_docker_volumes
5 4 * * * cd /opt/mailcow-dockerized/; BACKUP_LOCATION=/external_share/backups/backup_script /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup mysql crypt redis --delete-days 3
# If you want to, use the acl util to backup permissions of some/all folders/files: getfacl -Rn /path
```

On the destination (in this case `/external_share/backups`) you may want to have snapshot capabilities (ZFS, Btrfs etc.). Snapshot daily and keep for n days for a consistent backup.
Do **not** rsync to a Samba share, you need to keep the correct permissions!

To restore you'd simply need to run rsync the other way round and restart Docker to re-read the volumes. Run `docker-compose pull` and `docker-compose up -d`.

If you are lucky Redis and MariaDB can automatically fix the inconsistent databases (if they _are_ inconsistent).
In case of a corrupted database you'd need to use the helper script to restore the inconsistent elements. If a restore fails, try to extract the backups and copy the files back manually. Keep the file permissions!
