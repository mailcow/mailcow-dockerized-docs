## Installation von Roundcube

Laden Sie Roundcube 1.6.x in das Web htdocs Verzeichnis herunter und entpacken Sie es (hier `rc/`):
```
# Prüfen Sie, ob eine neuere Version vorliegt!
cd daten/web
wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.0/roundcubemail-1.6.0-complete.tar.gz | tar xfvz -

# Ändern Sie den Ordnernamen
mv roundcubemail-1.6.0 rc

# Berechtigungen ändern
chown -R root: rc/
```

Wenn Sie eine Rechtschreibprüfung benötigen, erstellen Sie eine Datei `data/hooks/phpfpm/aspell.sh` mit folgendem Inhalt und geben Sie dann `chmod +x data/hooks/phpfpm/aspell.sh` ein. Dadurch wird eine lokale Rechtschreibprüfung installiert. Beachten Sie, dass die meisten modernen Webbrowser eine eingebaute Rechtschreibprüfung haben, so dass Sie diese vielleicht nicht benötigen.
```
#!/bin/bash
apk update
apk add aspell-de # oder jede andere Sprache
```

Erstellen Sie eine Datei `data/web/rc/config/config.inc.php` mit dem folgenden Inhalt.
   - **Ändern Sie den Parameter `des_key` auf einen Zufallswert.** Er wird verwendet, um Ihr IMAP-Passwort vorübergehend zu speichern.
   - Der `db_prefix` ist optional, wird aber empfohlen.
   - Wenn Sie die Rechtschreibprüfung im obigen Schritt nicht installiert haben, entfernen Sie den Parameter `spellcheck_engine` und ersetzen ihn durch `$config['enable_spellcheck'] = false;`.
```
<?php
error_reporting(0);
if (!file_exists('/tmp/mime.types')) {
file_put_contents("/tmp/mime.types", fopen("http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types", 'r'));
}
$config = array();
$config['db_dsnw'] = 'mysql://' . getenv('DBUSER') . ':' . getenv('DBPASS') . '@mysql/' . getenv('DBNAME');
$config['imap_host'] = 'tls://dovecot:143';
$config['smtp_server'] = 'tls://postfix:587';
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
$config['spellcheck_engine'] = 'aspell';
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

Richten Sie Ihren Browser auf `https://myserver/rc/installer` und folgen Sie den Anweisungen.
Initialisiere die Datenbank und verlasse das Installationsprogramm.

**Löschen Sie das Verzeichnis `data/web/rc/installer` nach einer erfolgreichen Installation!

## Konfigurieren Sie die ManageSieve-Filterung

Öffnen Sie `data/web/rc/plugins/managesieve/config.inc.php` und ändern Sie die folgenden Parameter (oder fügen Sie sie am Ende der Datei hinzu):
```
$config['managesieve_host'] = 'tls://dovecot:4190';
$config['managesieve_conn_options'] = array(
  ssl' => array('verify_peer' => false, 'verify_peer_name' => false, 'allow_self_signed' => true)
);
// Aktiviert separate Verwaltungsschnittstelle für Urlaubsantworten (außer Haus)
// 0 - kein separater Abschnitt (Standard),
// 1 - Abschnitt "Urlaub" hinzufügen,
// 2 - Abschnitt "Urlaub" hinzufügen, aber Abschnitt "Filter" ausblenden
$config['managesieve_vacation'] = 1;
```

## Aktivieren Sie die Funktion "Passwort ändern" in Roundcube

Öffnen Sie `data/web/rc/config/config.inc.php` und aktivieren Sie das Passwort-Plugin:

```
[...]
$config['plugins'] = array(
    'archive',
    'password',
);
[...]
```

Öffnen Sie `data/web/rc/plugins/password/password.php`, suchen Sie nach `case 'ssha':` und fügen Sie oben hinzu:

```
        case 'ssha256':
            $salt = rcube_utils::random_bytes(8);
            $crypted = base64_encode( hash('sha256', $password . $salt, TRUE ) . $salt );
            $prefix  = '{SSHA256}';
            break;
```

Öffnen Sie `data/web/rc/plugins/password/config.inc.php` und ändern Sie die folgenden Parameter (oder fügen Sie sie am Ende der Datei hinzu):

```
$config['password_driver'] = 'sql';
$config['password_algorithm'] = 'ssha256';
$config['password_algorithm_prefix'] = '{SSHA256}';
$config['password_query'] = "UPDATE mailbox SET password = %P WHERE username = %u";
```

## CardDAV Adressbücher in Roundcube einbinden

