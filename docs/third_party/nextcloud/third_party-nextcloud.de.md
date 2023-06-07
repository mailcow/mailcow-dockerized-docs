## Nextcloud mit dem Helper-Skript verwalten

Nextcloud kann mit dem [helper script](https://github.com/mailcow/mailcow-dockerized/raw/master/helper-scripts/nextcloud.sh), das in mailcow enthalten ist, eingerichtet (Parameter `-i`) und entfernt (Parameter `-p`) werden. Um Nextcloud zu installieren, navigieren Sie einfach zu Ihrem mailcow-dockerized Root-Ordner und führen Sie das Helper-Skript wie folgt aus:

`./helper-scripts/nextcloud.sh -i`

Für den Fall, dass Sie das Passwort (z.B. für admin) vergessen haben und kein neues anfordern können [über den Passwort-Reset-Link auf dem Login-Bildschirm] (https://docs.nextcloud.com/server/20/admin_manual/configuration_user/reset_admin_password.html?highlight=reset), können Sie durch den Aufruf des Helper-Skripts mit `-r` als Parameter ein neues Passwort setzen. Verwenden Sie diese Option nur, wenn Ihre Nextcloud nicht so konfiguriert ist, dass Sie mailcow zur Authentifizierung verwendet, wie im nächsten Abschnitt beschrieben.

Damit mailcow ein Zertifikat für die Nextcloud Domain generieren kann, muss die Domain unter welcher die Nextcloud später erreichbar sein soll als ADDITIONAL_SAN in die mailcow.conf hinzufügt werden und folgender Befehl zur Übernahme ausgeführt werden. 

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Für weitere Informationen siehe: [Erweitertes SSL](../../post_installation/firststeps-ssl.de.md).

## Hintergrund-Aufgaben

Zur Verwendung der empfohlenen Einstellung (Cron) zur Verarbeitung der Hintergrund-Aufgaben müssen in der `docker-compose.override.yml` folgende Zeilen
 hinzugefügt werden:

```yaml
version: '2.1'
services:
  php-fpm-mailcow:
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.nextcloud-cron.schedule: "@every 5m"
      ofelia.job-exec.nextcloud-cron.command: "su www-data -s /bin/bash -c \"/usr/local/bin/php -f /web/nextcloud/cron.php\""
```

Nachdem diese Zeilen hinzugefügt wurden muss der folgende Befehl ausgeführt werden, um das Docker Image mit den entsprechenden Labels zu versehen. 

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Danach muss zudem der docker scheduler neu gestartet werden, um den neuen Job zu registrieren. Dazu wird der folgende Befehl ausgeführt. 

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart ofelia-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart ofelia-mailcow
    ```

Zur Überprüfung, ob die `ofelia` Konfiguration korrekt ist geladen wurde, kann mittels dem untenstehenden Befehl nach einer Zeile mit dem Inhalt
 `New job registered "nextcloud-cron" - ...` gesucht werden:

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs ofelia-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose logs ofelia-mailcow
    ```

Hierdurch wird alle 5 Minuten die Hintergrundverarbeitung gestartet. Da die Ausführung selbst keine Ausgabe liefert, kann die korrekte Funktionsweise in den
 Grundeinstellungen von Nextcloud überprüft werden. Hier wird automatisch mit der ersten Ausführung die Hintergrund-Aufgaben Verarbeitung auf `(X) Cron` gesetzt
 und der Zeitstempel `Letzte Aufgabe ausgeführt ` aktualisiert.

## Konfigurieren Sie Nextcloud, um mailcow für die Authentifizierung zu verwenden

Im Folgenden wird beschrieben, wie die Authentifizierung über mailcow unter Verwendung des OAuth2-Protokolls eingerichtet wird. Wir nehmen nur an, dass Sie Nextcloud bereits unter _cloud.example.com_ eingerichtet haben und dass Ihre mailcow unter _mail.example.com_ läuft. Es spielt keine Rolle, wenn Ihre Nextcloud auf einem anderen Server läuft, Sie können immer noch mailcow für die Authentifizierung verwenden.

1\. Melden Sie sich bei mailcow als Administrator an.

2\. Klicken Sie im Dropdown Menü (oben rechts) auf Konfiguration.

3\. Wählen Sie dann im Reiter "Zugang" den Dropdown Punkt OAuth2 aus.

4\. Scrollen Sie nach unten und klicken Sie auf die Schaltfläche _Füge OAuth2 Client hinzu_. Geben Sie die Redirect URI als `https://cloud.example.com/index.php/apps/sociallogin/custom_oauth2/mailcow` an und klicken Sie auf _Hinzufügen_. Speichern Sie die Client-ID und das Geheimnis für später.

!!! info
    Einige Installationen, einschließlich derer, die mit dem Helper-Skript von mailcow eingerichtet wurden, müssen index.php/ aus der URL entfernen, um einen erfolgreichen Redirect zu erhalten: `https://cloud.example.com/apps/sociallogin/custom_oauth2/mailcow`

3\. Melden Sie sich bei Nextcloud als Administrator an.

4\. Klicken Sie auf die Schaltfläche in der oberen rechten Ecke und wählen Sie _Apps_. Klicken Sie auf die Schaltfläche "Suchen" in der Symbolleiste, suchen Sie nach dem Plugin [_Social Login_](https://apps.nextcloud.com/apps/sociallogin) und klicken Sie daneben auf _Herunterladen und aktivieren_.

5\. Klicken Sie auf die Schaltfläche in der oberen rechten Ecke und wählen Sie _Einstellungen_. Scrollen Sie zum Abschnitt _Administration_ auf der linken Seite und klicken Sie auf _Social Login_.

6\. Entfernen Sie das Häkchen bei den folgenden Punkten:

- "Automatische Erstellung neuer Benutzer deaktivieren"
- "Benutzern erlauben, soziale Logins mit ihren Konten zu verbinden".
- "Nicht verfügbare Benutzergruppen bei der Anmeldung nicht entfernen"
- "Gruppen automatisch erstellen, wenn sie nicht vorhanden sind"
- "Anmeldung für Benutzer ohne zugeordnete Gruppen einschränken".

7\. Überprüfen Sie die folgenden Punkte:

- "Die Erstellung eines Kontos verhindern, wenn die E-Mail-Adresse in einem anderen Konto existiert"
- "Benutzerprofil bei jeder Anmeldung aktualisieren"
- "Benachrichtigung der Administratoren über neue Benutzer deaktivieren".

Klicken Sie auf die Schaltfläche _Speichern_.

8\. Scrollen Sie nach unten zu _Custom OAuth2_ und klicken Sie auf die Schaltfläche _+_.
9\. Konfigurieren Sie die Parameter wie folgt:

- Interner Name: `mailcow`
- Titel: `mailcow`
- API Basis-URL: `https://mail.example.com`
- Autorisierungs-URL: `https://mail.example.com/oauth/authorize`
- Token-URL: `https://mail.example.com/oauth/token`
- Profil-URL: `https://mail.example.com/oauth/profile`
- Abmelde-URL: (leer lassen)
- Kunden-ID: (die Sie in Schritt 1 erhalten haben)
- Client Secret: (was Sie in Schritt 1 erhalten haben)
- Bereich: `Profil`

Klicken Sie auf die Schaltfläche _Speichern_ ganz unten auf der Seite.

---

Wenn Sie bisher Nextcloud mit mailcow-Authentifizierung über user\_external/IMAP verwendet haben, müssen Sie einige zusätzliche Schritte durchführen, um Ihre bestehenden Benutzerkonten mit OAuth2 zu verknüpfen.

1\. Klicken Sie auf die Schaltfläche in der oberen rechten Ecke und wählen Sie _Apps_. Scrollen Sie nach unten zur App _Externe Benutzerauthentifizierung_ und klicken Sie daneben auf _Entfernen_.

2\. Führen Sie die folgenden Abfragen in Ihrer Nextcloud-Datenbank aus (wenn Sie Nextcloud mit dem Skript von mailcow einrichten, können Sie folgenden Befehl nutzen um in den Container zu gelangen)

=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf && docker compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf && docker-compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

```sql
INSERT INTO oc_users (uid, uid_lower) SELECT DISTINCT uid, LOWER(uid) FROM oc_users_external;
INSERT INTO oc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("mailcow-", uid) FROM oc_users_external;
```

---

Wenn Sie Nextcloud bisher ohne mailcow-Authentifizierung, aber mit den gleichen Benutzernamen wie mailcow genutzt haben, können Sie Ihre bestehenden Benutzerkonten auch mit OAuth2 verknüpfen.

1\. Führen Sie die folgenden Abfragen in Ihrer Nextcloud-Datenbank aus (wenn Sie Nextcloud mit dem Skript von mailcow einrichten, können Sie folgenden Befehl nutzen um in den Container zu gelangen):

=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf && docker compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf && docker-compose exec mysql-mailcow mysql -u$DBUSER -p$DBPASS $DBNAME
    ```

```sql
INSERT INTO oc_sociallogin_connect (uid, identifier) SELECT DISTINCT uid, CONCAT("mailcow-", uid) FROM oc_users;
```

---

## Aktualisieren

Die Nextcloud-Instanz kann einfach mit dem Web-Update-Mechanismus aktualisiert werden. Bei größeren Updates können nach dem Update weitere Änderungen vorgenommen werden. Nachdem die Nextcloud-Instanz geprüft wurde, werden Probleme angezeigt. Dies können z.B. fehlende Indizes in der DB oder ähnliches sein.
Es wird angezeigt, welche Befehle ausgeführt werden müssen, diese müssen im php-fpm-mailcow Container platziert werden.

Führen Sie z.B. folgenden Befehl aus, um die fehlenden Indizes hinzuzufügen:

`docker exec -it -u www-data $(docker ps -f name=php-fpm-mailcow -q) bash -c "php /web/nextcloud/occ db:add-missing-indices"`

Das Update kann bei Bedarf auch per CLI durchgeführt werden.
Dies ist mit folgedem Befehl im interaktiven Modus möglich:

`docker exec -it -u www-data $(docker ps -f name=php-fpm-mailcow -q) bash -c "php /web/nextcloud/updater/updater.phar"`

Um das Update ohne Rückfragen auszuführen, z.B. durch einen CRON Job, kann folgender Befehl verwendet werden: 

`docker exec -it -u www-data $(docker ps -f name=php-fpm-mailcow -q) bash -c "php /web/nextcloud/updater/updater.phar --no-interaction"`

---

## Fehlersuche und Fehlerbehebung

Es kann vorkommen, dass Sie die Nextcloud-Instanz von Ihrem Netzwerk aus nicht erreichen können. Dies kann daran liegen, dass der Eintrag Ihres Subnetzes im Array 'trusted_proxies' fehlt. Sie können Änderungen in der Nextcloud config.php in `data/web/nextcloud/config/*` vornehmen.

```php
'trusted_proxies' =>
  array (
    0 => 'fd4d:6169:6c63:6f77::/64',
    1 => '172.22.1.0/24',
    2 => 'NewSubnet/24',
  ),
```

Nachdem die Änderungen vorgenommen wurden, muss der nginx-Container neu gestartet werden.
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart nginx-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart nginx-mailcow
    ```
