#### Variablen für das Backup/Wiederherstellungsskript
##### Multithreading
Um die Sicherung/Wiederherstellung mit Multithreading zu starten, müssen Sie den Parameter `--threads <num>` oder die Kurzform `-t <num>` hinzufügen.

```bash
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -r /opt/backups -c all -t 14
```

!!! info "Hinweis"
    Die Zahl nach dem `-t` Zeichen gibt die Anzahl der Threads an. Bitte reduzieren Sie Ihre Kernanzahl um 2, um genügend CPU-Leistung für mailcow selbst zu lassen.

##### Backup-Pfad
Sie sollten den Pfad des Backup-Verzeichnisses direkt nach dem Parameter `-r`|`--restore` angeben. Das Skript durchsucht das Verzeichnis nach allen Backups und fordert Sie anschließend auf, das Backup auszuwählen, das Sie wiederherstellen möchten.

Um eine Wiederherstellung unbeaufsichtigt durchzuführen, definieren Sie die Umgebungsvariable `MAILCOW_RESTORE_LOCATION`, bevor Sie das Skript starten:

```bash
MAILCOW_RESTORE_LOCATION=/opt/backups /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all
```

!!! danger "Achtung"
    Bitte genau hinsehen: Die Variable hier heißt `MAILCOW_RESTORE_LOCATION`

Oder übergeben Sie den Parameter `-r`|`--restore` mit dem Wiederherstellungspfad als Argument an das Skript:

```bash
/opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -r /opt/backups -c all
```

!!! tip
    Beide oben genannten Variablen können auch kombiniert werden! Beispiel:
    ```bash
    MAILCOW_RESTORE_LOCATION=/opt/backups MAILCOW_BACKUP_RESTORE_THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c all
    ```

!!! tip
    Sie sollten die Komponente(n), die Sie wiederherstellen möchten, mit `-c` oder `--component` angeben, oder einfach `-c all` verwenden! Beispiel:
    ```bash
    MAILCOW_RESTORE_LOCATION=/opt/backups MAILCOW_BACKUP_RESTORE_THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh -c vmail -c crypt -c mysql
    ```

#### Daten wiederherstellen

!!! danger
    **Bitte kopieren Sie dieses Skript nicht an einen anderen Ort.**

!!! danger "Gefahr für ältere Installationen"
    Bevor Sie Ihr mailcow-System auf einem neuen Server und einem sauberen mailcow-dockerized-Ordner wiederherstellen, überprüfen Sie bitte, ob der Wert `MAILDIR_SUB` in Ihrer mailcow.conf gesetzt ist. Wenn dieser Wert nicht gesetzt ist, setzen Sie ihn nicht auf Ihrem neuen mailcow Server oder entfernen Sie ihn, da sonst **KEINE** E-Mails angezeigt werden. Dovecot lädt E-Mails aus dem angegebenen Unterordner des Maildir-Volumes unter `$DOCKER_VOLUME_PATH/mailcowdockerized_vmail-vol-1` und wenn es im Vergleich zum Originalzustand eine Änderung gibt, werden keine E-Mails verfügbar sein.

Um eine Wiederherstellung durchzuführen, **starten Sie mailcow**, und verwenden Sie das Skript mit `--restore` oder `-r` zusammen mit dem Pfad zum Backup-Verzeichnis:

```bash
# Syntax:
./helper-scripts/backup_and_restore.sh -r /opt/backups -c all
```

Alle verfügbaren Backups im angegebenen Ordner (in unserem Beispiel `/opt/backups`) werden dann angezeigt:

``` { .bash .no-copy }
Found project name mailcowdockerized
Using /opt/backups as restore location...
[ 1 ] - /opt/backups/mailcow-2023-12-11-13-27-14/
[ 2 ] - /opt/backups/mailcow-2023-12-11-14-02-06/
```

Nun können Sie die Nummer des Backups eingeben, das Sie wiederherstellen möchten, in diesem Beispiel das zweite Backup:

``` { .bash .no-copy }
Select a restore point: 2
```

Das Skript zeigt nun alle gesicherten Komponenten an, die es wiederherstellen wird.
In unserem Fall haben wir `all` für den Backup-Prozess ausgewählt, daher werden diese Komponenten hier angezeigt:

``` { .bash .no-copy }
Matching available components to restore:
[ 1 ] - Crypt data
[ 2 ] - Rspamd data
[ 3 ] - Mail directory (/var/vmail)
[ 4 ] - Redis DB
[ 5 ] - Postfix data
[ 6 ] - SQL DB

Restoring will start in 5 seconds. Press Ctrl+C to stop.
```

Nun warten Sie 5 Sekunden, bevor die oben genannten Komponenten wiederhergestellt werden! Wenn Sie den Wiederherstellungsprozess abbrechen möchten, drücken Sie `Ctrl+C`, um den Prozess zu stoppen.

??? warning "Wenn Sie auf eine andere Architektur wiederherstellen möchten..."
    Wenn Sie das Backup auf einer anderen Architektur erstellt haben, z. B. x86, und dieses Backup jetzt auf ARM64 wiederherstellen möchten, wird das Backup von Rspamd als inkompatibel angezeigt und kann nicht einzeln ausgewählt werden. Beim Wiederherstellen aller Komponenten wird die Wiederherstellung von Rspamd ebenfalls übersprungen.

    Beispiel eines inkompatiblen Rspamd-Backups im Auswahlmenü:

    ``` { .bash .no-copy }
    [...]
    [ NaN ] - Rspamd data (incompatible Arch, cannot restore it)
    [...]
    ```

Nun wird mailcow die von Ihnen ausgewählten Backups wiederherstellen. Bitte beachten Sie, dass die Wiederherstellung je nach Größe der Backups einige Zeit in Anspruch nehmen kann.
