# Delete Old Backups

Since the new backup script (introduced in mailcow version 2024-09), it is now possible to delete old backups separately (even without running a backup job).

To do this, use the new `--delete` parameter or the short form `-d` along with the number of days to keep.

Examples:

```bash
# Deletes old backups (older than 3 days) from the path /opt/backups:
./helper-scripts/backup_and_restore.sh --delete /opt/backups 3

# Deletes old backups (older than 30 days) from the path /opt/backups
# without any further input from the user (ideal for automation):
./helper-scripts/backup_and_restore.sh --delete /opt/backups 30 --yes
```

#### Variables for the Backup/Restore Script
##### Backup Path

To delete older backups unattended, define the environment variable `MAILCOW_BACKUP_LOCATION` before starting the script:

```bash
MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --delete 30 --yes
```

!!! danger
    Please look closeley: The variable here is called `MAILCOW_BACKUP_LOCATION`

#### Cronjob

You can schedule the backup script to delete old backups regularly using a cron job. Make sure that `MAILCOW_BACKUP_LOCATION` exists:

```bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --delete 3 --yes
```

By default, cron sends the complete output of every deletion operation via email. If you only want cron to send an email in case of an error (exit code not equal to zero), you can use the following snippet. The paths must be adjusted according to your setup (this script is a user contribution).

The following script can be placed in `/etc/cron.daily/mailcow-backup-delete` - don't forget to mark it as executable with `chmod +x`:

```bash
#!/bin/sh

# Backup Delete mailcow Docs
# https://docs.mailcow.email/backup_restore/b_n_r-delete/

set -e

OUT="$(mktemp)"
export MAILCOW_BACKUP_LOCATION="/opt/backup"
SCRIPT="/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh"
PARAMETERS=(--delete 30)
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
