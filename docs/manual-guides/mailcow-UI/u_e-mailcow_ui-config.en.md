Several configuration parameters of the mailcow UI can be changed by creating a file `data/web/inc/vars.local.inc.php` which overrides defaults settings found in `data/web/inc/vars.inc.php`.

The local configuration file is persistent over updates of mailcow. Try not to change values inside `data/web/inc/vars.inc.php`, but use them as template for the local override.

mailcow UI configuration parameters can be used to...

- ...change the default language[^1]
- ...change the default theme (see [Customize design](u_e-mailcow_ui-design.md#default-theme))
- ...set a password complexity regex
- ...enable DKIM private key visibility
- ...set a pagination trigger size
- ...set default mailbox attributes
- ...change session lifetimes
- ...create fixed app menus (which cannot be changed in mailcow UI)
- ...set a default "To" field for relayhost tests
- ...set a timeout for Docker API requests
- ...toggle IP anonymization
- ...change the limit for wrong 2FA codes (see [Two-Factor Authentication](u_e-mailcow_ui-tfa.md#failed-codes))
- ...define which imapsync options are allowed as custom parameters of sync jobs (see [Sync jobs](../../post_installation/firststeps-sync_jobs_migration.md#custom-parameters))

PHP-FPM caches the PHP files (OPcache) and does not re-read changed files. Restart PHP-FPM after changing `data/web/inc/vars.local.inc.php`:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart php-fpm-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart php-fpm-mailcow
    ```

[^1]: To change SOGos default language, you will need to edit `data/conf/sogo/sogo.conf` and replace "English" by your preferred language.