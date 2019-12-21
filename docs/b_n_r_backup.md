### Backup

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
