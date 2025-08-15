## Installation von Roundcube

!!! note "Beachten Sie"
Sofern nicht abweichend angegeben wird für alle aufgeführten Kommandos angenommen, dass diese im mailcow
Installationsverzeichnis ausgeführt werden, d. h. dem Verzeichnis, welches `mailcow.conf` usw. enthält. Bitte führen Sie
die Kommandos nicht blind aus, sondern verstehen Sie was diese bewirken. Keines der Kommandos sollte einen Fehler
ausgeben; sollten Sie dennoch auf einen Fehler stoßen, beheben Sie diesen sofern notwendig bevor Sie mit den
nachfolgenden Kommandos fortfahren.

## Integrierte Installation

### Hinweise zur Verwendung von composer

Diese Anweisungen verwenden das Programm composer zur Aktualisierung der Abhängigkeiten von Roundcube und um
Roundcube-Plugins zu installieren bzw. zu aktualisieren.

Das roundcube-plugin-installer composer Plugin hat eine [Design-Schwäche](https://github.com/roundcube/plugin-installer/issues/38),
die dazu führen kann, dass composer bei Operationen fehlschlägt, im Rahmen derer Pakete aktualisiert oder deinstalliert
werden.

Die Fehlermeldung in diesem Falle besagt, dass eine `require`-Anweisung in `autoload_real.php` fehlgeschlagen ist, weil
eine Datei nicht gefunden werden konnte. Beispiel:

```
In autoload_real.php line 43:
  require(/web/rc/vendor/composer/../guzzlehttp/promises/src/functions_include.php): Failed to open stream: No such file or directory
```

Leider treten diese Fehler relativ häufig auf, sie lassen sich jedoch leicht beheben indem der Autoloader aktualisiert
wird und das fehlgeschlagene Kommando im Anschluss erneut ausgeführt wird:

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer dump-autoload -o
# Nun das fehlgeschlagene Kommando erneut ausführen
```

### Vorbereitung

Zunächst laden wir `mailcow.conf` um Zugriff auf die mailcow-Einstellungen innerhalb der nachfolgenden Kommandos zu
erhalten.

```bash
source mailcow.conf
```

Laden Sie Roundcube 1.6.x (prüfen Sie das aktuellste Release und passen Sie die URL entsprechend an) in das web
Verzeichnis herunter und entpacken Sie es (hier `rc/`):

```bash
mkdir -m 755 data/web/rc
wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.11/roundcubemail-1.6.11-complete.tar.gz | tar -xvz --no-same-owner -C data/web/rc --strip-components=1 -f -
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown www-data:www-data /web/rc/logs /web/rc/temp
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chmod 750 /web/rc/logs /web/rc/temp /web/rc/config
```

### Optional: Rechtschreibprüfung

Wenn Sie eine Rechtschreibprüfung benötigen, erstellen Sie eine Datei `data/hooks/phpfpm/aspell.sh` mit folgendem Inhalt
und geben Sie dann `chmod +x data/hooks/phpfpm/aspell.sh` ein. Dadurch wird eine lokale Rechtschreibprüfung installiert.
Beachten Sie, dass die meisten modernen Webbrowser eine eingebaute Rechtschreibprüfung haben, so dass Sie diese
vielleicht nicht benötigen.

```bash
#!/bin/bash
apk update
apk add aspell-de # oder jede andere Sprache
```

### Installation des MIME-Typ-Verzeichnisses

Laden Sie die `mime.types` Datei herunter, da diese nicht im `php-fpm`-Container enthalten ist.

```bash
wget -O data/web/rc/config/mime.types http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
```

### Anlegen der Roundcube-Datenbank

Erstellen Sie eine Datenbank für Roundcube im mailcow mysql Container. Dies erstellt einen neuen `roundcube`
Datenbank-Benutzer mit einem Zufallspasswort, welches in die Shell ausgegeben wird und in einer Shell-Variable für die
Verwendung durch die nachfolgenden Kommandos gespeichert wird. Beachten Sie, dass Sie die `DBROUNDCUBE`-Shell-Variable
manuell auf das ausgegebene Passwort setzen müssen, falls sie den Installationsprozess unterbrechen und später in einer
neuen Shell fortsetzen sollten.

```bash
DBROUNDCUBE=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
echo Das Datenbank-Password für den Benutzer roundcube lautet $DBROUNDCUBE
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE roundcubemail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'roundcube'@'%' IDENTIFIED BY '${DBROUNDCUBE}';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'%';"
```

### Roundcube-Konfigurationsdatei

Erstellen Sie eine Datei `data/web/rc/config/config.inc.php` mit dem folgenden Inhalt.

- Die `des_key`-Einstellung wird auf einen Zufallswert gesetzt. Sie wird u. a. zur Verschlüsselung vorübergehend
  gespeicherter IMAP-Passwörter verwendet.
- Die Liste der Plugins kann nach Belieben angepasst werden. Die folgende Liste enthält eine Liste von
  Standard-Plugins, welche ich als allgemein nützlich empfinde und die gut mit mailcow zusammenspielen:
  - Das archive-Plugin fügt einen Archiv-Button hinzu, der ausgewählte E-Mails in ein konfigurierbares
    Archiv-Verzeichnis verschiebt.
  - Das managesieve-Plugin bietet eine benutzerfreundliche Oberfläche zur Verwaltung serverseitiger E-Mail-Filter und
    Abwesenheits-Benachrichtigungen.
  - Das acl-Plugin ermöglicht die Verwaltung von Zugriffskontroll-Listen auf IMAP-Verzeichnissen, mit der Möglichkeit
    IMAP-Verzeichnisse mit anderen Benutzern zu teilen.
  - Das markasjunk-Plugin fügt Buttons hinzu, um ausgewählte E-Mails als Spam (oder E-Mails im Junk-Verzeichnis nicht
    als Spam) zu markieren und diese in das Junk-Verzeichnis (oder zurück in den Posteingang) zu verschieben. Die in
    mailcow enthaltenen Sieve-Filter lösen automatisch die zugehörige Lern-Operation in rspamd aus, so dass keine
    weitere Konfiguration des Plugins erforderlich ist.
  - Das zipdownload-Plugin erlaubt es, mehrere E-Mail-Anhänge oder E-Mails als ZIP-Archiv herunterzuladen.
- Wenn Sie die Rechtschreibprüfung im obigen Schritt nicht installiert haben, entfernen Sie den Parameter
  `spellcheck_engine`.

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

### Initialisierung der Datenbank

Richten Sie Ihren Browser auf `https://myserver/rc/installer`. Prüfen Sie, dass die Webseite in keinem der Schritte "NOT
OK"-Testergebnisse zeigt. Einige "NOT AVAILABLE"-Testergebnisse sind bzgl. der verschiedenen Datenbank-Erweiterungen
erwartet, von denen nur MySQL benötigt wird.

Initialisieren Sie die Datenbank und verlassen Sie das Installationsprogramm. Es ist nicht notwendig, die
Konfigurationsdatei mit der heruntergeladenen Datei zu aktualisieren, sofern Sie keine Änderungen an den Einstellungen
innerhalb des Installationsprogramms durchgeführt habe, die Sie übernehmen möchten.

### Webserver-Konfiguration

Das Roundcube-Verzeichnis enthält einige Inhalte, die nicht an Web-Nutzer ausgeliefert werden sollen. Wir erstellen
daher eine Konfigurations-Ergänzung für nginx, um nur die öffentlichen Teile von Roundcube im Web zu exponieren:

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location /rc/ {
  alias /web/rc/public_html/;
}
EOCONFIG
```

### Deaktivieren und entfernen des Installationsprogramms

Löschen Sie das Verzeichnis `data/web/rc/installer` nach einer erfolgreichen Installation, und setzen Sie die
`enable_installer`-Option in `data/web/rc/config/config.inc.php` auf `false`:

```bash
rm -r data/web/rc/installer
sed -i -e "s/\(\$config\['enable_installer'\].* = \)true/\1false/" data/web/rc/config/config.inc.php
```

### Aktualisierung der Roundcube-Abhängigkeiten

Dieser Schritt ist nicht unbedingt notwendig, aber zumindest zum Zeitpunkt der Erstellung dieser Anweisungen enthielten
die mit Roundcube ausgelieferten Abhängigkeiten Versionen mit Sicherheitslücken, daher könnte es eine gute Idee sein,
die Abhängigkeiten auf die neusten Versionen zu aktualisieren. Aus demselben Grund sollte composer update hin und wieder
ausgeführt werden.

```bash
cp -n data/web/rc/composer.json-dist data/web/rc/composer.json
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer update --no-dev -o
```

Sie können außerdem `composer audit` verwenden, um bekannte Sicherheitslücken in den installierten composer-Paketen
anzuzeigen.

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer audit
```

### Ermöglichen der Klartext-Authentifizierung für den php-fpm-Container ohne die Verwendung von TLS

Wir müssen die Verwendung von Klartext-Authentifizierung über nicht verschlüsselte Verbindungen (innerhalb der
Container-Netzwerks) in Dovecot zulassen, was in der Standard-Installation von mailcow nur für den SOGo-Container
zum gleichen Zweck möglich ist. Danach starten Sie den Dovecot-Container neu, damit die Änderung wirksam wird.

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

### Ofelia-Job für Roundcube-Aufräumtätigkeiten

Roundcube muss regelmässig die Datenbank von nicht mehr benötigter Information befreien. Wir legen einen Ofelia-Job an,
der das Roundcube `cleandb.sh`-Skript regelmässig ausführt.

Um dies zu tun, fügen Sie folgendes zu `docker-compose.override.yml` hinzu (falls Sie bereits einige Anpassungen für den
php-fpm-Container durchgeführt haben, fügen Sie die Label dem bestehenden Abschnitt hinzu):

```yaml
services:
  php-fpm-mailcow:
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.roundcube_cleandb.schedule: "@every 168h"
      ofelia.job-exec.roundcube_cleandb.user: "www-data"
      ofelia.job-exec.roundcube_cleandb.command: '/bin/bash -c "[ -f /web/rc/bin/cleandb.sh ] && /web/rc/bin/cleandb.sh"'
```

## Externe Installation

Um Roundcube in einem eigenen Docker-Container installieren zu können muss zu Ihrer existierenden `docker-compose.yaml` Datei folgendes hinzugefügt werden:

```yaml
services:
  # ...

  roundcube:
    image: roundcube/roundcubemail:1.6.11-apache # Siehe neuste version https://hub.docker.com/r/roundcube/roundcubemail/tags?name=apache
    environment:
      IPV4_NETWORK: ${IPV4_NETWORK:-172.22.1}
      IPV6_NETWORK: ${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64}
      ROUNDCUBEMAIL_DB_TYPE: mysql
      ROUNDCUBEMAIL_DB_HOST: mysql
      ROUNDCUBEMAIL_DB_USER: roundcube
      ROUNDCUBEMAIL_DB_PASSWORD: ${DBROUNDCUBE}
      ROUNDCUBEMAIL_DB_NAME: roundcubemail
      ROUNDCUBEMAIL_DEFAULT_HOST: ssl://dovecot:143
      ROUNDCUBEMAIL_SMTP_SERVER: ssl://postfix:587
      ROUNDCUBEMAIL_PLUGINS: archive, managesieve, acl, markasjunk, zipdownload
    volumes:
      # == Dokumentation Kompatibilität ==
      # Diese Mounts sind ähnlich zu der Integrierten Installation aufgebaut
      # jedoch ist es empfohlen Mounts innerhalb des web/rc Ordners zu vermeiden, da diese Ordner ebenfalls im php-fpm Container eingehängt sind
      # - ./data/web/rc:/var/www/html
      # - ./data/web/rc/persistent-config:/var/roundcube/config

      # Erweiterte Variante (weniger kompatible, dafür aber sicherer)
      - ./data/rc/main:/var/www/html
      - ./data/rc/config:/var/roundcube/config
    depends_on:
      - mysql-mailcow
      - dovecot-mailcow
    restart: unless-stopped
    networks:
      mailcow-network:
        aliases:
          - roundcube

networks:
  proxy:
    external: true
```

### Webserver-Konfiguration

Das Roundcube-Verzeichnis enthält einige Inhalte, die nicht an Web-Nutzer ausgeliefert werden sollen. Wir erstellen
daher eine Konfigurations-Ergänzung für nginx, um nur die öffentlichen Teile von Roundcube im Web zu exponieren:

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location /rc/ {
  alias /web/rc/public_html/;
}
EOCONFIG
```

### Anlegen der Roundcube-Datenbank

Zunächst falls noch nicht getan, die Shell Variablen laden:

```bash
source mailcow.conf
```

Erstellen Sie eine Datenbank für Roundcube im mailcow mysql Container. Dies erstellt einen neuen `roundcube`
Datenbank-Benutzer mit einem Zufallspasswort, welches in die Shell ausgegeben wird und in einer Shell-Variable für die
Verwendung durch die nachfolgenden Kommandos gespeichert wird. Beachten Sie, dass Sie die `DBROUNDCUBE`-Shell-Variable
manuell auf das ausgegebene Passwort setzen müssen, falls sie den Installationsprozess unterbrechen und später in einer
neuen Shell fortsetzen sollten.

Hiermit besagtes Passwort generieren:

```bash
LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28
```

Anschließend den Wert `DBROUNDCUBE` in der Datei mailcow.conf auf das generierte Passwort setzen und...

```bash
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE roundcubemail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'roundcube'@'%' IDENTIFIED BY '${DBROUNDCUBE}';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'%';"
```

ausführen.

### Optional: Plugins hinzufügen

Um Plugins zu aktivieren müssen diese in `ROUNDCUBEMAIL_PLUGINS` gesetzt sein.
Falls ein Plugin noch nicht vorinstalliert, bzw. installiert ist muss dieses auch zu der `ROUNDCUBEMAIL_COMPOSER_PLUGINS` Umgebungsvariable in `docker-compose.yaml` hinzugefügt werden.

### Starte den Roundcube Container

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

**Wichtige Information für den Verlauf der Dokumentation:**

!!! note
Im Verlauf der Dokumentation werden Sie gebeten Dateien innerhalb von `data/web/rc/config` zu verändern
nutzen Sie stattdessen `data/web/rc/persistent-config` oder `data/rc/config` (Erweiterte Variante).
Dies liegt daran, dass Roundcube seine Konfigurationsdateien automatisch anhand von Konfigurationsdateien in `persistent-config/` / `data/rc/config/` innerhalb von `rc/main/config/` oder `web/rc/config/` erstellt.

If you chose to mount in the _Advanced_ way notice folders like `plugins/` are located inside of `data/rc/main`.
Sofern Sie sich für die Erweiterte Variante entschieden haben merken Sie sich, dass Ordner wie `plugins/` sich in `data/rc/main` befinden.

## Optionale Zusatz-Funktionalitäten

## Aktivieren der Funktion "Passwort ändern" in Roundcube

Das Ändern des mailcow Passworts aus der Roundcube-Benutzeroberfläche wird durch das password-Plugin ermöglicht. Wir
konfigurieren dieses zur Verwendung der mailcow-API zur Passwort-Aktualisierung, was es zunächst erfordert, die API zu
aktivieren und den API-Schlüssel zu ermitteln (Lese-/Schreib-Zugriff notwendig). Die API kann in der
mailcow-Administrationsoberfläche aktiviert werden, wo Sie auch den API-Schlüssel finden.

Öffnen Sie `data/web/rc/config/config.inc.php` und aktivieren Sie das Passwort-Plugin, indem Sie es dem
`$config['plugins']`-Array oder zur `ROUNDCUBEMAIL_PLUGINS` Variable hinzufügen, zum Beispiel:

=== "Integriert"

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

=== "Extern"

    ```yaml
          ROUNDCUBEMAIL_PLUGINS: archive, managesieve, acl, markasjunk, zipdownload, password
    ```

Konfigurieren Sie das password-Plugin (stellen Sie sicher, **\*\*API_KEY\*\*** auf Ihren mailcow Lese-/Schreib-API-Schlüssel
anzupassen):

```bash
cat <<EOCONFIG >data/web/rc/plugins/password/config.inc.php
<?php
\$config['password_driver'] = 'mailcow';
\$config['password_confirm_current'] = true;
\$config['password_mailcow_api_host'] = 'http://nginx';
\$config['password_mailcow_api_token'] = '**API_KEY**';
EOCONFIG
```

Hinweis: Sollten Sie die mailcow nginx-Konfiguration so angepasst haben, dass http-Anfragen auf https umgeleitet werden
(wie z. B. [hier](../../manual-guides/u_e-80_to_443.md) beschrieben), dann wird die direkte
Verbindung zum nginx-Container via HTTP nicht funktionieren, da nginx kein im Zertifikat enthaltener Hostname ist. In
solchen Fällen setzen Sie `password_mailcow_api_host` stattdessen auf die öffentliche URI:

```bash
cat <<EOCONFIG >data/web/rc/plugins/password/config.inc.php
<?php
\$config['password_driver'] = 'mailcow';
\$config['password_confirm_current'] = true;
\$config['password_mailcow_api_host'] = 'https://${MAILCOW_HOSTNAME}';
\$config['password_mailcow_api_token'] = '**API_KEY**';
EOCONFIG
```

## CardDAV-Adressbücher in Roundcube einbinden

=== "Integriert"
    Installieren Sie die neuste v5-Version (die untenstehende Konfiguration ist kompatibel zu v5-Releases) mit composer.
    Antworten Sie `Y`, wenn Sie gefragt werden, ob Sie das Plugin aktivieren möchten.

    ```bash
    docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer require --update-no-dev -o "roundcube/carddav:~5"
    ```

=== "Extern"
    Installieren Sie die neueste version von CardDAV indem Sie `carddav` zu `ROUNDCUBEMAIL_PLUGINS` hinzufügen:

    ```yaml
    ROUNDCUBEMAIL_PLUGINS: archive, managesieve, acl, markasjunk, zipdownload, carddav
    ROUNDCUBEMAIL_COMPOSER_PLUGINS: "roundcube/carddav:~5"
    ```

Editieren Sie die Datei `data/web/rc/plugins/carddav/config.inc.php` und fügen Sie folgenden Inhalt hinzu:

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

RCMCardDAV legt alle Adressbücher des Benutzers beim Login in Roundcube an, einschließlich **abonnierten** Adressbüchern
die mit dem Benutzers von anderen Benutzern geteilt werden.

Wenn Sie das Standard-Adressbuch (gespeichert in der Roundcube-Datenbank) entfernen möchten, so dass nur
CardDAV-Adressbücher verwendet werden können, fügen Sie der Konfigurationsdatei `data/web/rc/config/config.inc.php` die
Option `$config['address_book_type'] = '';` hinzu.

Hinweis: RCMCardDAV verwendet zusätzliche Datenbank-Tabellen. Nach der Installation (oder Aktualisierung) von RCMCardDAV
ist es notwendig, sich in Roundcube neu anzumelden (melden Sie sich vorher ab, wenn Sie bereits eingeloggt sind), da die
Erzeugung der Datenbank-Tabellen bzw. Änderungen nur bei der Anmeldung in Roundcube durchgeführt werden.

### Übermittlung der Client-Netzwerkadresse an Dovecot

Normalerweise sieht der IMAP-Server Dovecot die Netzwerkadresse des php-fpm-Containers wenn Roundcube zu diesem
Verbindungen aufbaut. Durch Verwendung einer IMAP-Erweiterung und dem `dovecot_client_ip` Roundcube-Plugin ist
es möglich, dass Roundcube Dovecot die Client-Netzwerkadresse übermittelt, so dass in den Log-Dateien die
Client-Netzwerkadresse erscheint. Dies führt dazu, dass Login-Versuche an Roundcube in den Dovecot-Logs genauso wie
direkte Client-Verbindungen zu Dovecot aufgezeichnet werden, und fehlgeschlagene Login-Versuche an Roundcube
analog zu fehlgeschlagenen direkten IMAP-Logins durch den netfilter-Container oder andere ggf. verfügbare Mechanismen
zur Behandlung von Bruteforce-Attacken auf den IMAP-Server aufgegriffen werden und z. B. zu einer Blockierung des
Clients führen.

Hierzu muss das Roundcube-Plugin installiert werden:

=== "Integriert"

    ```bash
    docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer require --update-no-dev -o "foorschtbar/dovecot_client_ip:~2"
    ```

=== "Extern"

    ```yaml
    ROUNDCUBEMAIL_PLUGINS: archive, managesieve, acl, markasjunk, zipdownload, dovecot_client_ip
    ROUNDCUBEMAIL_COMPOSER_PLUGINS: "foorschtbar/dovecot_client_ip:~2"
    ```

Bearbeiten Sie die Datei `data/web/rc/config/config.inc.php` und fügen Sie den folgenden Inhalt ein:

```bash
cat <<EOCONFIG >>data/web/rc/config/config.inc.php
\$config['dovecot_client_ip_trusted_proxies'] = ['${IPV4_NETWORK}.0/24', '${IPV6_NETWORK}'];
EOCONFIG
```

Weiterhin müssen wir Dovecot konfigurieren, so dass der php-fpm-Container als Teil eines vertrauenswürdigen Netzwerks
betrachtet wird und somit die Client-Netzwerkadresse innerhalb einer IMAP-Sitzung überschreiben darf. Beachten Sie, dass
dies auch die Klartext-Authentifizierung für die aufgeführten Netzwerkbereiche erlaubt, so dass das explizite
Überschreiben von `disable_plaintext_auth` weiter oben in diesem Fall nicht notwendig ist.

```bash
cat  <<EOCONFIG >>data/conf/dovecot/extra.conf
login_trusted_networks = ${IPV4_NETWORK}.0/24 ${IPV6_NETWORK}
EOCONFIG

docker compose restart dovecot-mailcow
```

### Roundcube zur mailcow Apps-Liste hinzufügen

Optional können Sie Roundcubes Link zu der mailcow Apps Liste hinzufügen.
Um dies zu tun, öffnen oder erstellen Sie `data/web/inc/vars.local.inc.php` und stellen Sie sicher, dass es den
folgenden Konfigurationsblock beinhaltet:

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

### Administratoren ohne Passwort in Roundcube einloggen lassen

Installieren Sie zunächst das Plugin [dovecot_impersonate](https://github.com/corbosman/dovecot_impersonate/) und fügen Sie Roundcube als App hinzu (siehe oben).

=== "Integriert"

    ```bash
    docker exec -it -w /web/rc/plugins $(docker ps -f name=php-fpm-mailcow -q) git clone https://github.com/corbosman/dovecot_impersonate.git
    ```

=== "Extern"

    ```bash
    docker exec -it -w /var/www/html/plugins $(docker ps -f name=roundcube -q) git clone https://github.com/corbosman/dovecot_impersonate.git
    ```

Editieren Sie `data/web/rc/config/config.inc.php` und aktivieren Sie das dovecot_impersonate Plugin indem Sie es zum Array `$config['plugins']` 
oder zur `ROUNDCUBEMAIL_PLUGINS` Variable hinzufügen,
zum Beispiel:

=== "Integriert"

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

=== "Extern"

    ```yaml
    ROUNDCUBEMAIL_PLUGINS: archive, managesieve, acl, markasjunk, zipdownload, dovecot_impersonate
    ROUNDCUBEMAIL_COMPOSER_PLUGINS: #... Schon bereits durch git clone installiert
    ```

Editieren Sie `mailcow.conf` und fügen Sie folgendes hinzu:

```
# Erlaube Admins, sich in Roundcube als Email-Benutzer einzuloggen (ohne Passwort)
# Roundcube mit Plugin dovecot_impersonate muss zuerst installiert werden

ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=y
```

Editieren Sie `docker-compose.override.yml` und verfassen/erweitern Sie den Abschnitt für `php-fpm-mailcow`:

```yaml
services:
  php-fpm-mailcow:
    environment:
      - ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=${ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE:-n}
```

Bearbeiten Sie `data/web/js/site/mailbox.js` und den folgenden Code nach [`if (ALLOW_ADMIN_EMAIL_LOGIN) { ... }`](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/js/site/mailbox.js#L485-L487)

```js
if (ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE) {
	item.action +=
		'<a href="/rc-auth.php?login=' +
		encodeURIComponent(item.username) +
		'" class="login_as btn btn-sm btn-xs-half btn-primary" target="_blank"><i class="bi bi-envelope-fill"></i> Roundcube</a>'
}
```

Füge die folgende Zeile zum Array `$template_data` hinzu:

- `data/web/admin/mailbox.php` [`$template_data`](https://github.com/mailcow/mailcow-dockerized/blob/master/data/web/admin/mailbox.php#L43-L56)
- `data/web/domainadmin/mailbox.php` [`$template_data`](https://github.com/mailcow/mailcow-dockerized/blob/master/data/web/domainadmin/mailbox.php#L43-L56)

```php
  'allow_admin_email_login_roundcube' => (preg_match("/^([yY][eE][sS]|[yY])+$/", $_ENV["ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE"])) ? 'true' : 'false',
```

Bearbeiten Sie `data/web/templates/mailbox.twig` und fügen Sie diesen Code am Ende des [Javascript-Abschnitts](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/templates/mailbox.twig#L49-L57) ein:

```js
  var ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE = {{ allow_admin_email_login_roundcube }};
```

Kopieren Sie den Inhalt der folgenden Dateien aus diesem [Snippet](https://gitlab.com/-/snippets/2038244):

- `data/web/inc/lib/RoundcubeAutoLogin.php`
- `data/web/rc-auth.php`

## Abschluss der Installation

Starten Sie schließlich mailcow neu

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

## Aktualisierung von Roundcube

=== "Integriert"

    Ein Upgrade von Roundcube ist recht einfach: Gehen Sie auf die
    [GitHub releases](https://github.com/roundcube/roundcubemail/releases) Seite für Roundcube und holen Sie sich den Link
    für die "complete.tar.gz" Datei für die gewünschte Version. Dann folgen Sie den untenstehenden Befehlen und ändern Sie
    die URL und den Namen des Roundcube-Ordners, falls nötig.

    ```bash
    # Starten Sie eine Bash-Sitzung des mailcow PHP-Containers
    docker exec -it mailcowdockerized-php-fpm-mailcow-1 bash

    # Installieren Sie die erforderliche Upgrade-Abhängigkeit, dann aktualisieren Sie Roundcube auf die gewünschte Version
    apk add rsync
    cd /tmp
    wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.11/roundcubemail-1.6.11-complete.tar.gz | tar xfvz -
    cd roundcubemail-1.6.11
    bin/installto.sh /web/rc

    # Geben Sie 'Y' ein und drücken Sie die Eingabetaste, um Ihre Installation von Roundcube zu aktualisieren.
    # Geben Sie 'N' ein, wenn folgender Dialog erscheint: "Do you want me to fix your local configuration".

    # Sollte im Output eine Notice kommen "NOTICE: Update dependencies by running php composer.phar update --no-dev" führen
    Sie composer aus:
    cd /web/rc
    composer update --no-dev -o
    # Auf die Frage "Do you trust "roundcube/plugin-installer" to execute code and wish to enable it now? (writes "allow-plugins" to composer.json) [y,n,d,?] " bitte mit y antworten.

    # Entfernen Sie übrig gebliebene Dateien
    rm -rf /tmp/roundcube*

    # Falls Sie von Version 1.5 auf 1.6 updaten, dann führen Sie folgende Befehle aus, um die Konfigurationsdatei anzupassen:`
    sed -i "s/\$config\['default_host'\].*$/\$config\['imap_host'\]\ =\ 'dovecot:143'\;/" /web/rc/config/config.inc.php
    sed -i "/\$config\['default_port'\].*$/d" /web/rc/config/config.inc.php
    sed -i "s/\$config\['smtp_server'\].*$/\$config\['smtp_host'\]\ =\ 'postfix:588'\;/" /web/rc/config/config.inc.php
    sed -i "/\$config\['smtp_port'\].*$/d" /web/rc/config/config.inc.php
    sed -i "s/\$config\['managesieve_host'\].*$/\$config\['managesieve_host'\]\ =\ 'dovecot:4190'\;/" /web/rc/config/config.inc.php
    sed -i "/\$config\['managesieve_port'\].*$/d" /web/rc/config/config.inc.php
    ```

=== "Extern"
    Ein Upgrade von Roundcube ist in der Externen Installation ziemlich einfach, es muss lediglich der Version-Tag heraufgestuft werden:

    ```yaml
    image: roundcube/roundcubemail:1.6.11-apache # 1.6.11 -> 1.6.X (in der Zukunft: 1.7.X)
    ```

    Nach einem Neustart aktualisiert sich Roundcube automatisch, was einen reibungslosen Prozess ermöglich sollte.

### Aktualisierung von composer-Plugins

=== "Integriert"

    Um Roundcube-Plugins und -Abhängigkeiten zu aktualisieren, die mit composer installiert wurden (z. B.
    RCMCardDAV-Plugin), führen Sie einfach composer im Container aus:

    ```bash
    docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer update --no-dev -o
    ```

=== "Extern"

    Um Roundcube-Plugins zu aktualisieren müssen lediglich die Version-Tags zur neusten Version erhöht werden:
    
    ```yaml
          ROUNDCUBEMAIL_COMPOSER_PLUGINS: "roundcube/carddav:~4" # zu v5 erhöhen
    ```

### Aktualisierung des MIME-Typ-Verzeichnisses

Um das MIME-Typ-Verzeichnis zu aktualisieren, laden Sie dieses erneut mit dem Kommando aus den
[Installations-Anweisungen](#installation-des-mime-typ-verzeichnisses) herunter.

## Deinstallation von Roundcube

Für die Deinstallation wird ebenfalls angenommen, dass die Kommandos im mailcow-Installationsverzeichnis ausgeführt
werden und dass `mailcow.conf` in die Shell geladen wurde, siehe Abschnitt [Vorbereitung](#vorbereitung) oben.

### Entfernen des Web-Verzeichnisses

Dies entfernt die Roundcube-Installation mit allen Plugins und Abhängigkeiten die Sie ggf. installiert haben,
einschließlich solcher, die mit composer installiert wurden.

Hinweis: Dies entfernt auch alle angepassten Konfigurationen die Sie ggf. in Roundcube durchgeführt haben. Sollten Sie
diese erhalten wollen, verschieben Sie das Verzeichnis an einen anderen Ort statt es zu entfernen.

=== "Integriert"

    ```bash
    rm -r data/web/rc
    ```

=== "Extern"

    Den Roundcube Container anhalten:

    === "docker compose (Plugin)"

        ``` bash
        docker compose down
        ```

    === "docker-compose (Standalone)"

        ``` bash
        docker-compose down
        ```

    Anschließend `data/web/rc` oder `data/rc` je nach Mounts löschen.

### Entfernen der Datenbank

Hinweis: Dies löscht alle Daten, die Roundcube abgespeichert hat. Wenn Sie diese erhalten möchten, können Sie
`mysqldump` ausführen, bevor Sie die Datenbank löschen, oder die Datenbank einfach nicht löschen.

```bash
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "DROP USER 'roundcube'@'%';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "DROP DATABASE roundcubemail;"
```

### Entfernen der Konfigurationsanpassungen für mailcow

Um die Dateien zu ermitteln, lesen Sie bitte die Installationsanweisungen und machen Sie die Schritte, die Sie dort
zuvor durchgeführt haben, rückgängig.

## Migration von einer älteren mailcow-Roundcube-Installation

Ältere Versionen dieser Anleitung verwendeten die mailcow-Datenbank auch für Roundcube, mit einem konfigurierten Präfix
`mailcow_rc1` für alle Roundcube-Tabellen.

Zur Migration wird ebenfalls angenommen, dass alle Kommandos im mailcow-Installationsverzeichnis ausgeführt werden und
`mailcow.conf` in die Shell geladen wurde, siehe [Vorbereitung](#vorbereitung) oben. Dies Kommandos der verschiedenen
Schritte bauen aufeinander auf und müssen innerhalb derselben Shell ausgeführt werden. Insbesondere setzen einige
Schritte Shell-Variablen (besonders die `DBROUNDCUBE`-Variable mit dem Datenbank-Passwort für den
roundcube-Datenbankbenutzer), die in späteren Schritten verwendet werden.

### Anlegen eines neuen roundcube-Datenbankbenutzers und der Datenbank

Folgen Sie den [Anweisungen oben](#anlegen-der-roundcube-datenbank) um den roundcube-Datenbankbenutzer und die getrennte
Datenbank anzulegen.

### Migration der Roundcube-Daten aus der mailcow-Datenbank

Bevor wir mit der Migration starten, deaktivieren wir Roundcube, um weitere Änderungen an dessen Datenbank-Tabellen zu
vermeiden.

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location ^~ /rc/ {
  return 503;
}
EOCONFIG
docker compose exec nginx-mailcow nginx -s reload
```

Nun kopieren wir die Roundcube-Daten in die neue Datenbank. Wir entfernen das Datenbank-Tabellen-Präfix in diesem
Schritt, welches Sie ggf. anpassen müssen, wenn Sie ein anderes Präfix als `mailcow_rc1` verwendet haben. Es ist auch
möglich, das Präfix beizubehalten (in diesem Fall behalten Sie auch die zugehörige Roundcube-Einstellung `db_prefix`
bei). Ändern Sie dann die Datenbank-Fremdschlüssel.

```bash
RCTABLES=$(docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -sN mailcow -e "show tables like 'mailcow_rc1%';" | tr '\n\r' ' ')
docker exec $(docker ps -f name=mysql-mailcow -q) /bin/bash -c "mysqldump -uroot -p${DBROOT} mailcow $RCTABLES | sed 's/mailcow_rc1//' | mysql -uroot -p${DBROOT} roundcubemail"
FOREIGNKEYS=$(docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -sN mailcow -e "SELECT CONCAT('ALTER TABLE \`', TABLE_NAME, '\` ', 'DROP FOREIGN KEY \`', CONSTRAINT_NAME, '\`;', 'ALTER TABLE \`', TABLE_NAME, '\` ', 'ADD FOREIGN KEY \`', CONSTRAINT_NAME, '\` (', COLUMN_NAME, ') ', 'REFERENCES \`', REPLACE(REFERENCED_TABLE_NAME, 'mailcow_rc1', ''), '\` (', REFERENCED_COLUMN_NAME, ');') FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_SCHEMA = 'roundcubemail' AND REFERENCED_TABLE_NAME IS NOT NULL;")
docker exec $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} roundcubemail -e "$FOREIGNKEYS"
```

### Aktualisierung der Roundcube-Konfiguration

Führen Sie folgende Kommandos aus, um die nicht mehr notwendige `db_prefix` Option zu entfernen. Wir aktivieren außerdem
das Logging in Roundcube, indem wir die Einstellungen `log_dir` und `temp_dir` entfernen, welche Teil der alten
Anweisungen waren.

```bash
sed -i "/\$config\['db_prefix'\].*$/d" data/web/rc/config/config.inc.php
sed -i "/\$config\['log_dir'\].*$/d" data/web/rc/config/config.inc.php
sed -i "/\$config\['temp_dir'\].*$/d" data/web/rc/config/config.inc.php
```

Wir müssen die nginx-Konfiguration anpassen, so dass nicht-öffentliche Verzeichnisse von Roundcube nicht exponiert
werden, insbesondere die Verzeichnisse, welche Log-Dateien und temporäre Dateien enthalten:

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location /rc/ {
  alias /web/rc/public_html/;
}
EOCONFIG
```

Wir können auch die `cipher_method`-Einstellung auf eine sicherere Einstellung ändern, aber beachten Sie, dass mit der
alten Methode verschlüsselte Daten danach nicht mehr entschlüsselt werden können. Dies betrifft insbesondere
CardDAV-Passwörter, sofern Sie RCMCardDAV verwenden und Ihre Nutzer benutzerdefinierte Adressbücher hinzugefügt haben
(die Admin-Voreinstellungen für die SOGo-Adressbücher werden automatisch beim nächsten Login für den jeweiligen Nutzer
korrigiert). Wenn Sie die `cipher_method` ändern wollen, führen Sie folgendes Kommando aus:

```bash
cat <<EOCONFIG >>data/web/rc/config/config.inc.php
\$config['cipher_method'] = 'chacha20-poly1305';
EOCONFIG
```

### Umstellung des RCMCardDAV-Plugins auf die Installation mittels composer

Dieser Schritt ist optional, aber er gleicht Ihre Installation an die aktuelle Fassung der Anweisungen an und ermöglicht
die Aktualisierung von RCMCardDAV mittels composer. Dies wird einfach dadurch erreicht, dass das carddav-Plugin aus dem
Installationsverzeichnis gelöscht und entsprechend der [Anweisungen oben](#carddav-adressbucher-in-roundcube-einbinden)
installiert wird, einschließlich der Erstellung einer neuen RCMCardDAV v5-Konfiguration. Falls Sie das RCMCardDAV
angepasst haben, sollten Sie dieses sichern, bevor Sie das Plugin löschen, und Ihre Anpassungen später in die neue
Konfigurationsdatei übernehmen.

Um das carddav-Plugin zu löschen, führen Sie folgendes Kommando aus, danach befolgen Sie zur Neuinstallation die
[Anweisungen oben](#carddav-adressbucher-in-roundcube-einbinden):

```bash
rm -r data/web/rc/plugins/carddav
```

### Umschalten von Roundcube auf die neue Datenbank

Zunächst passen wir die Roundcube-Konfiguration an, so dass die neue Datenbank verwendet wird.

```bash
sed -i "/\$config\['db_dsnw'\].*$/d" data/web/rc/config/config.inc.php
cat <<EOCONFIG >>data/web/rc/config/config.inc.php
\$config['db_dsnw'] = 'mysql://roundcube:${DBROUNDCUBE}@mysql/roundcubemail';
EOCONFIG
```

### Roundcube Web-Zugriff reaktivieren

Führen Sie chown und chmod auf den sensitiven Roundcube-Verzeichnissen, welche in [Vorbereitung](#vorbereitung)
aufgeführt sind aus, um sicherzustellen, dass der nginx-Webserver nicht auf Dateien zugreifen darf, die er nicht
ausliefern soll.

Dann reaktivieren Sie den Web-Zugriff für Roundcube, indem Sie die temporäre Roundcube-Konfigurations-Erweiterung für
nginx durch die [oben](#webserver-konfiguration) beschriebene ersetzen, und laden anschließend die nginx-Konfiguration
neu:

```bash
docker compose exec nginx-mailcow nginx -s reload
```

### Andere Anpassungen

Sie müssen auch die Konfiguration des Roundcube password-Plugins entsprechend dieser Anweisungen anpassen, sofern Sie
diese Funktionalität aktiviert haben, da die alten Anweisungen das Passwort direkt in der mailcow-Datenbank änderten,
wohingegen diese Fassung der Anweisungen die mailcow-API zur Passwort-Änderung verwendet.

Bezüglich weiterer Anpassungen und Neuerungen (z. B. roundcube-dovecot_client_ip Plugin) können Sie die aktuellen
Anweisungen durchgehen und Ihre Konfiguration entsprechend anpassen bzw. die genannten Installationsschritte für neue
Funktionalitäten ausführen.

Insbesondere beachten Sie folgende Abschnitte:

- [Ofelia-Job für Roundcube-Aufräumtätigkeiten](#ofelia-job-fur-roundcube-aufraumtatigkeiten)
- [Ermöglichen der Klartext-Authentifizierung für den php-fpm-Container ohne die Verwendung von TLS](#ermoglichen-der-klartext-authentifizierung-fur-den-php-fpm-container-ohne-die-verwendung-von-tls)
- [Übermittlung der Client-Netzwerkadresse an Dovecot](#ubermittlung-der-client-netzwerkadresse-an-dovecot)

### Entfernen der Roundcube-Tabellen aus der mailcow-Datenbank

Nachdem Sie sichergestellt haben, dass die Migration erfolgreich durchgeführt wurde und Roundcube mit der getrennten
Datenbank funktioniert, können Sie die Roundcube-Tabellen aus der mailcow-Datenbank mit dem folgenden Kommando
entfernen:

```bash
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -sN mailcow -e "SET SESSION foreign_key_checks = 0; DROP TABLE IF EXISTS $(echo $RCTABLES | sed -e 's/ \+/,/g');"
```


