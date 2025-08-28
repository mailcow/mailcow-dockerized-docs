# Roundcube installieren

!!! note "Hinweis"
    Sofern nicht anders angegeben, wird davon ausgegangen, dass alle angegebenen Befehle im mailcow-Installationsverzeichnis ausgeführt werden, d. h. im Verzeichnis, das `mailcow.conf` usw. enthält. Bitte führen Sie die Befehle nicht blind aus, sondern verstehen Sie, was sie tun. Keiner der Befehle sollte einen Fehler erzeugen. Wenn Sie auf einen Fehler stoßen, beheben Sie diesen, bevor Sie mit den nachfolgenden Befehlen fortfahren.

## Integrierte Installation

### Hinweis zur Nutzung von Composer

Diese Anleitung verwendet Composer, um Roundcube-Abhängigkeiten zu aktualisieren oder Roundcube-Plugins zu installieren/aktualisieren.

Das Composer-Plugin `roundcube-plugin-installer` hat ein [Designproblem](https://github.com/roundcube/plugin-installer/issues/38), das zu Composer-Fehlern führen kann, wenn Pakete während der Composer-Ausführung aktualisiert oder deinstalliert werden.

Die Fehlermeldung weist in der Regel darauf hin, dass ein `require` in `autoload_real.php` fehlgeschlagen ist, weil eine Datei nicht geöffnet werden konnte. Beispiel:

```
In autoload_real.php line 43:
  require(/web/rc/vendor/composer/../guzzlehttp/promises/src/functions_include.php): Failed to open stream: No such file or directory
```

Leider treten diese Fehler recht häufig auf, können jedoch umgangen werden, indem der Autoloader aktualisiert und der fehlgeschlagene Befehl erneut ausgeführt wird:

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer dump-autoload -o
# Führen Sie nun den fehlgeschlagenen Befehl erneut aus
```

### Vorbereitung

Zuerst laden wir `mailcow.conf`, um Zugriff auf die mailcow-Konfigurationseinstellungen für die folgenden Befehle zu erhalten.

```bash
source mailcow.conf
```

Laden Sie Roundcube 1.6.x (überprüfen Sie die neueste Version und passen Sie die URL an) in das Webverzeichnis herunter und extrahieren Sie es (hier `rc/`):

```bash
mkdir -m 755 data/web/rc
wget -O - https://github.com/roundcube/roundcubemail/releases/download/1.6.11/roundcubemail-1.6.11-complete.tar.gz | tar -xvz --no-same-owner -C data/web/rc --strip-components=1 -f -
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown www-data:www-data /web/rc/logs /web/rc/temp
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chmod 750 /web/rc/logs /web/rc/temp /web/rc/config
```

### Optional: Rechtschreibprüfung

Falls Sie Rechtschreibprüfungsfunktionen benötigen, erstellen Sie eine Datei `data/hooks/phpfpm/aspell.sh` mit folgendem Inhalt und setzen Sie die Berechtigung mit `chmod +x data/hooks/phpfpm/aspell.sh`. Dies installiert eine lokale Rechtschreibprüfung. Beachten Sie, dass die meisten modernen Webbrowser eine integrierte Rechtschreibprüfung haben, sodass Sie dies möglicherweise nicht benötigen.

```bash
#!/bin/bash
apk update
apk add aspell-en # oder eine andere Sprache
```

### MIME-Typ-Zuordnungen installieren

Laden Sie die Datei `mime.types` herunter, da sie nicht im php-fpm-Container enthalten ist.

```bash
wget -O data/web/rc/config/mime.types http://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types
```

### Roundcube-Datenbank erstellen

Erstellen Sie eine Datenbank für Roundcube im mailcow-MySQL-Container. Dies erstellt einen neuen `roundcube`-Datenbankbenutzer mit einem zufälligen Passwort, das in der Shell ausgegeben und in einer Shell-Variable für spätere Befehle gespeichert wird. Beachten Sie, dass Sie, wenn Sie den Prozess unterbrechen und in einer neuen Shell fortfahren, die Shell-Variable `DBROUNDCUBE` manuell auf das Passwort setzen müssen, das von den folgenden Befehlen ausgegeben wird.

```bash
DBROUNDCUBE=$(LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28)
echo Datenbankpasswort für Benutzer roundcube ist $DBROUNDCUBE
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE roundcubemail CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'roundcube'@'%' IDENTIFIED BY '${DBROUNDCUBE}';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON roundcubemail.* TO 'roundcube'@'%';"
```

### Roundcube-Konfiguration

Erstellen Sie eine Datei `data/web/rc/config/config.inc.php` mit folgendem Inhalt.

- Die Option `des_key` wird auf einen zufälligen Wert gesetzt. Sie wird verwendet, um Ihr IMAP-Passwort vorübergehend zu speichern.
- Die Plugin-Liste kann nach Ihren Vorlieben angepasst werden. Ich habe eine Reihe von Standard-Plugins hinzugefügt, die ich für allgemein nützlich halte und die gut mit mailcow zusammenarbeiten:
  - Das `archive`-Plugin fügt eine Archiv-Schaltfläche hinzu, die ausgewählte Nachrichten in einen benutzerkonfigurierbaren Archivordner verschiebt.
  - Das `managesieve`-Plugin bietet eine benutzerfreundliche Oberfläche zur Verwaltung von serverseitigen Mailfiltern und Abwesenheitsnotizen.
  - Das `acl`-Plugin ermöglicht die Verwaltung von Zugriffssteuerungslisten für IMAP-Ordner, einschließlich der Möglichkeit, IMAP-Ordner für andere Benutzer freizugeben.
  - Das `markasjunk`-Plugin fügt Schaltflächen hinzu, um ausgewählte Nachrichten als Spam zu markieren (oder Nachrichten im Spam-Ordner als Nicht-Spam zu markieren) und verschiebt sie in den Spam-Ordner oder zurück in den Posteingang. Die in mailcow enthaltenen Sieve-Filter sorgen dafür, dass diese Aktion ein Lernen als Spam/Ham in rspamd auslöst, sodass keine weitere Konfiguration des Plugins erforderlich ist.
  - Das `zipdownload`-Plugin ermöglicht das Herunterladen mehrerer Nachrichtenanhänge oder Nachrichten als ZIP-Datei.
- Wenn Sie die Rechtschreibprüfung im obigen Schritt nicht installiert haben, entfernen Sie den Parameter `spellcheck_engine`.

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
// Aktiviert eine separate Verwaltungsoberfläche für Abwesenheitsnotizen (Out-of-Office)
// 0 - kein separater Abschnitt (Standard); 1 - Abschnitt "Abwesenheit" hinzufügen; 2 - Abschnitt "Abwesenheit" hinzufügen, aber Abschnitt "Filter" ausblenden
\$config['managesieve_vacation'] = 1;
EOCONFIG

docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chown root:www-data /web/rc/config/config.inc.php
docker exec -it $(docker ps -f name=php-fpm-mailcow -q) chmod 640 /web/rc/config/config.inc.php
```

### Datenbank initialisieren

Öffnen Sie Ihren Browser und navigieren Sie zu `https://IHREDOMAIN/rc/installer`. Überprüfen Sie, dass die Website keine "NOT OK"-Ergebnisse bei den Prüfungen anzeigt. Einige "NOT AVAILABLE"-Ergebnisse sind zu erwarten, insbesondere bei verschiedenen Datenbankerweiterungen, von denen wir nur MySQL benötigen. 

Initialisieren Sie die Datenbank und verlassen Sie den Installer. Es ist nicht notwendig, die Konfiguration mit der heruntergeladenen zu aktualisieren, es sei denn, Sie haben im Installer Einstellungen vorgenommen, die Sie übernehmen möchten.

### Webserver-Konfiguration

Das Roundcube-Verzeichnis enthält einige Bereiche, die nicht für Webbenutzer zugänglich sein sollen. Wir fügen eine Konfigurationserweiterung für nginx hinzu, um nur das öffentliche Verzeichnis von Roundcube freizugeben.

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location /rc/ {
  alias /web/rc/public_html/;
}
EOCONFIG
```

### Installer deaktivieren und entfernen

Löschen Sie das Verzeichnis `data/web/rc/installer` nach einer erfolgreichen Installation und setzen Sie die Option `enable_installer` in `data/web/rc/config/config.inc.php` auf `false`:

```bash
rm -r data/web/rc/installer
sed -i -e "s/\(\$config\['enable_installer'\].* = \)true/\1false/" data/web/rc/config/config.inc.php
```

### Roundcube-Abhängigkeiten aktualisieren

Dieser Schritt ist nicht zwingend erforderlich, aber zumindest zum Zeitpunkt der Erstellung dieses Dokuments enthielten die mit Roundcube gelieferten Abhängigkeiten Versionen mit Sicherheitslücken. Daher könnte es eine gute Idee sein, die Abhängigkeiten auf die neuesten Versionen zu aktualisieren. Aus demselben Grund könnte es sinnvoll sein, den Composer-Update-Befehl gelegentlich auszuführen.

```bash
cp -n data/web/rc/composer.json-dist data/web/rc/composer.json
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer update --no-dev -o
```

Sie können auch `composer audit` verwenden, um nach gemeldeten Sicherheitsproblemen mit den installierten Composer-Paketen zu suchen:

```bash
docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer audit
```

### Erlauben unverschlüsselter Authentifizierung in Dovecot

Wir müssen die Klartext-Authentifizierung in Dovecot über eine unverschlüsselte Verbindung (innerhalb des Container-Netzwerks) zulassen, was standardmäßig in der mailcow-Installation nur für den SOGo-Container möglich ist. Danach starten wir den Dovecot-Container neu, damit die Änderung wirksam wird.

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

### Ofelia-Job für Roundcube-Housekeeping

Roundcube muss gelegentlich veraltete Informationen aus der Datenbank bereinigen. Dafür erstellen wir einen Ofelia-Job, der das Roundcube-Skript `cleandb.sh` ausführt.

Fügen Sie dazu Folgendes in die Datei `docker-compose.override.yml` ein (falls Sie bereits Anpassungen für den php-fpm-Container vorgenommen haben, fügen Sie die Labels in den bestehenden Abschnitt ein):

```yaml
services:
  php-fpm-mailcow:
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.roundcube_cleandb.schedule: "@every 168h"
      ofelia.job-exec.roundcube_cleandb.user: "www-data"
      ofelia.job-exec.roundcube_cleandb.command: '/bin/bash -c "[ -f /web/rc/bin/cleandb.sh ] && /web/rc/bin/cleandb.sh"'
```
## Standalone-Installation

Um Roundcube in einem eigenen Docker-Container zu installieren, fügen Sie Folgendes in Ihre `docker-compose-override.yaml`-Datei ein:

```yaml
services:
  roundcube-db:
    image: mariadb:10.11
    volumes:
      - roundcube-db:/var/lib/mysql/
    environment:
      TZ: ${TZ}
      MYSQL_ROOT_PASSWORD: ${DBROUNDCUBEROOT}
      MYSQL_DATABASE: roundcubemail
      MYSQL_USER: roundcube
      MYSQL_PASSWORD: ${DBROUNDCUBE}
    restart: unless-stopped
    networks:
      mailcow-network:
        aliases:
          - roundcube-db

  roundcube:
    image: roundcube/roundcubemail:1.6.11-apache # Neueste Version siehe https://hub.docker.com/r/roundcube/roundcubemail/tags?name=apache
    environment:
      IPV4_NETWORK: ${IPV4_NETWORK:-172.22.1}
      IPV6_NETWORK: ${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64}
      ROUNDCUBEMAIL_DB_TYPE: mysql
      ROUNDCUBEMAIL_DB_HOST: roundcube-db
      ROUNDCUBEMAIL_DB_USER: roundcube
      ROUNDCUBEMAIL_DB_PASSWORD: ${DBROUNDCUBE}
      ROUNDCUBEMAIL_DB_NAME: roundcubemail
      ROUNDCUBEMAIL_DEFAULT_HOST: dovecot
      ROUNDCUBEMAIL_SMTP_SERVER: postfix
      ROUNDCUBEMAIL_SMTP_PORT: 588
    volumes:
      # == Dokumentationskompatibilität ==
      # Diese Mounts sind so eingerichtet, dass sie mit denen der integrierten Installation übereinstimmen.
      # Es wird jedoch empfohlen, diese nicht innerhalb von web/rc zu mounten, da dieses Verzeichnis auch in den php-fpm-Container eingebunden wird.
      # - ./data/web/rc:/var/www/html
      # - ./data/web/rc/persistent-config:/var/roundcube/config

      # Fortgeschritten (weniger kompatibel mit der Dokumentation, aber sicherer)
      - ./data/rc/main:/var/www/html
      # Eigene Konfigurationen über Umgebungsvariablen hinaus hier erstellen
      - ./data/rc/config:/var/roundcube/config
    depends_on:
      - roundcube-db
      - dovecot-mailcow
    restart: unless-stopped
    networks:
      mailcow-network:
        aliases:
          - roundcube

volumes:
  roundcube-db:
```

### Webserver-Konfiguration

Das Roundcube-Verzeichnis enthält einige Bereiche, die nicht für Webbenutzer zugänglich sein sollen. Wir fügen eine Konfigurationserweiterung für nginx hinzu, um nur das öffentliche Verzeichnis von Roundcube freizugeben.

```bash
cat <<EOCONFIG >data/conf/nginx/site.roundcube.custom
location /rc/ {
    proxy_pass http://roundcube:80/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
}
EOCONFIG
```

### Roundcube-Passwörter erstellen

Möglicherweise müssen Sie die Umgebungsvariablen laden.

```bash
source mailcow.conf
```

Erstellen Sie ein Passwort für den separaten Roundcube-MySQL-Container. Dies erstellt einen neuen `roundcube`-Datenbankbenutzer mit einem zufälligen Passwort, das in der Shell ausgegeben wird.

Generieren Sie ein Passwort für die Roundcube-Datenbank mit dem folgenden Befehl. Führen Sie dies sowohl für `DBROUNDCUBEROOT` als auch für `DBROUNDCUBE` aus. Denken Sie daran, diese auch in Ihre `mailcow.conf`-Datei einzutragen.

```bash
LC_ALL=C </dev/urandom tr -dc A-Za-z0-9 2> /dev/null | head -c 28
```

### Erlauben unverschlüsselter Authentifizierung in Dovecot

Wir müssen die Klartext-Authentifizierung in Dovecot über eine unverschlüsselte Verbindung (innerhalb des Container-Netzwerks) zulassen, was standardmäßig in der mailcow-Installation nur für den SOGo-Container möglich ist. Danach starten wir den Dovecot-Container neu, damit die Änderung wirksam wird.

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

### Roundcube starten

Nach Abschluss aller oben genannten Schritte können Sie den Roundcube-Container starten.

=== "docker compose (Plugin)"

    ```bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose down
    docker-compose up -d
    ```

### Eigene Konfigurationsdateien

Roundcube bietet einige Umgebungsvariablen für die Konfiguration, aber nicht für alle. Für weitere Konfigurationen können Sie `*.inc.php`-Dateien in Ihrem Konfigurationsverzeichnis erstellen.

Anstatt sich auf Umgebungsvariablen zu verlassen, können Sie Konfigurationsdateien erstellen. Sie könnten beispielsweise die `config.inc.php`-Datei aus der integrierten Installation in der Standalone-Installation verwenden.

**Beispiel**

Die folgende Konfiguration enthält Einstellungen, die in der integrierten Installation verwendet werden, aber nicht in den Umgebungsvariablen angegeben werden können:

```bash
cat <<EOCONFIG >rc/config/config.inc.php
<?php
\$config['support_url'] = '';
\$config['product_name'] = 'Roundcube Webmail';
\$config['cipher_method'] = 'chacha20-poly1305';
\$config['plugins'] = [
  'archive',
  'managesieve',
  'acl',
  'markasjunk',
  'zipdownload',
];

\$config['managesieve_host'] = 'dovecot:4190';
// Aktiviert eine separate Verwaltungsoberfläche für Abwesenheitsnotizen (Out-of-Office)
// 0 - kein separater Abschnitt (Standard); 1 - Abschnitt "Abwesenheit" hinzufügen; 2 - Abschnitt "Abwesenheit" hinzufügen, aber Abschnitt "Filter" ausblenden
\$config['managesieve_vacation'] = 1;
EOCONFIG
```

### Hinweise zur Standalone-Installation

!!! Hinweis
    Für den Rest dieser Dokumentation werden Sie aufgefordert, Dateien in `data/web/rc/config` zu ändern. Verwenden Sie stattdessen `data/web/rc/persistent-config` oder `data/rc/config` (fortgeschritten). Dies liegt daran, dass Roundcube Konfigurationen in `rc/main/config/` oder `web/rc/config/` basierend auf Konfigurationen in `persistent-config/` / `data/rc/config/` automatisch generiert.

Wenn Sie sich für die _fortgeschrittene_ Methode entschieden haben, beachten Sie, dass sich Ordner wie `plugins/` in `data/rc/main` befinden.

## Optionale Zusatzfunktionen

### Passwortänderungsfunktion in Roundcube aktivieren

Das Ändern des mailcow-Passworts über die Roundcube-Benutzeroberfläche wird über das Passwort-Plugin unterstützt. Wir konfigurieren es so, dass die mailcow-API verwendet wird, um das Passwort zu aktualisieren. Dazu muss die API zuerst aktiviert und der API-Schlüssel (Lese-/Schreibzugriff erforderlich) abgerufen werden. Die API kann in der mailcow-Admin-Oberfläche aktiviert werden, wo auch der API-Schlüssel zu finden ist.

Öffnen Sie `rc/config/config.inc.php` und aktivieren Sie das Passwort-Plugin, indem Sie es zum `$config['plugins']`-Array hinzufügen, zum Beispiel:

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

Konfigurieren Sie das Passwort-Plugin (passen Sie **\*\*API_KEY\*\*** an Ihren mailcow-Lese-/Schreib-API-Schlüssel an):

```bash
cat <<EOCONFIG >data/web/rc/plugins/password/config.inc.php
<?php
\$config['password_driver'] = 'mailcow';
\$config['password_confirm_current'] = true;
\$config['password_mailcow_api_host'] = 'http://nginx';
\$config['password_mailcow_api_token'] = '**API_KEY**';
EOCONFIG
```

Hinweis: Wenn Sie die mailcow-nginx-Konfiguration geändert haben, um HTTP-Anfragen auf HTTPS umzuleiten (z. B. wie [hier](https://docs.mailcow.email/manual-guides/u_e-80_to_443/) beschrieben), wird die direkte Kommunikation mit dem nginx-Container über HTTP nicht funktionieren, da nginx kein Hostname ist, der im Zertifikat enthalten ist. In solchen Fällen setzen Sie `password_mailcow_api_host` in der obigen Konfiguration auf die öffentliche URI:

```bash
cat <<EOCONFIG >data/web/rc/plugins/password/config.inc.php
<?php
\$config['password_driver'] = 'mailcow';
\$config['password_confirm_current'] = true;
\$config['password_mailcow_api_host'] = 'https://${MAILCOW_HOSTNAME}';
\$config['password_mailcow_api_token'] = '**API_KEY**';
EOCONFIG
```

### CardDAV-Adressbücher in Roundcube integrieren

Installieren Sie die neueste v5-Version (die unten stehende Konfiguration ist mit v5-Releases kompatibel) mit Composer. Antworten Sie mit `Y`, wenn Sie gefragt werden, ob Sie das Plugin aktivieren möchten.

=== "Integriert"

    ```bash
    docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer require --update-no-dev -o "roundcube/carddav:~5"
    ```

=== "Standalone"

    ```bash
    docker exec -it $(docker ps -f name=roundcube -q) composer require --update-no-dev -o "roundcube/carddav:~5"
    ```

Bearbeiten Sie die Datei `data/web/rc/plugins/carddav/config.inc.php` und fügen Sie den folgenden Inhalt ein:

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

RCMCardDAV fügt beim Login alle Adressbücher des Benutzers hinzu, einschließlich **abonnierter** Adressbücher, die von anderen Benutzern für den Benutzer freigegeben wurden.

Wenn Sie die Standard-Adressbücher (gespeichert in der Roundcube-Datenbank) entfernen möchten, sodass nur die CardDAV-Adressbücher zugänglich sind, fügen Sie `$config['address_book_type'] = '';` zur Konfigurationsdatei `data/web/rc/config/config.inc.php` hinzu.

Hinweis: RCMCardDAV verwendet zusätzliche Datenbanktabellen. Nach der Installation (oder Aktualisierung) von RCMCardDAV ist es erforderlich, sich bei Roundcube anzumelden (melden Sie sich ab, falls Sie bereits angemeldet sind), da die Erstellung/Änderung der Datenbanktabellen nur während des Logins bei Roundcube durchgeführt wird.

### Weiterleitung der Client-Netzwerkadresse an Dovecot

Normalerweise sieht der IMAP-Server Dovecot die Netzwerkadresse des php-fpm-Containers, wenn Roundcube mit dem IMAP-Server interagiert. Mithilfe einer IMAP-Erweiterung und des `dovecot_client_ip`-Roundcube-Plugins ist es möglich, dass Roundcube Dovecot die Client-IP mitteilt, sodass diese auch in den Logs als Remote-IP angezeigt wird. Dadurch erscheinen Login-Versuche in den Dovecot-Logs wie direkte Client-Verbindungen zu Dovecot, und fehlgeschlagene Logins bei Roundcube werden genauso behandelt wie fehlgeschlagene direkte IMAP-Logins, was zur Blockierung des Clients durch den Netfilter-Container oder andere Mechanismen führen kann, die bereits zur Abwehr von Brute-Force-Angriffen auf den IMAP-Server eingerichtet sind.

Dafür muss das Roundcube-Plugin installiert werden.

=== "Integriert"

    ```bash
    docker exec -it -w /web/rc $(docker ps -f name=php-fpm-mailcow -q) composer require --update-no-dev -o "foorschtbar/dovecot_client_ip:~2"
    ```

=== "Standalone"

    ```bash
    docker exec -it $(docker ps -f name=roundcube -q) composer require --update-no-dev -o "foorschtbar/dovecot_client_ip:~2"
    ```

Bearbeiten Sie die Datei `rc/config/config.inc.php` und fügen Sie den folgenden Inhalt ein:

```bash
cat <<EOCONFIG >>rc/config/config.inc.php
\$config['dovecot_client_ip_trusted_proxies'] = ['${IPV4_NETWORK}.0/24', '${IPV6_NETWORK}'];
EOCONFIG
```

Darüber hinaus müssen wir Dovecot so konfigurieren, dass der php-fpm-Container als Teil eines vertrauenswürdigen Netzwerks behandelt wird, damit er die Client-IP in der IMAP-Sitzung überschreiben darf. Beachten Sie, dass dies auch die Klartext-Authentifizierung für die aufgeführten Netzwerkbereiche aktiviert, sodass die oben explizit vorgenommenen Überschreibungen von `disable_plaintext_auth` nicht erforderlich sind, wenn dies verwendet wird.

```bash
cat  <<EOCONFIG >>data/conf/dovecot/extra.conf
login_trusted_networks = ${IPV4_NETWORK}.0/24 ${IPV6_NETWORK}
EOCONFIG

docker compose restart dovecot-mailcow
```

### Roundcube-Link zur mailcow-App-Liste hinzufügen

Sie können den Roundcube-Link zur mailcow-App-Liste hinzufügen. Öffnen oder erstellen Sie `data/web/inc/vars.local.inc.php` und stellen Sie sicher, dass es den folgenden Konfigurationsblock enthält:

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

### Admins erlauben, sich ohne Passwort bei Roundcube anzumelden

Zuerst installieren Sie das Plugin [dovecot_impersonate](https://github.com/corbosman/dovecot_impersonate/) und fügen Roundcube als App hinzu (siehe oben).

=== "Integriert"

  ```bash
  docker exec -it -w /web/rc/plugins $(docker ps -f name=php-fpm-mailcow -q) git clone https://github.com/corbosman/dovecot_impersonate.git
  ```

=== "Standalone"

  ```bash
  docker exec -it -w /var/www/html/plugins $(docker ps -f name=roundcube -q) git clone https://github.com/corbosman/dovecot_impersonate.git
  ```

Öffnen Sie `rc/config/config.inc.php` und aktivieren Sie das Plugin `dovecot_impersonate`, indem Sie es zum `$config['plugins']`-Array hinzufügen. Zum Beispiel:

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

Bearbeiten Sie `mailcow.conf` und fügen Sie Folgendes hinzu:

```
# Erlaubt Admins, sich als E-Mail-Benutzer bei Roundcube anzumelden (ohne Passwort)
# Roundcube mit Plugin dovecot_impersonate muss zuerst installiert werden

ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=y
```

Bearbeiten Sie `docker-compose.override.yml` und erstellen/erweitern Sie den Abschnitt für `php-fpm-mailcow`:

```yaml
services:
  php-fpm-mailcow:
  environment:
    - ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE=${ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE:-n}
```

Bearbeiten Sie `data/web/js/site/mailbox.js` und fügen Sie den folgenden Code nach [`if (ALLOW_ADMIN_EMAIL_LOGIN) { ... }`](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/js/site/mailbox.js#L485-L487) ein:

```js
if (ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE) {
  item.action +=
  '<a href="/rc-auth.php?login=' +
  encodeURIComponent(item.username) +
  '" class="login_as btn btn-sm btn-xs-half btn-primary" target="_blank"><i class="bi bi-envelope-fill"></i> Roundcube</a>'
}
```

Fügen Sie die folgende Zeile zum Array `$template_data` hinzu:

- `data/web/admin/mailbox.php` [`$template_data`](https://github.com/mailcow/mailcow-dockerized/blob/master/data/web/admin/mailbox.php#L43-L56)
- `data/web/domainadmin/mailbox.php` [`$template_data`](https://github.com/mailcow/mailcow-dockerized/blob/master/data/web/domainadmin/mailbox.php#L43-L56)

```php
  'allow_admin_email_login_roundcube' => (preg_match("/^([yY][eE][sS]|[yY])+$/", $_ENV["ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE"])) ? 'true' : 'false',
```

Bearbeiten Sie `data/web/templates/mailbox.twig` und fügen Sie diesen Code am Ende des [JavaScript-Abschnitts](https://github.com/mailcow/mailcow-dockerized/blob/2f9da5ae93d93bf62a8c2b7a5a6ae50a41170c48/data/web/templates/mailbox.twig#L49-L57) hinzu:

```js
  var ALLOW_ADMIN_EMAIL_LOGIN_ROUNDCUBE = {{ allow_admin_email_login_roundcube }};
```

Kopieren Sie den Inhalt der folgenden Dateien aus diesem [Snippet](https://gitlab.com/-/snippets/2038244):

- `data/web/inc/lib/RoundcubeAutoLogin.php`
- `data/web/rc-auth.php`

## Installation abschließen

Starten Sie abschließend mailcow neu.

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


### Wechsel des RCMCardDAV-Plugins zur Composer-Installationsmethode

Dies ist optional, sorgt aber dafür, dass Ihre Installation mit diesen Anweisungen übereinstimmt und ermöglicht Ihnen, RCMCardDAV mit Composer zu aktualisieren.

Dazu müssen Sie lediglich das CardDAV-Plugin aus der Installation entfernen und es anschließend mit Composer gemäß den [obigen Anweisungen](#carddav-adressbucher-in-roundcube-integrieren) installieren.  

Diese beinhalten auch die Erstellung einer neuen RCMCardDAV-v5-Konfiguration. Falls Sie Ihre RCMCardDAV-Konfigurationsdatei angepasst haben, sollten Sie sie vor dem Entfernen sichern und Ihre Änderungen anschließend in die neue Konfiguration übernehmen.

Um das CardDAV-Plugin zu löschen, führen Sie folgenden Befehl aus und installieren Sie es danach erneut gemäß den [obigen Anweisungen](#carddav-adressbucher-in-roundcube-integrieren):

```bash
rm -r data/web/rc/plugins/carddav
```

### Umstellung von Roundcube auf die neue Datenbank

Passen Sie zuerst die Roundcube-Konfiguration an, damit diese die neue Datenbank nutzt.

```bash
sed -i "/\$config\['db_dsnw'\].*$/d" data/web/rc/config/config.inc.php
cat <<EOCONFIG >>data/web/rc/config/config.inc.php
\$config['db_dsnw'] = 'mysql://roundcube:${DBROUNDCUBE}@mysql/roundcubemail';
EOCONFIG
```

### Roundcube-Webzugriff wieder aktivieren

Führen Sie die `chown`- und `chmod`-Befehle auf den in [Vorbereitung](#vorbereitung) aufgeführten sensiblen Roundcube-Verzeichnissen aus,  
um sicherzustellen, dass der nginx-Webserver nicht auf Dateien zugreifen kann, die er nicht ausliefern soll.

Aktivieren Sie anschließend den Webzugriff auf Roundcube wieder, indem Sie die temporäre Roundcube-Custom-Config durch die [oben beschriebene](#webserver-konfiguration) ersetzen und die nginx-Konfiguration neu laden:

```bash
docker compose exec nginx-mailcow nginx -s reload
```

### Weitere Änderungen

Sie müssen auch die Konfiguration des Roundcube-Passwort-Plugins gemäß dieser Anweisung anpassen,  
insbesondere wenn Sie die Passwort-Änderungsfunktion nutzen.  
Die alte Anweisung änderte das Passwort direkt in der Datenbank, während diese Version der Anleitung die mailcow-API zur Passwortänderung verwendet.

Bezüglich weiterer Änderungen und Ergänzungen (z. B. `dovecot_client_ip`-Plugin) können Sie die aktuellen Installationsanweisungen durchgehen und Ihre Konfiguration entsprechend anpassen oder die beschriebenen Installationsschritte für neue Ergänzungen durchführen.

Beachten Sie dabei insbesondere folgende Abschnitte:

- [Ofelia-Job für Roundcube-Housekeeping](#ofelia-job-fur-roundcube-housekeeping)  
- [Erlauben unverschlüsselter Authentifizierung in Dovecot](#erlauben-unverschlusselter-authentifizierung-in-dovecot),  
falls Sie die Roundcube-Konfiguration so anpassen, dass Dovecot über eine unverschlüsselte IMAP-Verbindung kontaktiert wird.  
- [Weiterleiten der Client-IP-Adresse an Dovecot](#weiterleitung-der-client-netzwerkadresse-an-dovecot)

### Entfernen der Roundcube-Tabellen aus der mailcow-Datenbank

Nachdem Sie überprüft haben, dass die Migration erfolgreich war und Roundcube mit der separaten Datenbank funktioniert,  
können Sie die Roundcube-Tabellen aus der mailcow-Datenbank mit folgendem Befehl entfernen:

```bash
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -sN mailcow -e "SET SESSION foreign_key_checks = 0; DROP TABLE IF EXISTS $(echo $RCTABLES | sed -e 's/ \+/,/g');"
```
