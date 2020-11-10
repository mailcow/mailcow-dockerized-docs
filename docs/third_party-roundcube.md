Download Roundcube 1.4.x to the web htdocs directory and extract it (here `rc/`):
```
# Check for a newer release!
cd data/web
wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.4.9/roundcubemail-1.4.9-complete.tar.gz | tar xfvz -
# Change folder name
mv roundcubemail-1.4.9 rc
# Change permissions
chown -R root: rc/
```

Create a file `data/web/rc/config/config.inc.php` with the following content.

**Change the `des_key` parameter to a random value.** It is used to temporarily store your IMAP password. The "db_prefix" is optional but recommended.

```
<?php
error_reporting(0);
if (!file_exists('/tmp/mime.types')) {
file_put_contents("/tmp/mime.types", fopen("http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types", 'r'));
}
$config = array();
$config['db_dsnw'] = 'mysql://' . getenv('DBUSER') . ':' . getenv('DBPASS') . '@mysql/' . getenv('DBNAME');
$config['default_host'] = 'tls://dovecot';
$config['default_port'] = '143';
$config['smtp_server'] = 'tls://postfix';
$config['smtp_port'] = 587;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['support_url'] = '';
$config['product_name'] = 'Roundcube Webmail';
$config['des_key'] = 'yourrandomstring_changeme';
$config['log_dir'] = '/dev/null';
$config['temp_dir'] = '/tmp';
$config['plugins'] = array(
  'archive',
  'managesieve'
);
$config['mime_types'] = '/tmp/mime.types';
$config['imap_conn_options'] = array(
  'ssl' => array('verify_peer' => false, 'verify_peer_name' => false, 'allow_self_signed' => true)
);
$config['enable_installer'] = true;
$config['smtp_conn_options'] = array(
  'ssl' => array('verify_peer' => false, 'verify_peer_name' => false, 'allow_self_signed' => true)
);
$config['db_prefix'] = 'mailcow_rc1';
```

Point your browser to `https://myserver/rc/installer` and follow the instructions.
Initialize the database and leave the installer.

**Delete the directory `data/web/rc/installer` after a successful installation!**

### Configure ManageSieve filtering

Open `data/web/rc/plugins/managesieve/config.inc.php` and change the following parameters (or add them at the bottom of that file):
```
$config['managesieve_port'] = 4190;
$config['managesieve_host'] = 'tls://dovecot';
$config['managesieve_conn_options'] = array(
  'ssl' => array('verify_peer' => false, 'verify_peer_name' => false, 'allow_self_signed' => true)
);
// Enables separate management interface for vacation responses (out-of-office)
// 0 - no separate section (default),
// 1 - add Vacation section,
// 2 - add Vacation section, but hide Filters section
$config['managesieve_vacation'] = 1;
```

### Enable change password function in Roundcube

Open `data/web/rc/config/config.inc.php` and enable the password plugin:

```
...
$config['plugins'] = array(
    'archive',
    'password',
);
...
```

Open `data/web/rc/plugins/password/password.php`, search for `case 'ssha':` and add above:

```
        case 'ssha256':
            $salt = rcube_utils::random_bytes(8);
            $crypted = base64_encode( hash('sha256', $password . $salt, TRUE ) . $salt );
            $prefix  = '{SSHA256}';
            break;
```

Open `data/web/rc/plugins/password/config.inc.php` and change the following parameters (or add them at the bottom of that file):

```
$config['password_driver'] = 'sql';
$config['password_algorithm'] = 'ssha256';
$config['password_algorithm_prefix'] = '{SSHA256}';
$config['password_query'] = "UPDATE mailbox SET password = %P WHERE username = %u";
```

### Integrate CardDAV addressbooks in Roundcube

