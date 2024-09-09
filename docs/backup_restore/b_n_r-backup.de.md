## Sicherung

### Vorwort

!!! danger "Achtung"

    Die Syntax des Backup Skriptes hat sich mit dem Update 2024-09 drastisch im Rahmen der Neuentwicklung des Skriptes verändert. Sollten automatische Sicherungsprozesse auf Ihrem System laufen ändern Sie diese bitte dementsprechend ab.

    Wichtig zu beachten ist die Auslagerung des `--delete-days` Parameters in die neue und separat auszuführende Funktion `-d`.

    Ebenfalls wichtig: Die neue Variable `--yes`, welche für Automatisierungen verwendet wird.

    Bitte entnehmen Sie die geänderten Syntaxe aus dieser Dokumentation.

### Anleitung

Sie können das mitgelieferte Skript `helper-scripts/backup_and_restore.sh` verwenden, um mailcow automatisch zu sichern.

!!! danger "Achtung"
    **Bitte kopieren Sie dieses Skript nicht an einen anderen Ort.**

Um ein Backup zu starten nutzen Sie bitte den Parameter `-b` oder `--backup` zusammen mit dem Zielpfad für das Backup im Schema `/path/to/backup/folder`.
Geben Sie bitte auch mit `-c` oder `--component` die zu sichernden Komponenten an.

Es folgen einige Beispiele:

```
# Für die Syntax Anzeige oder allgemeine Hilfe
# ./helper-scripts/backup_and_restore.sh --help

# Alle Komponenten nach "/opt/backups" sichern ohne extra Aufforderungen (Ideal für automatische Sicherungen):
./helper-scripts/backup_and_restore.sh --backup /opt/backups --component all --yes

# Die kurze Variante des selbigen Befehls:
./helper-scripts/backup_and_restore.sh -b /opt/backups -c all

# Nur vmail, crypt und mysql Daten sichern
./helper-scripts/backup_and_restore.sh -b /opt/backups -c vmail -c crypt -c mysql

# Nur vmail sichern
./helper-scripts/backup_and_restore.sh -b /opt/backups -c vmail

```

#### Variablen für das Backup/Restore Skript
##### Multithreading
Um das Backup bzw. den Restore mit mehreren Threads zu starten, nutzen Sie bitte den  `--threads <num>` oder den kurzen `-t <num>` Parameter.

Beispiel:

```
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -b /opt/backups -c all -t 14
```

!!! info "Hinweis"

    Bitte behalten Sie Ihre Kernanzahl um 2 reduziert, um genügend CPU-Leistung für mailcow selbst zu lassen. Wenn Sie beispielsweise 16 Kerne haben, übergeben Sie `-t 14`.

##### Backup-Pfad

Sie sollten den Backup-Pfad direkt nach dem Parameter `-b`|`--backup` angeben. Innerhalb dieses Verzeichnisses werden Ordner im Format "*mailcow_DATUM*" erstellt.
Sie sollten diese Ordner nicht umbenennen, um den Wiederherstellungsprozess nicht zu beeinträchtigen.

Um ein Backup unbeaufsichtigt durchzuführen, definieren Sie die Umgebungsvariable MAILCOW_BACKUP_LOCATION, bevor Sie das Skript starten:

```bash

MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all --yes

```

!!! danger "Achtung"
    Bitte genau hinsehen: Die Variable hier heißt `MAILCOW_BACKUP_LOCATION`

!!! tip "Tipp"
    Beide oben genannten Variablen können auch kombiniert werden! Bsp:

    ```bash
    MAILCOW_BACKUP_LOCATION=/opt/backups MAILCOW_BACKUP_RESTORE_THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all --yes
    ```

#### Cronjob

Sie können das Backup-Skript regelmäßig über einen Cronjob laufen lassen. Stellen Sie sicher, dass `MAILCOW_BACKUP_LOCATION` existiert:

```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --backup -c mysql -c crypt -c redis --yes
```

Standardmäßig sendet Cron das komplette Ergebnis jeder Backup-Operation per E-Mail. Wenn Sie möchten, dass cron nur im Fehlerfall (Exit-Code ungleich Null) eine E-Mail sendet, können Sie den folgenden Ausschnitt verwenden. Die Pfade müssen entsprechend Ihrer Einrichtung angepasst werden (dieses Skript ist ein Beitrag eines Benutzers).

Das folgende Skript kann in `/etc/cron.daily/mailcow-backup` platziert werden - vergessen Sie nicht, es mit `chmod +x` als ausführbar zu markieren:

```
#!/bin/sh

# Backup mailcow Docs
# https://docs.mailcow.email/backup_restore/b_n_r-backup/

set -e

OUT="$(mktemp)"
export MAILCOW_BACKUP_LOCATION="/opt/backup"
export MAILCOW_BACKUP_RESTORE_THREADS="2"
SCRIPT="/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh"
PARAMETERS=(-c all)
OPTIONS=(--yes)

# run command
set +e
"${SCRIPT}" "${PARAMETERS[@]}" "${OPTIONS[@]}" 2>&1 > "$OUT"
RESULT=$?

if [ $RESULT -ne 0 ]; then
  echo "${SCRIPT} ${PARAMETERS[@]} ${OPTIONS[@]} encounters an error:"
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
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/external_share/backups/backup_script /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c mysql -c crypt -c redis --yes
5 4 * * * cd /opt/mailcow-dockerized/; /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --delete /external_share/backups/backup_script 3 --yes
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