Laden Sie die neueste Version von [RCMCardDAV](https://github.com/mstilkerich/rcmcarddav) in das Roundcube Plugin Verzeichnis und entpacken Sie es (hier `rc/plugins`):
```
cd data/web/rc/plugins
wget -O - https://github.com/mstilkerich/rcmcarddav/releases/download/v4.4.1/carddav-v4.4.1-roundcube16.tar.gz | tar xfvz -
chown -R root: carddav/
```
  
Kopieren Sie die Datei `config.inc.php.dist` nach `config.inc.php` (hier in `rc/plugins/carddav`) und fügen Sie die folgende Voreinstellung an das Ende der Datei an - vergessen Sie nicht, `mx.example.org` durch Ihren eigenen Hostnamen zu ersetzen:
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
Bitte beachten Sie, dass dieses Preset nur das Standard-Adressbuch integriert (dasjenige, das den Namen "Persönliches Adressbuch" trägt und nicht gelöscht werden kann). Weitere Adressbücher werden derzeit nicht automatisch erkannt, können aber manuell in den Roundcube-Einstellungen hinzugefügt werden.

Aktivieren Sie das Plugin, indem Sie `carddav` zu `$config['plugins']` in `rc/config/config.inc.php` hinzufügen.

Wenn Sie die Standard-Adressbücher (die in der Roundcube-Datenbank gespeichert sind) entfernen möchten, so dass nur die CardDAV-Adressbücher zugänglich sind, fügen Sie `$config['address_book_type'] = '';` in die Konfigurationsdatei `data/web/rc/config/config.inc.php` ein.

---

Optional können Sie Roundcube's Link zu der mailcow Apps Liste hinzufügen.
Um dies zu tun, öffnen oder erstellen Sie `data/web/inc/vars.local.inc.php` und fügen Sie den folgenden Code-Block hinzu:

*HINWEIS: Vergessen Sie nicht, das `<?php` Trennzeichen in der ersten Zeile einzufügen*

```
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
```

## Aktualisierung von Roundcube

Ein Upgrade von Roundcube ist recht einfach: Gehen Sie auf die [Github releases](https://github.com/roundcube/roundcubemail/releases) Seite für Roundcube und holen Sie sich den Link für die "complete.tar.gz" Datei für die gewünschte Version. Dann folgen Sie den untenstehenden Befehlen und ändern Sie die URL und den Namen des Roundcube-Ordners, falls nötig. 


```
# Starten Sie eine Bash-Sitzung des mailcow PHP-Containers
docker exec -it mailcowdockerized-php-fpm-mailcow-1 bash

# Installieren Sie die erforderliche Upgrade-Abhängigkeit, dann aktualisieren Sie Roundcube auf die gewünschte Version
apk add rsync
cd /tmp
wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.0/roundcubemail-1.6.0-complete.tar.gz | tar xfvz -
cd roundcubemail-1.6.0
bin/installto.sh /web/rc

# Geben Sie 'Y' ein und drücken Sie die Eingabetaste, um Ihre Installation von Roundcube zu aktualisieren.
# Geben Sie 'N' ein, wenn folgender Dialog erscheint: "Do you want me to fix your local configuration".

# Entfernen Sie übrig gebliebene Dateien
cd /tmp
rm -rf roundcube*

# Falls Sie von Version 1.5 auf 1.6 updaten, dann führen Sie folgende Befehle aus, um die Konfigurationsdatei anzupassen:`
sed -i "s/\$config\['default_host'\].*$/\$config\['imap_host'\]\ =\ 'tls:\/\/dovecot:143'\;/" /web/rc/config/config.inc.php
sed -i "/\$config\['default_port'\].*$/d" /web/rc/config/config.inc.php
sed -i "s/\$config\['smtp_server'\].*$/\$config\['smtp_host'\]\ =\ 'tls:\/\/postfix:587'\;/" /web/rc/config/config.inc.php
sed -i "/\$config\['smtp_port'\].*$/d" /web/rc/config/config.inc.php
sed -i "s/\$config\['managesieve_host'\].*$/\$config\['managesieve_host'\]\ =\ 'tls:\/\/dovecot:4190'\;/" /web/rc/config/config.inc.php
sed -i "/\$config\['managesieve_port'\].*$/d" /web/rc/config/config.inc.php
```

## Administratoren ohne Passwort in Roundcube einloggen lassen

Installieren Sie zunächst das Plugin [dovecot_impersonate] (https://github.com/corbosman/dovecot_impersonate/) und fügen Sie Roundcube als App hinzu (siehe oben).

Editieren Sie `mailcow.conf` und fügen Sie folgendes hinzu:

```
# Erlaube Admins, sich in Roundcube als Email-Benutzer einzuloggen (ohne Passwort)
# Roundcube mit Plugin dovecot_impersonate muss zuerst installiert werden

ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=y
```

Editieren Sie `docker-compose.override.yml` und verfassen/erweitern Sie den Abschnitt für `php-fpm-mailcow`:

```yml
version: '2.1'
services:
  php-fpm-mailcow:
    environment:
      - ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=${ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE:-n}
```


Bearbeiten Sie `data/web/js/site/mailbox.js` und den folgenden Code nach [`if (ALLOW_ADMIN_EMAIL_LOGIN) { ... }`](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/js/site/mailbox.js#L485-L487)

```js
if (ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE) {
  item.action += '<a href="/rc-auth.php?login=' + encodeURIComponent(item.username) + '" class="login_as btn btn-xs ' + btnSize + ' btn-primary" target="_blank"><i class="bi bi-envelope-fill"></i> Roundcube</a>';
}
```

Bearbeiten Sie `data/web/mailbox.php` und fügen Sie diese Zeile zum Array [`$template_data`](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/mailbox.php#L33-L43) hinzu:

```php
  'allow_admin_email_login_roundcube' => (preg_match("/^(yes|y)+$/i", $_ENV["ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE"])) ? 'true' : 'false',
```

Bearbeiten Sie `data/web/templates/mailbox.twig` und fügen Sie diesen Code am Ende des [javascript-Abschnitts] ein (https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/templates/mailbox.twig#L49-L57):

```js
  var ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE = {{ allow_admin_email_login_roundcube }};
```

Kopieren Sie den Inhalt der folgenden Dateien aus diesem [Snippet](https://gitlab.com/-/snippets/2038244):

* `data/web/inc/lib/RoundcubeAutoLogin.php`
* `data/web/rc-auth.php`

Starten Sie schließlich mailcow neu

```
docker-compose down
docker-compose up -d
```




