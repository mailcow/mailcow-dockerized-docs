## Installing Roundcube

Unless otherwise stated, all of the given commands are expected to be executed in the mailcow installation directory,
i.e., the directory containing `mailcow.conf` etc. Please do not blindly execute the commands but understand what they
do. None of the commands is supposed to produce an error, so if you encounter an error, fix it if necessary before
continuing with the subsequent commands.

### Note on composer usage

This guide uses composer to update roundcube dependencies or install / update roundcube plugins.

The roundcube-plugin-installer composer plugin has a [design issue](https://github.com/roundcube/plugin-installer/issues/38)
that can lead to composer errors when packages are upgraded or uninstalled in the composer execution.

The error message will typically tell you that a `require` in `autoload_real.php` failed because a file could not be
opened. Example:

```
In autoload_real.php line 43:
  require(/web/rc/vendor/composer/../guzzlehttp/promises/src/functions_include.php): Failed to open stream: No such file or directory
```

Unfortunately these occur quite frequently, but they can be worked around by updating the autoloader and re-running the
failed command:

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer dump-autoload -o
# Now execute the command that failed again
```

### Preparation
First we load `mailcow.conf` so we have access to the mailcow configuration settings for the following commands.

```bash
source mailcow.conf
```

Download Roundcube 1.6.x (check for latest release and adapt URL) to the web directory and extract it (here `rc/`):

```bash
mkdir -m 755 data/web/rc
wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.2/roundcubemail-1.6.2-complete.tar.gz | tar -xvz --no-same-owner -C data/web/rc --strip-components=1 -f -
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown www-data:www-data /web/rc/logs /web/rc/temp
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chmod 750 /web/rc/logs /web/rc/temp /web/rc/config
```

### Optional: Spellchecking
If you need spell check features, create a file `data/hooks/phpfpm/aspell.sh` with the following content, then
`chmod +x data/hooks/phpfpm/aspell.sh`. This installs a local spell check engine. Note, most modern web browsers have
built in spell check, so you may not want/need this.

```bash
#!/bin/bash
apk update
apk add aspell-en # or any other language
```

### Install mime type mappings
Download the `mime.types` file as it is not included in the php-fpm container.

```bash
wget -O data/web/rc/config/mime.types http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
```

### Create roundcube database
Create a database for roundcube in the mailcow MySQL container. This creates a new `roundcube` database user
with a random password, which will be echoed to the shell and stored in a shell variable for use by later
commands. Note that when you interrupt the process and continue in a new shell, you must set the `DBROUNDCUBE`
shell variable manually to the password output by the following commands.

```bash
DBROUNDCUBE=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
echo Database password for user roundcube is $DBROUNDCUBE
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE roundcubemail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'roundcube'@'%' IDENTIFIED BY '${DBROUNDCUBE}';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'%';"
```

### Roundcube configuration
Create a file `data/web/rc/config/config.inc.php` with the following content.
  - The `des_key` option is set to a random value. It is used to temporarily store your IMAP password.
  - The plugins list can be adapted to your preference. I added a set of standard plugins that I consider of common
    usefulness and which work well together with mailcow:
    - The archive plugin adds an archive button that moves selected messages to a user-configurable archive folder.
    - The managesieve plugin provides a user-friendly interface to manage server-side mail filtering and vacation / out
      of office notification.
    - The acl plugin allows to manage access control lists on IMAP folders, including the ability to share IMAP folders
      to other users.
    - The markasjunk plugin adds buttons to mark selected messages as junk (or messages in the junk folder not as junk)
      and moves them to the junk folder or back to the inbox. The sieve filters included with mailcow will take care
      that action triggers a learn as spam/ham action in rspamd, so no further configuration of the plugin is needed.
    - The zipdownload plugin allows to download multiple message attachments or messages as a zip file.
  - If you didn't install spell check in the above step, remove `spellcheck_engine` parameter.

```bash
cat <<EOCONFIG >data/web/rc/config/config.inc.php
<?php
\$config['db_dsnw'] = 'mysql://roundcube:${DBROUNDCUBE}@mysql/roundcubemail';
\$config['imap_host'] = 'dovecot:143';
\$config['smtp_host'] = 'postfix:588';
\$config['smtp_user'] = '%u';
\$config['smtp_pass'] = '%p';
\$config['support_url'] = '';
\$config['product_name'] = 'Roundcube Webmail';
\$config['cipher_method'] = 'chacha20-poly1305';
\$config['des_key'] = '$(LC_ALL=C </dev/urandom tr -dc "A-Za-z0-9 !#$%&()*+,-./:;<=>?@[\\]^_{|}~" 2> /dev/null | head -c 32)';
\$config['plugins'] = [
  'archive',
  'managesieve',
  'acl',
  'markasjunk',
  'zipdownload',
];
\$config['spellcheck_engine'] = 'aspell';
\$config['mime_types'] = '/web/rc/config/mime.types';
\$config['enable_installer'] = true;

\$config['managesieve_host'] = 'dovecot:4190';
// Enables separate management interface for vacation responses (out-of-office)
// 0 - no separate section (default); 1 - add Vacation section; 2 - add Vacation section, but hide Filters section
\$config['managesieve_vacation'] = 1;
EOCONFIG

docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config/config.inc.php
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chmod 640 /web/rc/config/config.inc.php
```

### Initialize database
Point your browser to `https://myserver/rc/installer`. Check that the website shows no "NOT OK" check results on
any of the steps, some "NOT AVAILABLE" are expected regarding different database extensions of which we only need MySQL.
Initialize the database and leave the installer. It is not necessary to update the configuration with
the downloaded one, unless you made some settings in the installer you would like to take over.

### Webserver configuration

The roundcube directory includes some locations that we do not want to serve to web users. We add a configuration
extension to nginx to only expose the public directory of roundcube.

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location /rc/ {
  alias /web/rc/public_html/;
}
EOCONFIG
```

### Disable and remove installer

Delete the directory `data/web/rc/installer` after a successful installation, and set the `enable_installer` option
to false in `data/web/rc/config/config.inc.php`:

```bash
rm -r data/web/rc/installer
sed -i -e "s/\(\$config\['enable_installer'\].* = \)true/\1false/" data/web/rc/config/config.inc.php
```

### Update roundcube dependencies

This step is not strictly necessary, but at least at the time of this writing the dependencies shipped with roundcube
included versions with security vulnerabilities, so it may be a good idea to update the dependencies to the latest
versions. For the same reason, it may be a good idea to run the composer update once in a while.

```bash
cp -n data/web/rc/composer.json-dist data/web/rc/composer.json
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer update --no-dev -o
```

You can also use `composer audit` to check for any reported security issues with the installed set of composer packages:

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer audit
```

### Allow plaintext authentication for the php-fpm container without using TLS

We need to allow plaintext authentication in dovecot over unencrypted connection (inside the container network), which
is per default mailcow installation only possible for the SOGo container for the very same purpose. Afterwards restart
the dovecot container so the change becomes effective.

```bash
cat  <<EOCONFIG >>data/conf/dovecot/extra.conf
remote ${IPV4_NETWORK}.0/24 {
  disable_plaintext_auth = no
}
remote ${IPV6_NETWORK} {
  disable_plaintext_auth = no
}
EOCONFIG

docker compose restart dovecot-mailcow
```

### Ofelia job for roundcube housekeeping

Roundcube needs to clean some stale information from the database every once in a while,
for which we will create an ofelia job that runs the roundcube `cleandb.sh` script.

To do this, add the following to `docker-compose.override.yml` (if you already have some
adaptations for the php-fpm container, add the labels to the existing section):

```yml
version: '2.1'
services:
  php-fpm-mailcow:
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.roundcube_cleandb.schedule: "@every 168h"
      ofelia.job-exec.roundcube_cleandb.user: "www-data"
      ofelia.job-exec.roundcube_cleandb.command: "/bin/bash -c \"[ -f /web/rc/bin/cleandb.sh ] && /web/rc/bin/cleandb.sh\""
```

## Optional extra functionality

### Enable change password function in Roundcube

Changing the mailcow password from the roundcube UI is supported via the password plugin. We will configure it to use
the mailcow API to update the password, which requires to enable the API first and to get the API key (read/write API
access required). The API can be enabled in the mailcow admin interface, where you can also find the API key.

Open `data/web/rc/config/config.inc.php` and enable the password plugin by adding it to the `$config['plugins']` array,
for example:

```php
$config['plugins'] = array(
  'archive',
  'managesieve',
  'acl',
  'markasjunk',
  'zipdownload',
  'password',
);
```

Configure the password plugin (be sure to adapt __\*\*API_KEY\*\*__ to you mailcow read/write API key):

```bash
cat <<EOCONFIG >data/web/rc/plugins/password/config.inc.php
<?php
\$config['password_driver'] = 'mailcow';
\$config['password_confirm_current'] = true;
\$config['password_mailcow_api_host'] = 'http://nginx';
\$config['password_mailcow_api_token'] = '**API_KEY**';
EOCONFIG
```

Note: If you have changed the mailcow nginx configuration to redirect http requests to https
(e.g., as described [here](https://docs.mailcow.email/manual-guides/u_e-80_to_443/)), then
directly talking to the nginx container via http will not work because nginx is not a hostname contained
in the certificate. In such cases, set `password_mailcow_api_host` in the above configuration to the
public URI instead:

```bash
cat <<EOCONFIG >data/web/rc/plugins/password/config.inc.php
<?php
\$config['password_driver'] = 'mailcow';
\$config['password_confirm_current'] = true;
\$config['password_mailcow_api_host'] = 'https://${MAILCOW_HOSTNAME}';
\$config['password_mailcow_api_token'] = '**API_KEY**';
EOCONFIG
```

### Integrate CardDAV addressbooks in Roundcube

Install the latest v5 version (the config below is compatible with v5 releases) using composer.
Answer `Y` when asked if you want to activate the plugin.

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer require --update-no-dev -o "roundcube/carddav:~5"
```

Edit the file `data/web/rc/plugins/carddav/config.inc.php` and insert the following content:

```bash
cat <<EOCONFIG >data/web/rc/plugins/carddav/config.inc.php
<?php
\$prefs['_GLOBAL']['pwstore_scheme'] = 'des_key';

\$prefs['SOGo'] = [
    'accountname'    => 'SOGo',
    'username'       => '%u',
    'password'       => '%p',
    'discovery_url'  => 'http://sogo:20000/SOGo/dav/',
    'name'           => '%N',
    'use_categories' => true,
    'fixed'          => ['username', 'password'],
];
EOCONFIG
```

RCMCardDAV will add all addressbooks of the user on login, including __subscribed__ addressbooks shared to the user by
other users.

If you want to remove the default addressbooks (stored in the Roundcube database), so that only the CardDAV addressbooks
are accessible, append `$config['address_book_type'] = '';` to the config file `data/web/rc/config/config.inc.php`.

Note: RCMCardDAV uses additional database tables. After installing (or upgrading) RCMCardDAV, it is required to log
in roundcube (log out first if already logged in) because the database table creation / changes are performed only
during the login to roundcube.

### Forward the client network address to dovecot

Normally, the IMAP server dovecot will see the network address of the php-fpm container when roundcube interacts with the IMAP
server. Using an IMAP extension and the `roundcube-dovecot_client_ip` roundcube plugin, it is possible for roundcube to tell
dovecot the client IP, so it will also show up in the logs as the remote IP. When doing this, login attempts will show in the
dovecot logs like any direct client connections to dovecot, and such failed logins into roundcube will be treated in the same
manner as failed direct IMAP logins, causing blocking of the client with the netfilter container or other mechanisms that may
already be in place to handle bruteforce attacks on the IMAP server.

For this, the roundcube plugin must be installed.

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer require --update-no-dev -o "takerukoushirou/roundcube-dovecot_client_ip:~1"
```

Furthermore, we must configure dovecot to treat the php-fpm container as part of a trusted network so it is allowed to override
the client IP in the IMAP session. Note that this also enables plaintext authentication for the listed network ranges, so the
explicit overridings of `disable_plaintext_auth` done above are not necessary when using this.

```bash
cat  <<EOCONFIG >>data/conf/dovecot/extra.conf
login_trusted_networks = ${IPV4_NETWORK}.0/24 ${IPV6_NETWORK}
EOCONFIG

docker compose restart dovecot-mailcow
```

### Add roundcube link to mailcow Apps list

You can add Roundcube's link to the mailcow Apps list.
To do this, open or create `data/web/inc/vars.local.inc.php` and make sure it includes the following configuration
block:

```php
<?php

$MAILCOW_APPS = [
    [
        'name' => 'SOGo',
        'link' => '/SOGo/'
    ],
    [
        'name' => 'Roundcube',
        'link' => '/rc/'
    ]
];
```

### Let admins log into Roundcube without password

First, install plugin [dovecot_impersonate](https://github.com/corbosman/dovecot_impersonate/) and add Roundcube as an app (see above).

```bash
docker exec -it -w /web/rc/plugins $(docker ps -f name=php-fpm-mailcow -q) git clone https://github.com/corbosman/dovecot_impersonate.git
```

Open `data/web/rc/config/config.inc.php` and enable the dovecot_impersonate plugin by adding it to the `$config['plugins']` array,
for example:

```php
$config['plugins'] = array(
  'archive',
  'managesieve',
  'acl',
  'markasjunk',
  'zipdownload',
  'password',
  'dovecot_impersonate'
);
```

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
  php-fpm-mailcow:
    environment:
      - ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=${ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE:-n}
```

Edit `data/web/js/site/mailbox.js` and the following code after [`if (ALLOW_ADMIN_EMAIL_LOGIN) { ... }`](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/js/site/mailbox.js#L485-L487)

```js
if (ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE) {
  item.action += '<a href="/rc-auth.php?login=' + encodeURIComponent(item.username) + '" class="login_as btn btn-sm btn-xs-half btn-primary" target="_blank"><i class="bi bi-envelope-fill"></i> Roundcube</a>';
}
```

Edit `data/web/mailbox.php` and add this line to array [`$template_data`](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/mailbox.php#L33-L43):

```php
  'allow_admin_email_login_roundcube' => (preg_match("/^(yes|y)+$/i", $_ENV["ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE"])) ? 'true' : 'false',
```

Edit `data/web/templates/mailbox.twig` and add this code to the bottom of the [javascript section](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/templates/mailbox.twig#L49-L57):

```js
  var ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE = {{ allow_admin_email_login_roundcube }};
```

Copy the contents of the following files from this [Snippet](https://gitlab.com/-/snippets/2038244):

* `data/web/inc/lib/RoundcubeAutoLogin.php`
* `data/web/rc-auth.php`

## Finish installation
Finally, restart mailcow

=== "docker compose (Plugin)"

    ``` bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose down
    docker-compose up -d
    ```

## Upgrading Roundcube

Upgrading Roundcube is rather simple, go to the [GitHub releases](https://github.com/roundcube/roundcubemail/releases)
page for Roundcube and get the link for the "complete.tar.gz" file for the wanted release. Then follow the below
commands and change the URL and Roundcube folder name if needed.

```bash
# Enter a bash session of the mailcow PHP container
docker exec -it mailcowdockerized-php-fpm-mailcow-1 bash

# Install required upgrade dependency, then upgrade Roundcube to wanted release
apk add rsync
cd /tmp
wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.2/roundcubemail-1.6.2-complete.tar.gz | tar xfvz -
cd roundcubemail-1.6.2
bin/installto.sh /web/rc

# Type 'Y' and press enter to upgrade your install of Roundcube
# Type 'N' to "Do you want me to fix your local configuration" if prompted

# If you see "NOTICE: Update dependencies by running php composer.phar update --no-dev" run composer:
cd /web/rc
composer update --no-dev -o
# If asked "Do you trust "roundcube/plugin-installer" to execute code and wish to enable it now? (writes "allow-plugins" to composer.json) [y,n,d,?] " hit y and continue.

# Remove leftover files
rm -rf /tmp/roundcube*

# If you're going from 1.5 to 1.6 please run the config file changes below
sed -i "s/\$config\['default_host'\].*$/\$config\['imap_host'\]\ =\ 'dovecot:143'\;/" /web/rc/config/config.inc.php
sed -i "/\$config\['default_port'\].*$/d" /web/rc/config/config.inc.php
sed -i "s/\$config\['smtp_server'\].*$/\$config\['smtp_host'\]\ =\ 'postfix:588'\;/" /web/rc/config/config.inc.php
sed -i "/\$config\['smtp_port'\].*$/d" /web/rc/config/config.inc.php
sed -i "s/\$config\['managesieve_host'\].*$/\$config\['managesieve_host'\]\ =\ 'dovecot:4190'\;/" /web/rc/config/config.inc.php
sed -i "/\$config\['managesieve_port'\].*$/d" /web/rc/config/config.inc.php
```

### Upgrade composer plugins

To upgrade roundcube plugins installed using composer and dependencies (e.g. RCMCardDAV plugin), you can simply run
composer in the container:

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer update --no-dev -o
```

### Upgrade mime type mappings

To upgrade the mime type mappings, re-download them using the command in the
[installation instructions](#Install-mime-type-mappings).

## Uninstalling roundcube

For the uninstallation, it is also assumed that the commands are executed in the mailcow installation directory and
that `mailcow.conf` has been sourced in the shell, see [Preparation](#Preparation) above.

### Remove the web directory

This deletes the roundcube installation and all plugins and dependencies that you may have installed,
including those installed with composer.

Note: This deletes also any custom configuration that you may have done in roundcube. If you want to preserve it, move it some
place else instead of deleting it.

```bash
rm -r data/web/rc
```

### Remove the database

Note: This clears all data stored for roundcube. If you want to preserve it, you could use `mysqldump` before deleting the data,
or simply keep the database.

```bash
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "DROP USER 'roundcube'@'%';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "DROP DATABASE roundcubemail;"
```

### Remove any custom configuration files we added to mailcow

To determine these, please read through the installation steps and revert what you changed there.

## Migration from older mailcow roundcube setup

Older versions of this instruction used the mailcow database also for roundcube, with a configured name prefix
`mailcow_rc1` on all roundcube tables.

For the migration, it is also assumed that the commands are executed in the mailcow installation directory and
that `mailcow.conf` has been sourced in the shell, see [Preparation](#Preparation) above. The commands of the different
steps build on each other and must be executed in the same shell. Particularly, some steps set shell variables (most
importantly the `DBROUNDCUBE` variable with the database password of the roundcube database user) used in later steps.

### Create new roundcube database user and database

Follow the [steps above](#Create-roundcube-database) to create the roundcube database user and the separate database.

### Migrate roundcube data from mailcow database

Before starting the database migration, we disable roundcube to avoid further changes to the roundcube database tables
during the migration.

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location ^~ /rc/ {
  return 503;
}
EOCONFIG
docker compose exec nginx-mailcow nginx -s reload
```

Now we copy the roundcube data to the new database. We strip the database table prefix in the process, you may need to
adjust `mailcow\_rc1` in case you used a different prefix. It is also possible to keep the prefix (then also keep the
respective `db_prefix` roundcube setting).

```bash
RCTABLES=$(docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -sN mailcow -e "show tables like 'mailcow_rc1%';" | tr '\n\r' ' ')
docker exec $(docker ps -f name=mysql-mailcow -q) /bin/bash -c "mysqldump -uroot -p${DBROOT} mailcow $RCTABLES | sed 's/mailcow_rc1//' | mysql -uroot -p${DBROOT} roundcubemail"
```

### Update roundcube configuration

Run the following to remove the no longer required `db_prefix` option. We also enable logging of roundcube by removing
the settings `log_dir` and `temp_dir` that were part of the old setup instructions.

```bash
sed -i "/\$config\['db_prefix'\].*$/d" data/web/rc/config/config.inc.php
sed -i "/\$config\['log_dir'\].*$/d" data/web/rc/config/config.inc.php
sed -i "/\$config\['temp_dir'\].*$/d" data/web/rc/config/config.inc.php
```

We need to adapt the nginx configuration for roundcube to not expose the non-public folders of roundcube, specifically
those containing temporary files and log files:

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location /rc/ {
  alias /web/rc/public_html/;
}
EOCONFIG
```

We can also update the `cipher_method` to a more secure one but mind that data previously encrypted by roundcube cannot
be decrypted anymore afterwards. This specifically affects stored CardDAV passwords if you use RCMCardDAV and your
users added custom addressbooks (the preset will be fixed automatically upon next login of the user). If you want to
change the `cipher_method`, run:

```bash
cat <<EOCONFIG >>data/web/rc/config/config.inc.php
\$config['cipher_method'] = 'chacha20-poly1305';
EOCONFIG
```

### Switch RCMCardDAV plugin to composer installation method

This is optional but will align your installation with these instructions and enable you to upgrade RCMCardDAV
using composer. This is simply done by deleting the carddav plugin from the installation and installing it using
composer according to the [instructions above](#Integrate-CardDAV-addressbooks-in-Roundcube), which include the creation
of a new RCMCardDAV v5 config. In case you modified your RCMCardDAV configuration file, you may want to backup it before
deleting the plugin and carry over your changes to the new configuration afterwards as well.

To delete the carddav plugin run the following command, then re-install according to the
[instructions above](#Integrate-CardDAV-addressbooks-in-Roundcube):

```bash
rm -r data/web/rc/plugins/carddav
```

### Switch roundcube to new database

First adapt the roundcube configuration to use the new database.
```bash
sed -i "/\$config\['db_dsnw'\].*$/d" data/web/rc/config/config.inc.php
cat <<EOCONFIG >>data/web/rc/config/config.inc.php
\$config['db_dsnw'] = 'mysql://roundcube:${DBROUNDCUBE}@mysql/roundcubemail';
EOCONFIG
```

### Re-enable roundcube web access
Execute the chown and chmod commands on sensitive roundcube directories listed in [Preparation](#Preparation), to
make sure the nginx webserver cannot access files it is not supposed to serve.

Then re-enable web access to roundcube by replacing our temporary roundcube custom config for the one described
[above](#Webserver-configuration), and reload the nginx configuration:

```bash
docker compose exec nginx-mailcow nginx -s reload
```

### Other changes
You must also adapt the configuration of the roundcube password plugin according to this instruction, specifically if
you use the password changing functionality, since the old instruction directly changed the password in the database,
whereas this version of the instruction uses the mailcow API for the password change.

Regarding other changes and additions (e.g., roundcube-dovecot\_client\_ip plugin), you can go through the current
installation instructions and adapt your configuration accordingly or perform the listed installation steps for new
additions.

Specifically, consider the following sections:
  - [Ofelia job for roundcube housekeeping](#Ofelia-job-for-roundcube-housekeeping)
  - [Allow plaintext authentication in dovecot](#Allow-plaintext-authentication-for-the-php-fpm-container-without-using-TLS),
    if you adapt the roundcube configuration to contact dovecot via non-encrypted IMAP connection.
  - [Forward the client network address to dovecot](#Forward-the-client-network-address-to-dovecot)

### Removing roundcube tables from mailcow database

After you have verified that the migration was successful and roundcube works using the separate database, you can remove
the roundcube tables from the mailcow database using the following command:

```bash
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -sN mailcow -e "SET SESSION foreign_key_checks = 0; DROP TABLE IF EXISTS $(echo $RCTABLES | sed -e 's/ \+/,/g');"
```
