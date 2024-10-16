### Wiederherstellung
#### Variablen für Backup/Restore Skript
##### Multithreading
Seit dem 2022-10 Update ist es möglich das Skript mit Multithreading Support laufen zu lassen. Dies lässt sich sowohl für Backups aber auch für Restores nutzen.

Um das Backup/den Restore mit Multithreading zu starten muss `THREADS` als Umgebungsvariable vor dem Befehl zum starten hinzugefügt werden.

```
THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore
```
Die Anzahl hinter dem `=` Zeichen gibt dabei dann die Thread Anzahl an. Nehmen Sie bitte immer ihre Kernanzahl -2 um mailcow selber noch genug CPU Leistung zu lassen.

##### Backup Pfad
Das Skript wird Sie nach einem Speicherort für die Sicherung fragen. Innerhalb dieses Speicherortes wird es Ordner im Format "mailcow_DATE" erstellen.
Sie sollten diese Ordner nicht umbenennen, um den Wiederherstellungsprozess nicht zu stören.

Um ein Backup unbeaufsichtigt durchzuführen, definieren Sie MAILCOW_BACKUP_LOCATION als Umgebungsvariable, bevor Sie das Skript starten:

```bash
MAILCOW_BACKUP_LOCATION=/opt/backup /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh backup all
```

!!! tip "Tipp"
    Beide oben genannten Variablen können auch kombiniert werden! Bsp:
    ```bash
    MAILCOW_BACKUP_LOCATION=/opt/backup THREADS=14 /opt/mailcow-dockerized/helper-scripts/backup_and_restore.sh restore
    ```

#### Wiederherstellung der Daten

!!! danger "Achtung"
    **Bitte kopieren Sie dieses Skript nicht an einen anderen Ort.**

!!! warning "Wichtig"
    Um ein Backup auf ein neues System wiederherzustellen **muss mailcow initialisiert sein und gestartet sein!** Installieren Sie also mailcow nach der Anleitung neu und warten Sie mit der Wiederherstellung so lange, bis mailcow in einem leeren Zustand läuft.

!!! danger "Achtung für ältere Installationen"
    Bitte schauen Sie **VOR** der Wiederherstellung Ihres mailcow Systemes auf einen neuen Server und einem sauberen mailcow-dockerized Ordner, ob in Ihrer mailcow.conf der Wert `MAILDIR_SUB` gesetzt ist. Falls dieser nicht gesetzt ist, so setzen Sie diesen auch bitte in Ihrer neuen mailcow nicht, bzw. entfernen diesen, da sonst **KEINE** E-Mails angezeigt werden. Dovecot lädt E-Mails aus dem besagtem Unterordner des Maildir Volumes unter `$DOCKER_VOLUME_PFAD/mailcowdockerized_vmail-vol-1` und bei Änderung im Vergleich zum Ursprungszustand sind dort keine Mails vorhanden.

Um eine Wiederherstellung durchzuführen, **starten Sie mailcow**, verwenden Sie das Skript mit "restore" als ersten Parameter.

``` { .yaml .no-copy }
# Syntax:
# ./helper-scripts/backup_and_restore.sh restore

```

Das Skript wird Sie nach einem Speicherort für die Sicherung der mailcow_DATE-Ordner fragen:

``` { .bash .no-copy }
Backup location (absolute path, starting with /): /opt/backup
```

Anschließend werden alle verfügbaren Backups in dem angegebenen Ordner (in unserem Beispiel `/opt/backup`) angezeigt:

``` { .bash .no-copy }
Found project name mailcowdockerized
[ 1 ] - /opt/backup/mailcow-2023-12-11-13-27-14/
[ 2 ] - /opt/backup/mailcow-2023-12-11-14-02-06/
```

Nun können Sie die Nummer Ihres Backups angeben, welches Sie Wiederherstellen wollen, in diesem Beispiel die 2:

``` { .bash .no-copy }
Select a restore point: 2
```

Das Skript wird nun alle gesicherten Komponenten Anzeigen, die Sie wiederherstellen können, in unserem Fall haben wir beim Backup Prozess `all` also Alles gewählt, dementsprechend taucht das hier nun auf:

``` { .bash .no-copy }
[ 0 ] - all
[ 1 ] - Crypt data
[ 2 ] - Rspamd data
[ 3 ] - Mail directory (/var/vmail)
[ 4 ] - Redis DB
[ 5 ] - Postfix data
[ 6 ] - SQL DB
```

Auch hier wählen wir nun wieder die Komponente aus, die wir wiederherstellen wollen. Option 0 stellt **ALLES** wieder her.

??? warning "Wenn Sie auf eine andere Architektur wiederherstellen wollen..."
    Sollten Sie das Backup auf einer anderen Architektur bspw. x86 gemacht haben und wollen dieses Backup nun auf ARM64 wiederherstellen, so wird das Backup von Rspamd als inkompatibel angezeigt und ist nicht einzeln anwählbar. Bei der Wiederherstellung mit Aufruf der Taste 0 wird die Wiederherstellung von Rspamd ebenfalls übersprungen.

    Beispiel für inkompatibles Rspamd Backup im Auswahl Menü:

    ``` { .bash .no-copy } 
    [...]
    [ NaN ] - Rspamd data (incompatible Arch, cannot restore it)
    [...]
    ```

Nun wird mailcow die von Ihnen ausgewählten Sicherungen wiederherstellen. Bitte beachten Sie, dass je nach Größe der Sicherungen die Wiederherstellung eine gewisse Zeit in Anspruch nehmen kann.