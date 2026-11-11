# Borgmatic Backup

## Einführung

Borgmatic ist ein großartiger Weg, um Backups auf Ihrem mailcow-Setup durchzuführen, da es Ihre Daten sicher verschlüsselt und extrem einfach einzurichten ist.

Aufgrund seiner Deduplizierungsfähigkeiten können Sie eine große Anzahl von Backups speichern, ohne große Mengen an Speicherplatz zu verschwenden.
So können Sie Backups in sehr kurzen Abständen durchführen, um einen minimalen Datenverlust zu gewährleisten, wenn die Notwendigkeit besteht,
Daten aus einer Sicherung wiederherzustellen.

Dieses Dokument führt Sie durch den Prozess zur Aktivierung kontinuierlicher Backups für mailcow mit borgmatic. Die borgmatic
Funktionalität wird durch das [borgmatic Docker Image](https://github.com/borgmatic-collective/docker-borgmatic) bereitgestellt. Schauen Sie sich
die `README` in diesem Repository an, um mehr über die anderen Optionen (wie z.B. Push-Benachrichtigungen) zu erfahren, die verfügbar sind.
Diese Anleitung behandelt nur die Grundlagen.

---

## Einrichten von borgmatic

### Erstellen oder ändern Sie `docker-compose.override.yml`

Im mailcow-dockerized Stammverzeichnis erstellen oder bearbeiten Sie `docker-compose.override.yml` und fügen Sie die folgende
Konfiguration ein:

```yaml
services:
  borgmatic-mailcow:
    image: ghcr.io/borgmatic-collective/borgmatic
    hostname: mailcow
    restart: always
    dns: ${IPV4_NETWORK:-172.22.1}.254
    volumes:
      - vmail-vol-1:/mnt/source/vmail:ro
      - crypt-vol-1:/mnt/source/crypt:ro
      - redis-vol-1:/mnt/source/redis:ro
      - rspamd-vol-1:/mnt/source/rspamd:ro
      - postfix-vol-1:/mnt/source/postfix:ro
      - mysql-socket-vol-1:/var/run/mysqld/
      - borg-config-vol-1:/root/.config/borg
      - borg-cache-vol-1:/root/.cache/borg
      - ./data/conf/borgmatic/etc:/etc/borgmatic.d:Z
      - ./data/conf/borgmatic/ssh:/root/.ssh:Z
    environment:
      - TZ=${TZ}
      - BORG_PASSPHRASE=${BORG_PASSPHRASE}
      - DBNAME=${DBNAME}
      - DBUSER=${DBUSER}
      - DBPASS=${DBPASS}
    networks:
      mailcow-network:
        aliases:
          - borgmatic

volumes:
  borg-cache-vol-1:
  borg-config-vol-1:
```

Fügen Sie `BORG_PASSPHRASE=YouBetterPutSomethingRealGoodHere` zu Ihrer `mailcow.conf` hinzu und stellen Sie sicher, dass Sie die `BORG_PASSPHRASE` in eine sichere Passphrase Ihrer Wahl ändern.

Aus Sicherheitsgründen mounten wir das maildir als schreibgeschützt. Wenn Sie später Daten wiederherstellen wollen,
müssen Sie das `ro`-Flag entfernen, bevor Sie die Daten wiederherstellen. Dies wird im Abschnitt über die Wiederherstellung von Backups beschrieben.

### Erstellen Sie `data/conf/borgmatic/etc/config.yaml`

Als nächstes müssen wir die borgmatic-Konfiguration erzeugen. Borgmatic unterstützt Umgebungsvariableninterpolation, dadurch erhalten wir die korrekten MySQL-Zugangsdaten über Docker bzw. über unsere `mailcow.conf`, ohne dass diese in der Konfigurationsdatei offengelegt werden.

Vergewissern Sie sich, alle folgenden Zeilen zu kopieren!

```bash
cat <<EOF > data/conf/borgmatic/etc/config.yaml
source_directories:
    - /mnt/source/vmail
    - /mnt/source/crypt
    - /mnt/source/redis
    - /mnt/source/rspamd
    - /mnt/source/postfix
repositories:
    - path: ssh://uXXXXX@uXXXXX.your-storagebox.de:23/./mailcow
      label: rsync
exclude_patterns:
    - '/mnt/source/postfix/public/'
    - '/mnt/source/postfix/private/'
    - '/mnt/source/rspamd/rspamd.sock'

keep_hourly: 24
keep_daily: 7
keep_weekly: 4
keep_monthly: 6

mariadb_databases:
    - name: \${DBNAME}
      username: \${DBUSER}
      password: \${DBPASS}
      options: "--default-character-set=utf8mb4 --skip-ssl"
      list_options: "--skip-ssl"
      restore_options: "--skip-ssl"
EOF
```

!!! warning
    Ab borgmatic 1.8.0 (erschienen am 19. Juli 2023) wurde der Aufbau der Konfigurationsdatei
    [geändert](https://github.com/borgmatic-collective/borgmatic/releases/tag/1.8.0). Sie können die Docker-Logs
    des Borgmatic-Containers auf Deprecation-Warnmeldungen prüfen, um festzustellen, ob Sie betroffen sind und Ihre
    Konfigurationsdatei für eine ältere Version von borgmatic erstellt wurde. In diesem Fall sollten Sie eine neue
    `config.yaml`-Datei wie oben beschrieben erstellen, um Probleme mit zukünftigen Versionen von borgmatic zu vermeiden.

!!! warning
    Ab borgmatic 1.9.4 (erschienen am 11. Dezember 2024) versuchen die enthaltenen MariaDB-Tools standardmäßig, verschlüsselte Verbindungen
    herzustellen. Bearbeiten Sie die `config.yaml` und fügen Sie `--skip-ssl` zu `options`, `restore_options` und `list_options` wie oben gezeigt hinzu.
    Ändern Sie außerdem `mysql_databases` in `mariadb_databases`, um Probleme mit zukünftigen Versionen von borgmatic und MariaDB zu vermeiden.

Diese Datei ist ein minimales Beispiel für die Verwendung von borgmatic mit einem Konto `uXXXXX` auf einer Storage Box beim Cloud-Speicheranbieter `Hetzner`. Als Repository wird `mailcow` verwendet (siehe Einstellung `repositories`). Dies muss entsprechend angepasst werden.

Es wird sowohl das maildir als auch die MySQL-Datenbank gesichert, was alles ist, was Sie brauchen, um Ihre mailcow nach einem Vorfall wiederherzustellen.

Im Backup wird jeweils ein Archiv für jede der letzten 24 Stunden, eines für jeden der letzten 7 Wochentage, eines für jede der letzten 4 Wochen und eines pro Monat des letzten halben Jahrs behalten.

Schauen Sie in der [borgmatic Dokumentation](https://torsion.org/borgmatic/) nach, wie Sie andere Arten von Repositories oder
Konfigurationsoptionen nutzen können. Wenn Sie ein lokales Dateisystem als Backup-Ziel verwenden, stellen Sie sicher, dass Sie es in den
Container einbinden. Der Container definiert zu diesem Zweck ein Volume namens `/mnt/borg-repository`.

### Erstellen Sie einen crontab

Erstellen Sie eine neue Textdatei in `data/conf/borgmatic/etc/crontab.txt` mit folgendem Inhalt:

```
14 * * * * PATH=$PATH:/usr/local/bin /usr/local/bin/borgmatic --stats -v 0 2>&1
```

Diese Datei erwartet eine crontab-Syntax. Das hier gezeigte Beispiel veranlasst das Backup, jede Stunde um 14 Minuten
nach der vollen Stunde auszuführen und am Ende einige nette Statistiken zu protokollieren.

### SSH-Schlüssel in Ordner ablegen

Legen Sie die SSH-Schlüssel, die Sie für Verbindungen zu entfernten Repositories verwenden wollen, in `data/conf/borgmatic/ssh` ab. OpenSSH erwartet die
übliche `id_rsa`, `id_ed25519` oder ähnliches in diesem Verzeichnis zu finden. Stellen Sie sicher, dass die Datei `chmod 600` und nicht für alle lesbar ist,
oder OpenSSH wird sich weigern, den SSH-Schlüssel zu benutzen.

### Den Container hochfahren

Für den nächsten Schritt müssen wir den Container in einem konfigurierten Zustand hochfahren und laufen lassen. Um das zu tun, führen Sie aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

### Das Backup Repository initialisieren

Zwar ist Ihr borgmatic-Container jetzt betriebsbereit, aber die Backups schlagen derzeit fehl, da das Repository nicht
initialisiert wurde.

Um das Repository zu initialisieren, führen Sie folgenden Befehl aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic init --encryption repokey-blake2
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic init --encryption repokey-blake2
    ```

Sie werden aufgefordert, den SSH-Hostschlüssel Ihres entfernten Repository-Servers zu authentifizieren. Prüfen Sie, ob er übereinstimmt
und bestätigen Sie die Aufforderung mit `yes`. Das Repository wird mit der Passphrase initialisiert, die Sie zuvor in der Umgebungsvariable `BORG_PASSPHRASE` gesetzt haben.

Bei Verwendung einer der `repokey`-Verschlüsselungsmethoden wird der Verschlüsselungsschlüssel im Repository selbst gespeichert und nicht auf
dem Client, so dass in dieser Hinsicht keine weiteren Maßnahmen erforderlich sind. Wenn Sie sich für die Verwendung eines `keyfile` anstelle von
`repokey` entscheiden, stellen Sie sicher, dass Sie den Schlüssel exportieren und separat sichern. Lesen Sie den Abschnitt [Exportieren von Schlüsseln](#exportieren-von-schlusseln)
um zu erfahren, wie Sie den Schlüssel abrufen können.

### Container neustarten

Nachdem wir nun die Konfiguration und Initialisierung des Repositorys abgeschlossen haben, starten wir den Container neu, um sicherzustellen, dass er sich in einem definierten
Zustand befindet:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart borgmatic-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart borgmatic-mailcow
    ```

---

## Wiederherstellung von einem Backup

Das Wiederherstellen eines Backups setzt voraus, dass Sie mit einer neuen Installation von mailcow beginnen, und dass Sie derzeit
keine benutzerdefinierten Daten in ihrem maildir oder ihrer mailcow-Datenbank haben.

### Wiederherstellen von maildir (vollständig)

!!! warning "Warnung"
    Dies wird Dateien in Ihrem maildir überschreiben! Führen Sie dies nicht aus, es sei denn, Sie beabsichtigen tatsächlich, Mail
    Dateien von einem Backup wiederherzustellen.

!!! note "Wenn Sie SELinux im Enforcing-Modus verwenden"
    Wenn Sie mailcow auf einem Host mit SELinux im Enforcing-Modus verwenden, müssen Sie ihn
    während der Extraktion des Archivs vorübergehend deaktivieren, da das mailcow-Setup das vmail-Volume als privat kennzeichnet, das ausschließlich dem Dovecot-Container gehört.
    SELinux wird (berechtigterweise) jeden anderen Container, wie z.B. den borgmatic Container, daran hindern, auf
    dieses Volume zu schreiben.

Bevor Sie eine Wiederherstellung durchführen, müssen Sie die Volumes in `docker-compose.override.yml` beschreibbar machen, indem Sie
das `ro`-Flag der mit `ro` eingebundenen Volumes entfernen.
Dann können Sie den folgenden Befehl verwenden, um das Maildir aus einem Backup wiederherzustellen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic extract --path mnt/source --archive latest
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic extract --path mnt/source --archive latest
    ```

Alternativ können Sie auch einen beliebigen Archivnamen aus der Liste der Archive angeben (siehe
[Auflistung aller verfügbaren Archive](#auflistung-aller-verfugbaren-archive))

### Wiederherstellen von maildir (pro Mailbox)

Es besteht auch die Möglichkeit, nur eine einzelne Mailbox aus einem Backup wiederherzustellen. Angenommen, Sie möchten die Mailbox für `user@example.com` wiederherstellen.

Auch hier gilt wieder, dass vor der Wiederherstellung das `ro`-Flag aus dem Volume in der `docker-compose.override.yml` entfernt werden muss, bevor Sie fortfahren.

Wenn Sie die Konfiguration von oben verwendet haben, speichert Borgmatic die Backups im Verzeichnis `mnt/source/vmail/example.com/user/` (jetzt hier in dem Beispiel für unseren Nutzer `user@example.com`).

Um diese Mailbox wiederherzustellen, verwenden Sie den folgenden Befehl:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic extract --path mnt/source/vmail/example.com/user --archive latest
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic extract --path mnt/source/vmail/example.com/user --archive latest
    ```

!!! info "Hinweis"
    Statt `latest` können Sie auch einen beliebigen Archivnamen aus der Liste der Archive angeben (siehe [Auflistung aller verfügbaren Archive](#auflistung-aller-verfugbaren-archive))

Je nachdem, wie lange es her ist, dass die ursprünglichen Daten gelöscht wurden, müssen Sie via Dovecot einen Reindex der Mailbox durchführen, damit die wiederhergestellten E-Mails in Ihrem E-Mail-Client angezeigt werden:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec dovecot-mailcow doveadm index -u user@example.com '*'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec dovecot-mailcow doveadm index -u user@example.com '*'
    ```

### MySQL wiederherstellen

!!! warning "Warnung"
    Die Ausführung dieses Befehls löscht und erstellt die mailcow-Datenbank neu! Führen Sie diesen Befehl nicht aus, es sei denn Sie beabsichtigen, die mailcow-Datenbank von einem Backup wiederherzustellen.

Um die MySQL-Datenbank aus dem letzten Archiv wiederherzustellen, verwenden Sie diesen Befehl:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic restore --archive latest
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic restore --archive latest
    ```

Alternativ können Sie auch einen beliebigen Archivnamen aus der Liste der Archive angeben (siehe
[Auflistung aller verfügbaren Archive](#auflistung-aller-verfugbaren-archive))

### Nach der Wiederherstellung

Nach der Wiederherstellung müssen Sie mailcow neu starten. Wenn Sie den Enforcing-Modus von SELinux deaktiviert haben, wäre jetzt ein guter Zeitpunkt, um
ihn wieder zu aktivieren.

Um mailcow neu zu starten, verwenden Sie den folgenden Befehl:

=== "docker compose (Plugin)"

    ``` bash
    docker compose down && docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose down && docker-compose up -d
    ```

Wenn Sie SELinux verwenden, werden dadurch auch alle Dateien in Ihrem vmail-Volume neu benannt. Seien Sie geduldig, denn dies kann
eine Weile dauern kann, wenn Sie viele Dateien haben.

---

## Nützliche Befehle

### Manueller Archivierungslauf (mit Debugging-Ausgabe)

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic -v 2
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic -v 2
    ```

### Auflistung aller verfügbaren Archive

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic list
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic list
    ```

### Sperre aufheben

Wenn borg während eines Archivierungslaufs unterbrochen wird, hinterlässt es eine Sperre, die gelöscht werden muss, bevor
neue Operationen durchgeführt werden können:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec borgmatic-mailcow borgmatic break-lock
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec borgmatic-mailcow borgmatic break-lock
    ```


Jetzt wäre ein guter Zeitpunkt, einen manuellen Archivierungslauf durchzuführen, um sicherzustellen, dass er erfolgreich durchgeführt werden kann.

### Exportieren von Schlüsseln

Wenn Sie eine der `keyfile`-Methoden zur Verschlüsselung verwenden, **MÜSSEN** Sie sich selbst um die Sicherung der Schlüsseldateien kümmern. Die
Schlüsseldateien werden erzeugt, wenn Sie das Repository initialisieren. Die `repokey`-Methoden speichern die Schlüsseldatei innerhalb des
Repositories, so dass eine manuelle Sicherung nicht so wichtig ist.

Beachten Sie, dass Sie in beiden Fällen auch die Passphrase haben müssen, um die Archive zu entschlüsseln.

Um das `keyfile` zu holen, führen Sie aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec -e BORG_RSH="ssh -p 23" borgmatic-mailcow borg key export --paper uXXXXX@uXXXXX.your-storagebox.de:mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec -e BORG_RSH="ssh -p 23" borgmatic-mailcow borg key export --paper uXXXXX@uXXXXX.your-storagebox.de:mailcow
    ```

Wobei `uXXXXX@uXXXXX.your-storagebox.de:mailcow` die URI zu Ihrem Repository ist.
