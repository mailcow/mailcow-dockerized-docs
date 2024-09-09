# Alte Backups Löschen

Seit dem neuen Backup Skript (eingeführt in mailcow Version 2024-09) ist es nun separat (auch ohne Backup Job) möglich, alte Backups zu löschen.

Verwenden Sie dazu den neuen Parameter `--delete` oder die Kurzform `-d` samt der Anzahl der zu behaltenden Tage.

Beispiele:

```bash

# Löscht alte Backups (älter als 3 Tage) aus dem Pfad /opt/backups:
./helper-scripts/backup_and_restore.sh --delete /opt/backups 3

# Löscht alte Backups (älter als 30 Tage) aus dem Pfad /opt/backups
# ohne weitere Eingabe vom Benutzer (Ideal zur Automatisierung):
./helper-scripts/backup_and_restore.sh --delete /opt/backups 30 --yes

```

#### Variablen für das Backup/Restore Skript
##### Backup-Pfad

Um ältere Backups unbeaufsichtigt zu löschen, definieren Sie die Umgebungsvariable `MAILCOW_BACKUP_LOCATION`, bevor Sie das Skript starten:

```bash

MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --delete 30 --yes

```

!!! danger "Achtung"
    Bitte genau hinsehen: Die Variable hier heißt `MAILCOW_BACKUP_LOCATION`

#### Cronjob

Sie können das Backup-Skript regelmäßig über einen Cronjob alte Backups löschen lassen. Stellen Sie sicher, dass `MAILCOW_BACKUP_LOCATION` existiert:

```bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
5 4 * * * cd /opt/mailcow-dockerized/; MAILCOW_BACKUP_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh --delete 3 --yes
```

Standardmäßig sendet Cron das komplette Ergebnis jeder Löschungs-Operation per E-Mail. Wenn Sie möchten, dass cron nur im Fehlerfall (Exit-Code ungleich Null) eine E-Mail sendet, können Sie den folgenden Ausschnitt verwenden. Die Pfade müssen entsprechend Ihrer Einrichtung angepasst werden (dieses Skript ist ein Beitrag eines Benutzers).

Das folgende Skript kann in `/etc/cron.daily/mailcow-backup-delete` platziert werden - vergessen Sie nicht, es mit `chmod +x` als ausführbar zu markieren:

```bash
#!/bin/sh

# Backup Delete mailcow Docs
# https://docs.mailcow.email/backup_restore/b_n_r-delete/

set -e

OUT="$(mktemp)"
export MAILCOW_BACKUP_LOCATION="/opt/backup"
SCRIPT="/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh"
PARAMETERS=(--delete 30)
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