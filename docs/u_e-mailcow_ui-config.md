Several configuration parameters of the mailcow UI can be changed by creating a file `data/web/inc/vars.local.inc.php` which overrides defaults settings found in `data/web/inc/vars.inc.php`.

The local configuration file is persistent over updates of mailcow. Try not to change values inside `data/web/inc/vars.inc.php`, but use them as template for the local override.

mailcow UI configuration parameters can be to...

- ...change the default language[^1]
- ...change the default bootstrap theme
- ...set a password complexity regex
- ...add mailcow app buttons to the login screen
- ...set a pagination trigger
- ...set action after submitting forms (stay in form, return to previous page)

[^1]: To change SOGos default language, you will need to edit `data/conf/sogo/sogo.conf` and replace "English" by your preferred language.