Download the latest release of [RCMCardDAV](https://github.com/blind-coder/rcmcarddav/) to the Roundcube plugin directory and extract it (here `rc/plugins`):
```
cd data/web/rc/plugins
wget -O - https://github.com/blind-coder/rcmcarddav/releases/download/v3.0.3/carddav-3.0.3.tar.bz2 | tar xfvj -
chown -R root: carddav/
```
  
Copy the file `config.inc.php.dist` to `config.inc.php` (here in `rc/plugins/carddav`) and append the following preset to the end of the file - don't forget to replace `mx.example.org` with your own hostname:
```
$prefs['SOGo'] = array(
    'name'         =>  'SOGo',
    'username'     =>  '%u',
    'password'     =>  '%p',
    'url'          =>  'https://mx.example.org/SOGo/dav/%u/',
    'carddav_name_only' => true,
    'use_categories' => true,
    'active'       =>  true,
    'readonly'     =>  false,
    'refresh_time' => '02:00:00',
    'fixed'        =>  array( 'active', 'name', 'username', 'password', 'refresh_time' ),
    'hide'        =>  false,
);
```
Please note, that this preset only integrates the default addressbook (the one that's named "Personal Address Book" and can't be deleted). Additional addressbooks are currently not automatically detected but can be manually added within the roundecube settings.

Enable the plugin by adding `carddav` to `$config['plugins']` in `rc/config/config.inc.php`.

If you want to remove the default addressbooks (stored in the Roundcube database), so that only the CardDAV addressbooks are accessible, append `$config['address_book_type'] = '';` to the config file `data/web/rc/config/config.inc.php`.

---

Optionally, you can add Roundcube's link to the mailcow Apps list.
To do this, open or create `data/web/inc/vars.local.inc.php` and add the following code-block:

*NOTE: Don't forget to add the `<?php` delimiter on the first line*

````
...
$MAILCOW_APPS = array(
  array(
    'name' => 'SOGo',
    'link' => '/SOGo/'
  ),
  array(
    'name' => 'Roundcube',
    'link' => '/rc/'
   )
);
...
````

### Let admins log into Roundcube without password

First, install plugin [dovecot_impersonate](https://github.com/corbosman/dovecot_impersonate/) and add Roundcube as an app (see above).

Edit `mailcow.conf` and add the following:

```
# Allow admins to log into Roundcube as email user (without any password)
# Roundcube with plugin dovecot_impersonate must be installed first

ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=y
```

Edit `docker-compose.override.yml` and crate/extend the section for `php-fpm-mailcow`:

```yml
version: '2.1'
services:
  postfix-mailcow:
    environment:
      - ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=${ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE:-n}
```


Edit `data/web/js/site/mailbox.js` and the following code after [`if (ALLOW_ADMIN_EMAIL_LOGIN) { ... }`](https://github.com/mailcow/mailcow-dockerized/pull/3849/commits/1c873a83b5e6b1714512b2dc79ff81b26af3ef79#diff-aac7eb6ff52acc8698ff9bcc71c313cbc5bbbe501c3eb1b8bc658ef97fb9d4c1)

```php
if (ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE) {
	item.action += '<a href="/rc-auth.php?login=' + encodeURIComponent(item.username) + '" class="login_as btn btn-xs btn-primary" target="_blank"><span class="glyphicon glyphicon-envelope"></span> Roundcube</a>';
}
```

Edit `data/web/mailbox.php` and add this code to the bottom of the [javascript section](https://github.com/mailcow/mailcow-dockerized/pull/3849/commits/1c873a83b5e6b1714512b2dc79ff81b26af3ef79#diff-312fb7af69e284eca2fd573cdf2e4c3d04b6cd93fc5eb0e4dcdc6c199afd0aba):

```php
<script type='text/javascript'>
<?php
// ...
$ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE = (preg_match(
  "/^(yes|y)+$/i",
  $_ENV["ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE"]
)) ? "true" : "false";
echo "var ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE = " . $ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE . ";\n";
?>
</script>
```

Copy the contents of the following files from this [Snippet](https://gitlab.com/-/snippets/2038244):

* `data/web/inc/lib/RoundcubeAutoLogin.php`
* `data/web/rc-auth.php`

Finally, restart mailcow

```
docker-compose down
docker-compose up -d
```
