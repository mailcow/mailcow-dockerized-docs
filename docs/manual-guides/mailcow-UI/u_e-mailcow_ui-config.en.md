Several configuration parameters of the mailcow UI can be changed by creating a file `data/web/inc/vars.local.inc.php` which overrides defaults settings found in `data/web/inc/vars.inc.php`.

The local configuration file is persistent over updates of mailcow. Try not to change values inside `data/web/inc/vars.inc.php`, but use them as template for the local override.

mailcow UI configuration parameters can be used to...

- ...change the default language[^1]
- ...change the default bootstrap theme
- ...set a password complexity regex
- ...enable DKIM private key visibility
- ...set a pagination trigger size
- ...set default mailbox attributes
- ...change session lifetimes
- ...create fixed app menus (which cannot be changed in mailcow UI)
- ...set a default "To" field for relayhost tests
- ...set a timeout for Docker API requests
- ...toggle IP anonymization

[^1]: To change SOGos default language, you will need to edit `data/conf/sogo/sogo.conf` and replace "English" by your preferred language.