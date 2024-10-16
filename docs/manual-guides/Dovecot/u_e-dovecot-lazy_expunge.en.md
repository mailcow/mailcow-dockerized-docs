!!! danger
    This guide is still a work in progress, and errors may occur! Use this feature with caution!

!!! info
    This feature is compatible with mailcow versions starting from 2024-10. Older versions are theoretically capable of using it as well, but due to internal changes, the implementation is more complicated, so it won't be stated here as unsupported.

## Introduction
Dovecot has supported a feature called *Lazy Expunge* for [quite some time](https://doc.dovecot.org/2.3/configuration_manual/lazy_expunge_plugin/), which allows server administrators to temporarily retain deleted emails from a user account even after they have been deleted.

mailcow also has a similar feature, but it is not easily accessible to users (see [Recover accidentally deleted data (Mail)](../../backup_restore/b_n_r-accidental_deletion.en.md#mail)) and serves more as a fallback method for administrators.

With the Dovecot option, users can view and restore emails that have been marked as deleted before they are automatically purged by the Dovecot server.

## Setup

1. Edit the `extra.conf` file in the Dovecot configuration folder (usually located at `MAILCOW_ROOT/data/conf/dovecot`) with the following content:
    ```bash
    plugin {
        # Copy all deleted emails to the .EXPUNGED mailbox
        lazy_expunge = .EXPUNGED

        # Exclude marked-as-deleted emails from the quota
        quota_rule = .EXPUNGED:ignore
    }

    # Define the .EXPUNGED mailbox
    namespace inbox {
        mailbox .EXPUNGED {
            # Define how long emails will stay in this folder before they are deleted. Time is defined according to: https://doc.dovecot.org/2.3/settings/types/#time
            autoexpunge = 7days
            # Define how many emails can be kept in the EXPUNGED folder before it is cleared
            autoexpunge_max_mails = 100000
        }
    }
    ```

2. Restart the Dovecot container:

    === "docker compose (Plugin)"

        ```bash
        docker compose restart dovecot-mailcow
        ```

    === "docker-compose (Standalone)"

        ```bash
        docker-compose restart dovecot-mailcow
        ```

3. Once the trash is emptied, a new folder named `.EXPUNGED` should appear. This folder will contain emails that, according to the rules defined in step 1, will be automatically deleted from the server after a certain period.