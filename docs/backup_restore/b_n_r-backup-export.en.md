### Exporting Backups

#### Backup
It is strongly recommended to back up the mail server regularly to prevent data loss. Additionally, backups should be exported to avoid complete data loss.

General information on backups can be found in the chapter [Backup](b_n_r-backup.md).

This chapter explains the options for exporting backups.

#### Borgmatic Backup
Borgmatic is an excellent solution for performing backups on your mailcow setup. It provides secure encryption of your data and is very easy to set up.

Additionally, the functionality for exporting backups is already integrated.

Further information on backup and export with Borgmatic can be found in the chapter [Borgmatic Backup](../third_party/borgmatic/third_party-borgmatic.md).

#### Export via WebDAV, FTP/SFTP, NAS and S3 (V3)
The community extension [mailcow-backup](https://github.com/the1andoni/mailcow-backup) enables automated export and encryption of backups to external targets.

!!! warning "Note"
    This feature is developed by the community. The link points to an external GitHub repository.

**Version 3 Features:**
* **Targets:** Support for WebDAV, FTP/SFTP, NAS, and S3-compatible cloud storage.
* **Security:** Optional backup encryption and support for secure transfer protocols.
* **Automation:** Easy integration via cronjob using a modular script structure.

Setup and configuration details can be found in the [repository](https://github.com/the1andoni/mailcow-backup). The script is under active development with additional features being added regularly. It is generally recommended to use TLS-secured connections when exporting backups(SFTP).
