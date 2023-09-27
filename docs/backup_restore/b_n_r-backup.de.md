### Sicherung

#### Anleitung

Sie können das mitgelieferte Skript `helper-scripts/backup_and_restore.sh` verwenden, um mailcow automatisch zu sichern.

Bitte kopieren Sie dieses Skript nicht an einen anderen Ort.

Um ein Backup zu starten, geben Sie "backup" als ersten Parameter an und entweder eine oder mehrere zu sichernde Komponenten als folgende Parameter.
Sie können auch "all" als zweiten Parameter verwenden, um alle Komponenten zu sichern. Fügen Sie `--delete-days n` an, um Sicherungen zu löschen, die älter als n Tage sind.

```
# Syntax:
# ./helper-scripts/backup_and_restore.sh backup (vmail|crypt|redis|rspamd|postfix|mysql|all|--delete-days)

# Alles sichern, Sicherungen älter als 3 Tage löschen
./helper-scripts/backup_and_restore.sh backup all --delete-days 3

# vmail-, crypt- und mysql-Daten sichern, Sicherungen löschen, die älter als 30 Tage sind
./helper-scripts/backup_and_restore.sh backup vmail crypt mysql --delete-days 30

# vmail sichern
./helper-scripts/backup_and_restore.sh backup vmail

```

#### Variablen für Backup/Restore Skript
##### Multithreading
Seit dem 2022-10 Update ist es möglich das Skript mit Multithreading Support laufen zu lassen. Dies lässt sich sowohl für Backups aber auch für Restores nutzen.

Um das Backup/den Restore mit Multithreading zu starten muss `THREADS` als Umgebungsvariable vor dem Befehl zum starten hinzugefügt werden.

```
THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
```
Die Anzahl hinter dem `=` Zeichen gibt dabei dann die Thread Anzahl an. Nehmen Sie bitte immer ihre Kernanzahl -2 um mailcow selber noch genug CPU Leistung zu lassen.

##### Backup Pfad
Das Skript wird Sie nach einem Speicherort für die Sicherung fragen. Innerhalb dieses Speicherortes wird es Ordner im Format "mailcow_DATE" erstellen.
Sie sollten diese Ordner nicht umbenennen, um den Wiederherstellungsprozess nicht zu stören.

Um ein Backup unbeaufsichtigt durchzuführen, definieren Sie MAILCOW_BACKUP_LOCATION als Umgebungsvariable, bevor Sie das Skript starten:

```
MAILCOW_BACKUP_LOCATION=/opt/backup /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
```

!!! tip "Tipp"
        Beide oben genannten Variablen können auch kombiniert werden! Bsp:
        ```
        MAILCOW_BACKUP_LOCATION=/opt/backup THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
        ```

#### Cronjob

Sie können das Backup-Skript regelmäßig über einen Cronjob laufen lassen. Stellen Sie sicher, dass `BACKUP_LOCATION` existiert:

```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/mnt/mailcow_backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup mysql crypt redis --delete-days 3
```

Standardmäßig sendet Cron das komplette Ergebnis jeder Backup-Operation per E-Mail. Wenn Sie möchten, dass cron nur im Fehlerfall (Exit-Code ungleich Null) eine E-Mail sendet, können Sie den folgenden Ausschnitt verwenden. Die Pfade müssen entsprechend Ihrer Einrichtung angepasst werden (dieses Skript ist ein Beitrag eines Benutzers).

Das folgende Skript kann in `/etc/cron.daily/mailcow-backup` platziert werden - vergessen Sie nicht, es mit `chmod +x` als ausführbar zu markieren:

```
#!/bin/sh

# Backup mailcow data
# https://docs.mailcow.email/b_n_r_backup/

set -e

OUT="$(mktemp)"
export MAILCOW_BACKUP_LOCATION="/opt/backup"
SCRIPT="/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh"
PARAMETERS="backup all"
OPTIONS="--delete-days 30"

# run command
set +e
"${SCRIPT}" ${PARAMETERS} ${OPTIONS} 2>&1 > "$OUT"
RESULT=$?

if [ $RESULT -ne 0 ]
    then
            echo "${SCRIPT} ${PARAMETERS} ${OPTIONS} encounters an error:"
            echo "RESULT=$RESULT"
            echo "STDOUT / STDERR:"
            cat "$OUT"
fi
```

# Backup-Strategie mit rsync und mailcow Backup-Skript

Erstellen Sie das Zielverzeichnis für mailcows Hilfsskript:
```
mkdir -p /external_share/backups/backup_script
```

Cronjobs erstellen:
```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
25 1 * * * rsync -aH --delete /opt/mailcow-dockerized /external_share/backups/mailcow-dockerized
40 2 * * * rsync -aH --delete /var/lib/docker/volumes /external_share/backups/var_lib_docker_volumes
5 4 * * * cd /opt/mailcow-dockerized/; BACKUP_LOCATION=/external_share/backups/backup_script /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup mysql crypt redis --delete-days 3
# Wenn Sie wollen, benutzen Sie das Werkzeug acl, um die Berechtigungen einiger/aller Ordner/Dateien zu sichern: getfacl -Rn /path
```

Am Zielort (in diesem Fall `/external_share/backups`) möchten Sie vielleicht Snapshot-Möglichkeiten haben (ZFS, Btrfs usw.). Machen Sie täglich einen Snapshot und bewahren Sie ihn für n Tage auf, um ein konsistentes Backup zu erhalten.
Führen Sie **kein** rsync auf eine Samba-Freigabe durch, Sie müssen die richtigen Berechtigungen behalten!

Zum Wiederherstellen müssen Sie rsync einfach in umgekehrter Richtung ausführen und Docker neu starten, um die Volumes erneut zu lesen. Führen Sie folgende Befehle aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose pull
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose pull
    docker-compose up -d
    ```

Wenn Sie Glück haben, können Redis und MariaDB die inkonsistenten Datenbanken automatisch reparieren (wenn sie inkonsistent _sind_).
Im Falle einer beschädigten Datenbank müssen Sie das Hilfsskript verwenden, um die inkonsistenten Elemente wiederherzustellen. Wenn die Wiederherstellung fehlschlägt, versuchen Sie, die Sicherungen zu extrahieren und die Dateien manuell zurück zu kopieren. Behalten Sie die Dateiberechtigungen bei!