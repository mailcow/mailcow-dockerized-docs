### Restore

Please do not copy this script to another location.

To run a restore, **start mailcow**, use the script with "restore" as first parameter.

```
# Syntax:
# ./helper-scripts/backup_and_restore.sh restore

```

The script will ask you for a backup location containing the mailcow_DATE folders.

!!! danger
    When restoring from a backup of a different architecture to the new architecture, the Rspamd backup **MUST** be omitted from the restore, as it contains incompatible data that causes Rspamd to crash and mailcow to fail to start due to the architecture change.