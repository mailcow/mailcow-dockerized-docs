### Backup

You can use the provided script `helper-scripts/backup_and_restore.sh` to backup mailcow automatically.

Please do not copy this script to another location.

To run a backup, write "backup" as first parameter and either one or more components to backup as following parameters.
You can also use "all" as second parameter to backup all components.

```
# Syntax:
# ./helper-scripts/backup_and_restore.sh backup (vmail|crypt|redis|rspamd|postfix|mysql|all)

# Backup all
./helper-scripts/backup_and_restore.sh backup all

# Backup vmail, crypt and mysql data
./helper-scripts/backup_and_restore.sh backup vmail crypt mysql

```

The script will ask you for a backup location. Inside of this location it will create folders in the format "mailcow_DATE".
You should not rename those folders to not break the restore process.

To run a backup unattended, define MAILCOW_BACKUP_LOCATION as environment variable before starting the script:

```
MAILCOW_BACKUP_LOCATION=/opt/backup /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
```
