# Cold-standby-Backup

mailcow bietet eine einfache Möglichkeit, eine konsistente Kopie von sich selbst zu erstellen, die per rsync an einen entfernten Ort ohne Ausfallzeit übertragen werden kann.

Dies kann auch verwendet werden, um Ihre mailcow auf einen neuen Server zu übertragen.

## Das sollten Sie wissen

Das bereitgestellte Skript funktioniert auf Standardinstallationen.

Es kann versagen, wenn Sie nicht unterstützte Volume Overrides verwenden. Wir unterstützen das nicht und wir werden keine Hacks einbauen, die das unterstützen. Bitte erstellen und pflegen Sie einen Fork, wenn Sie Ihre Änderungen beibehalten wollen.

Das Skript wird **die gleichen Pfade** wie Ihre Standard-mailcow-Installation verwenden. Das ist das mailcow-Basisverzeichnis - für die meisten Nutzer `/opt/mailcow-dockerized` - sowie die Mountpoints.

Um die Pfade Ihrer Quellvolumes zu finden, verwenden wir `docker inspect` und lesen das Zielverzeichnis jedes Volumes, das mit Ihrem mailcow compose Projekt verbunden ist. Das bedeutet, dass wir auch Volumes übertragen, die Sie in einer Override-Datei hinzugefügt haben. Lokale Bind-Mounts können funktionieren, müssen aber nicht.

Das Skript verwendet rsync mit dem `--delete` Flag. Das Ziel wird eine exakte Kopie der Quelle sein.

`mariabackup` wird verwendet, um eine konsistente Kopie des SQL-Datenverzeichnisses zu erstellen.

Nach dem Rsync der Daten führen wir folgenden Befehl aus (anhand der gesetzten docker compose Version in der mailcow.conf) und entfernen alte Image-Tags aus dem Ziel:

=== "docker compose (Plugin)"

    ``` bash
    docker compose pull
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose pull
    ```

Ihre Quelle wird zu keinem Zeitpunkt verändert.

**Sie sollten sicherstellen, dass Sie die gleiche `/etc/docker/daemon.json` auf dem entfernten Ziel verwenden.**

Sie sollten keine Festplatten-Snapshots (z. B. über ZFS, LVM usw.) auf dem Ziel ausführen, während dieses Skript ausgeführt wird.

Die Versionierung ist nicht Teil dieses Skripts, wir verlassen uns auf das Ziel (Snapshots oder Backups). Sie können dafür auch jedes andere Tool verwenden.

## Vorbereiten

Sie benötigen ein SSH-fähiges Ziel und eine Schlüsseldatei, um sich mit diesem Ziel zu verbinden. Der Schlüssel sollte nicht durch ein Passwort geschützt sein, damit das Skript unbeaufsichtigt arbeiten kann.

In Ihrem mailcow-Basisverzeichnis, z.B. `/opt/mailcow-dockerized`, finden Sie eine Datei `create_cold_standby.sh`.

Bearbeiten Sie diese Datei und ändern Sie die exportierten Variablen:

```
export REMOTE_SSH_KEY=/pfad/zum/keyfile
export REMOTE_SSH_PORT=22
export REMOTE_SSH_HOST=mailcow-backup.host.name
```

Der Schlüssel muss im Besitz von root sein und darf nur von diesem gelesen werden können.

Sowohl die Quelle als auch das Ziel benötigen `rsync` >= v3.1.0.
Das Ziel muss über Docker und docker compose **v2** verfügen.

Das Skript wird Fehler automatisch erkennen und sich beenden.

Sie können die Verbindung testen, indem Sie `ssh mailcow-backup.host.name -p22 -i /path/to/keyfile` ausführen.

??? warning "Wichtig für den Wechsel auf eine andere Architektur"

    Wenn Sie planen mit dem Cold Standby Skript eine Migration von x86 auf ARM64 bzw. umgekehrt zu machen, lassen Sie das Skript einfach normal laufen. Das Skript wird automatisch erkennen, ob es unterschiede zwischen der Quelle und dem Ziel im Bezug auf die Architektur gibt und sich dementsprechend verhalten und betroffene Volumes im Sync auslassen.

    Dies hat den Hintergrund, dass Rspamd Regexp Einträge von unseren Konfigurationen auf die entsprechende Plattform kompiliert und bei einem Plattform Wechsel diese Cache Dateien nicht gelesen werden können. Rspamd würde daraufhin abstürzen und eine sinnvolle Nutzung mailcow's damit nicht ermöglichen. Deswegen wird das `rspamd-vol-1` (Rspamd Volume) im Cold Standby ausgelassen.

    **Keine Sorge!** Rspamd wird trotzdem nach der Migration korrekt funktionieren, da diese Cache Dateien selbstständig für die neue Plattform generiert werden.

## Backup und Aktualisierung des Cold-Standby

Starten Sie das erste Backup, dies kann je nach Verbindung eine Weile dauern:

```
bash /opt/mailcow-dockerized/create_cold_standby.sh
```

Das war einfach, nicht wahr?

Das Aktualisieren des Cold-Standby ist genauso einfach:

```
bash /opt/mailcow-dockerized/create_cold_standby.sh
```

Es ist derselbe Befehl.

## Automatisierte Backups mit cron

Stellen Sie zunächst sicher, dass der `cron` Dienst aktiviert ist und läuft:

```
systemctl enable cron.service && systemctl start cron.service
```

Um die Backups auf dem Cold-Standby-Server zu automatisieren, können Sie einen Cron-Job verwenden. Um die Cron-Jobs für den Root-Benutzer zu bearbeiten, führen Sie aus:

```
crontab -e
```

Fügen Sie die folgenden Zeilen hinzu, um den Cold-Standby-Server täglich um 03:00 Uhr zu synchronisieren. In diesem Beispiel werden Fehler der letzten Ausführung in einer Datei protokolliert.

```
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

0 3 * * * bash /opt/mailcow-dockerized/create_cold_standby.sh 2> /var/log/mailcow-coldstandby-sync.log
```

Wenn korrekt gespeichert, sollte der Cron-Job durch folgende Eingabe angezeigt werden:

```
crontab -l
```