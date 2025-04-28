### Exporting Backups

#### Backup
It is strongly recommended to back up the mail server regularly to prevent data loss. Additionally, backups should be exported to avoid complete data loss.

General information on backups can be found in the chapter [Backup](https://docs.mailcow.email/en/backup_restore/b_n_r-backup/).

This chapter explains the options for exporting backups.

#### Borgmatic Backup
Borgmatic is an excellent solution for performing backups on your Mailcow setup. It provides secure encryption of your data and is very easy to set up.

Additionally, the functionality for exporting backups is already integrated.

Further information on backup and export with Borgmatic can be found in the chapter [Borgmatic Backup](https://docs.mailcow.email/en/third_party/borgmatic/third_party-borgmatic/).

#### Export via WebDAV / sFTP
Backups can also be exported via FTP or Nextcloud using the backup script [mailcow-backup.sh](https://github.com/the1andoni/mailcow-backupV2).

The script collects all necessary data using Mailcow's built-in backup functionality and packages it into a compressed directory.

For setting up backups, it is recommended to consult the documentation of the respective repository.

The script is actively developed and enhanced with additional features. It is generally recommended to export backups over FTP using TLS certificates.
