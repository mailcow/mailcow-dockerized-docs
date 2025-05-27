# Installation von mailcow und Mailman 3 auf Basis der Docker-Versionen

!!! info
    Diese Anleitung ist eine Kopie von [dockerized-mailcow-mailman](https://github.com/g4rf/dockerized-mailcow-mailman). Bitte posten Sie Probleme, Fragen und Verbesserungen in den [Issue Tracker](https://github.com/g4rf/dockerized-mailcow-mailman/issues) dort.

!!! warning "Warnung"
    mailcow ist nicht verantwortlich für Datenverlust, Hardwareschäden oder kaputte Tastaturen. Diese Anleitung kommt ohne jegliche Garantie. Macht Backups bevor ihr anfangt, denn **Kein Backup, kein Mitleid!**

## Einleitung

Diese Anleitung zielt darauf ab, [mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized) mit [docker-mailman](https://github.com/maxking/docker-mailman) zu installieren und zu konfigurieren und einige nützliche Skripte bereitzustellen. Eine wesentliche Idee ist, dass *mailcow* und *Mailman* in ihren eigenen Installationen erhalten bleiben um unabhängige Updates durchzuführen.

Es gibt einige Anleitungen und Projekte im Internet. Diese sind nicht auf dem neuesten Stand und/oder unvollständig in der Dokumentation oder Konfiguration. Diese Anleitung basiert auf der Arbeit von:

- [mailcow-mailman3-dockerized](https://github.com/Shadowghost/mailcow-mailman3-dockerized) von [Shadowghost](https://github.com/Shadowghost)
- [mailman-mailcow-integration](https://gitbucket.pgollor.de/docker/mailman-mailcow-integration)

Ziel dieser Anleitung ist, [mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized) und [docker-mailman](https://github.com/maxking/docker-mailman) als Docker-Container laufen zu lassen und *Apache* als Reverse-Proxy.

Das verwendete Betriebssystem ist ein *Ubuntu 20.04 LTS*.

## Installation

Diese Anleitung basiert auf folgenden Schritten:

1. DNS-Einrichtung
1. *Apache* als Reverse-Proxy installieren
1. SSL-Zertifikate mit *Let's Encrypt*
1. *mailcow* mit *Mailman*-Integration installieren
1. *Mailman* installieren
1. 🏃 Laufen lassen

### DNS-Einrichtung

Der größte Teil der Konfiguration ist in *mailcow*s [DNS Konfiguration](../../getstarted/prerequisite-dns.de.md) enthalten. Nachdem diese Einrichtung abgeschlossen ist, fügen Sie eine weitere Subdomain für *Mailman* hinzu, z.B. `lists.example.org`, die auf denselben Server zeigt:

```
# Name Typ Wert
lists IN A 1.2.3.4
lists IN AAAA dead:beef
```

### *Apache* als Reverse Proxy installieren

Installieren Sie *Apache*, z.B. mit dieser Anleitung von *Digital Ocean*: [How To Install the Apache Web Server on Ubuntu 20.04 (Englisch)](https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-20-04).

Aktiviere folgende *Apache* Module (als *root* oder *sudo*):

```
a2enmod rewrite proxy proxy_http headers ssl wsgi proxy_uwsgi http2
```

Möglicherweise müssen weitere Pakete installiert werden, um diese Module zu erhalten. Das [PPA](https://launchpad.net/~ondrej/+archive/ubuntu/apache2) von *Ondřej Surý* kann helfen.

#### vHost-Konfiguration

Kopieren Sie die [mailcow.conf](https://github.com/g4rf/dockerized-mailcow-mailman/tree/master/apache/mailcow.conf) und die [mailman.conf](https://github.com/g4rf/dockerized-mailcow-mailman/tree/master/apache/mailman.conf) in den *Apache* conf Ordner `sites-available` (z.B. unter `/etc/apache2/sites-available`).

Änderungen in der `mailcow.conf`:
- den Platzhalter `MAILCOW_HOSTNAME` zum **MAILCOW_HOSTNAME** ändern

Änderungen in der `mailman.conf`:
- den Platzhalter `MAILMAN_DOMAIN` in die *Mailman*-Domain (z.B. `Lists.example.org`) ändern

**Aktivieren Sie die Konfiguration noch nicht, da die ssl-Zertifikate und Verzeichnisse noch fehlen.**

### SSL-Zertifikate mit *Let's Encrypt*

Prüfen Sie, ob die DNS-Konfiguration über das Internet verfügbar ist und auf die richtigen IP-Adressen zeigt, z.B. mit [MXToolBox](https://mxtoolbox.com):

- https://mxtoolbox.com/SuperTool.aspx?action=a%3aMAILCOW_HOSTNAME
- https://mxtoolbox.com/SuperTool.aspx?action=aaaa%3aMAILCOW_HOSTNAME
- https://mxtoolbox.com/SuperTool.aspx?action=a%3aMAILMAN_DOMAIN
- https://mxtoolbox.com/SuperTool.aspx?action=aaaa%3aMAILMAN_DOMAIN

Installieren Sie [certbot](https://certbot.eff.org/) (als *root* oder *sudo*):

```
apt install certbot
```

Holen der gewünschten Zertifikate (als *root* oder *sudo*):

```
certbot certonly -d mailcow_HOSTNAME
certbot certonly -d MAILMAN_DOMAIN
```

### *mailcow* mit *Mailman*-Integration installieren

#### mailcow installieren

Folgen Sie der beschreibung unter [mailcow installation](../../getstarted/install.de.md). **Den Schritt »_mailcow starten_« auslassen und kein pull und up durchführen!**

#### mailcow konfigurieren

Den Schritt **mailcow Initialisieren** ausführen und dann mittels `nano mailcow.conf` folgende Variablen anpassen:

```
HTTP_PORT=18080            # nicht 8080 verwenden, wird von mailman benutzt
HTTP_BIND=127.0.0.1        #
HTTPS_PORT=18443           # hier kann 8443 verwendet werden
HTTPS_BIND=127.0.0.1       #

SKIP_LETS_ENCRYPT=y        # Apache macht die SSL-Terminierung

SNAT_TO_SOURCE=1.2.3.4     # die öffentliche IPv4 des Servers
SNAT6_TO_SOURCE=dead:beef  # die öffentliche IPv6 des Servers
```

#### Mailman-Integration hinzufügen

Erstellen Sie die Datei `/opt/mailcow-dockerized/docker-compose.override.yml` (z.B. mit `nano`) und fügen Sie die folgenden Zeilen hinzu:

```
services:
  postfix-mailcow:
    volumes:
      - /opt/mailman/core/var/data/:/opt/mailman/core/var/data/
    networks:
      - docker-mailman_mailman

networks:
  docker-mailman_mailman:
    external: true
```

- Das zusätzliche Volume wird von *Mailman* verwendet, um zusätzliche Konfigurationsdateien für *mailcow postfix* zu generieren.
- Das externe Netzwerk wird von *Mailman* erstellt und verwendet. *mailcow* benötigt es, um eingehende Listenmails an *Mailman* zu liefern.

Erstellen Sie die Datei `/opt/mailcow-dockerized/data/conf/postfix/extra.cf` (z.B. mit `nano`) und fügen Sie die folgenden Zeilen hinzu:

```
# mailman

recipient_delimiter = +
unknown_local_recipient_reject_code = 550
owner_request_special = no

local_recipient_maps =
  regexp:/opt/mailman/core/var/data/postfix_lmtp,
  proxy:unix:passwd.byname,
  $alias_maps
virtual_mailbox_maps =
  proxy:mysql:/opt/postfix/conf/sql/mysql_virtual_mailbox_maps.cf,
  regexp:/opt/mailman/core/var/data/postfix_lmtp
transport_maps =
  pcre:/opt/postfix/conf/custom_transport.pcre,
  pcre:/opt/postfix/conf/local_transport,
  proxy:mysql:/opt/postfix/conf/sql/mysql_relay_ne.cf,
  proxy:mysql:/opt/postfix/conf/sql/mysql_transport_maps.cf,
  regexp:/opt/mailman/core/var/data/postfix_lmtp
relay_domains =
  proxy:mysql:/opt/postfix/conf/sql/mysql_virtual_relay_domain_maps.cf,
  regexp:/opt/mailman/core/var/data/postfix_domains
relay_recipient_maps =
  proxy:mysql:/opt/postfix/conf/sql/mysql_relay_recipient_maps.cf,
  regexp:/opt/mailman/core/var/data/postfix_lmtp
```

Da wir hier die *mailcow postfix* Konfiguration überschreiben, kann dieser Schritt die *mail transports* unterbrechen. Überprüfen Sie daher die [originalen Konfigurationsdateien](https://github.com/mailcow/mailcow-dockerized/tree/master/data/conf/postfix) auf Änderungen.

#### SSL-Zertifikate

Da wir *mailcow* hinter einem Proxy haben, müssen wir die SSL-Zertifikate in die *mailcow*-Dateistruktur kopieren. Diese Aufgabe wird das Skript [renew-ssl.sh](https://github.com/g4rf/dockerized-mailcow-mailman/tree/master/scripts/renew-ssl.sh) für uns erledigen:

- die Datei `renew-ssl-sh` nach `/opt/mailcow-dockerized` kopieren
- in der Datei den Platzhalter **MAILCOW_HOSTNAME** in den *mailcow*-Hostnamen ändern
- das Skript ausführbar machen (`chmod a+x renew-ssl.sh`)
- **Noch nicht ausführen, da wir noch Mailman benötigen!**

Um neue Zertifikate zu kopieren, legen wir noch einen *cronjob* an. Als *root* oder *sudo*:

```
crontab -e
```

Um das Skript jeden Tag um 5 Uhr morgens laufen zu lassen:

```
0 5 * * * /opt/mailcow-dockerized/renew-ssl.sh
```

### *Mailman* installieren

Befolgen Sie im Wesentlichen die Anweisungen unter [docker-mailman](https://github.com/maxking/docker-mailman). Da diese sehr umfangreich sind, folgt hier eine kurze Zusammenfassung:

Als *root* oder *sudo*:

```
cd /opt
mkdir -p mailman/core
mkdir -p mailman/web
git clone https://github.com/maxking/docker-mailman
cd docker-mailman
```

#### Mailman konfigurieren

- Erstellen Sie einen langen Schlüssel für *Hyperkitty*, z.B. mit dem Linux-Befehl `cat /dev/urandom | tr -dc a-zA-Z0-9 | head -c30; echo`. Das ist der Schlüssel für `HYPERKITTY_KEY`.
- Erstellen Sie ein langes Passwort für die Datenbank, z. B. mit dem Linux-Befehl `cat /dev/urandom | tr -dc a-zA-Z0-9 | head -c30; echo`. Das Passwort brauchen wir für `DBPASS`.
- Erstellen Sie einen langen Schlüssel für *Django*, z. B. mit dem Linux-Befehl `cat /dev/urandom | tr -dc a-zA-Z0-9 | head -c30; echo`. Das ist der Schlüssel für `DJANGO_KEY`.

Erstellen Sie die Datei `/opt/docker-mailman/docker compose.override.yaml` und ersetzen `HYPERKITTY_KEY`, `DBPASS` und `DJANGO_KEY` durch die generierten Werte:

```
services:
  mailman-core:
    environment:
    - DATABASE_URL=postgresql://mailman:DBPASS@database/mailmandb
    - HYPERKITTY_API_KEY=HYPERKITTY_KEY
    - TZ=Europe/Berlin
    - MTA=postfix
    restart: always
    networks:
      - mailman

  mailman-web:
    environment:
    - DATABASE_URL=postgresql://mailman:DBPASS@database/mailmandb
    - HYPERKITTY_API_KEY=HYPERKITTY_KEY
    - TZ=Europe/Berlin
    - SECRET_KEY=DJANGO_KEY
    - SERVE_FROM_DOMAIN=MAILMAN_DOMAIN # e.g. lists.example.org
    - MAILMAN_ADMIN_USER=admin # the admin user
    - MAILMAN_ADMIN_EMAIL=admin@example.org # the admin mail address
    - UWSGI_STATIC_MAP=/static=/opt/mailman-web-data/static
    restart: always

  database:
    environment:
    - POSTGRES_PASSWORD=DBPASS
    restart: always
```

Bei `mailman-web` geben Sie die korrekten Werte für `SERVE_FROM_DOMAIN` (z.B. `lists.example.org`), `MAILMAN_ADMIN_USER` und `MAILMAN_ADMIN_EMAIL` ein. Die Admin-Zugangsdaten werden benötigt, um sich in der Web-Oberfläche (*Pistorius*) anzumelden. Um **das Passwort zum ersten Mal** zu setzen, verwenden Sie die Funktion *Passwort vergessen* im Webinterface.

Über andere Konfigurationsoptionen lesen Sie die Dokumentationen zu [Mailman-web](https://github.com/maxking/docker-mailman#mailman-web-1) und [Mailman-core](https://github.com/maxking/docker-mailman#mailman-core-1).

#### Mailman core und Mailman web konfigurieren

Erstellen Sie die Datei `/opt/mailman/core/mailman-extra.cfg` mit dem folgenden Inhalt. `mailman@example.org` sollte auf ein gültiges Postfach oder eine Umleitung verweisen.

```
[mailman]
default_language: de
site_owner: mailman@example.org
```

Erstellen Sie die Datei `/opt/mailman/web/settings_local.py` mit dem folgenden Inhalt. `mailman@example.org` sollte auf ein gültiges Postfach oder eine Umleitung verweisen.

```
# Gebietsschema
LANGUAGE_CODE = 'de-de'

# Social Auth deaktivieren
MAILMAN_WEB_SOCIAL_AUTH = []

# Hier bitte ändern
DEFAULT_FROM_EMAIL = 'mailman@example.org'

DEBUG = False
```
`LANGUAGE_CODE` und `SOCIALACCOUNT_PROVIDERS` kann an die eigenen Bedürfnisse angepasst werden.

### 🏃 Laufen lassen

Ausführen (als *root* oder *sudo*):

=== "docker compose (Plugin)"

    ``` bash
    a2ensite mailcow.conf
    a2ensite mailman.conf
    systemctl restart apache2

    cd /opt/docker-mailman
    docker compose pull
    docker compose up -d

    cd /opt/mailcow-dockerized/
    docker compose pull
    ./renew-ssl.sh
    ```

=== "docker-compose (Standalone)"

    ``` bash
    a2ensite mailcow.conf
    a2ensite mailman.conf
    systemctl restart apache2

    cd /opt/docker-mailman
    docker-compose pull
    docker-compose up -d

    cd /opt/mailcow-dockerized/
    docker-compose pull
    ./renew-ssl.sh
    ```

**Warten Sie ein paar Minuten!** Die Container müssen ihre Datenbanken und Konfigurationsdateien erstellen. Dies kann bis zu 1 Minute und länger dauern.

## Bemerkungen

### Neue Listen werden von Postfix nicht sofort erkannt

Wenn man eine neue Liste anlegt und versucht, sofort eine E-Mail zu versenden, antwortet *postfix* mit `User doesn't exist`, weil *postfix* die Liste noch nicht an *Mailman* übergeben hat. Die Konfiguration unter `/opt/mailman/core/var/data/postfix_lmtp` wird nicht sofort aktualisiert. Wenn Sie die Liste sofort benötigen, starten Sie *postifx* manuell neu:

=== "docker compose (Plugin)"

    ``` bash
    cd /opt/mailcow-dockerized
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    cd /opt/mailcow-dockerized
    docker-compose restart postfix-mailcow
    ```

## Updates

**mailcow** hat sein eigenes Update-Skript in `/opt/mailcow-dockerized/update.sh`, [siehe die Dokumentation](../../maintenance/update.de.md).

Für **Mailman** holen Sie die neueste Version aus dem [GitHub-Repository](https://github.com/maxking/docker-mailman).

## Backups

**mailcow** hat ein eigenes Backup-Skript. [Lesen Sie die Docs](../../backup_restore/b_n_r-backup.de.md) für weitere Informationen.

**Mailman** gibt keine Backup-Anweisungen in der README.md an. Im [gitbucket von pgollor](https://gitbucket.pgollor.de/docker/mailman-mailcow-integration/blob/master/mailman-backup.sh) befindet sich ein Skript, das hilfreich sein könnte.

## ToDo

### Ein Installations-Skript

Ein Skript erstellen wie [mailman-mailcow-integration/mailman-install.sh](https://gitbucket.pgollor.de/docker/mailman-mailcow-integration/blob/master/mailman-install.sh), da viele der Schritte automatisierbar sind.

1. Konfigurationsvariablen abfragen und Passwörter und Schlüssel erstellen
2. (Halb)automatische Installation durchführen
3. Spaß haben!



