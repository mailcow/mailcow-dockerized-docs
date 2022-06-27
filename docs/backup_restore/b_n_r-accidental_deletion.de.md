Sie haben also ein Postfach gelöscht und haben keine Sicherungskopien?

Wenn Sie Ihren Fehler innerhalb von ein paar Stunden bemerken, können Sie die Daten des Benutzers wahrscheinlich wiederherstellen.

### SOGo

Wir erstellen automatisch tägliche Backups (24 Stunden Intervall ab dem Hochfahren -d) in `/var/lib/docker/volumes/mailcowdockerized_sogo-userdata-backup-vol-1/_data/`.

**Stellen Sie sicher, dass der Benutzer, den Sie wiederherstellen wollen, in Ihrem Mailcow-Backend existiert**. Legen Sie diesen neu an, falls nicht mehr existent.

Kopieren Sie die Datei mit dem Namen des Benutzers, den Sie wiederherstellen wollen, nach `__MAILCOW_DIRECTORY__/data/conf/sogo`.

1\. Kopieren Sie die Sicherung: `cp /var/lib/docker/volumes/mailcowdockerized_sogo-userdata-backup-vol-1/_data/restoreme@example.org __MAILCOW_DIRECTORY__/data/conf/sogo`

2\. Starten Sie `docker-compose exec -u sogo sogo-mailcow sogo-tool restore -F ALL /etc/sogo restoreme@example.org`.

Führen Sie `sogo-tool` ohne Parameter aus, um nach möglichen Wiederherstellungsoptionen zu suchen.

3\. Löschen Sie die kopierte Sicherung, indem Sie `rm __MAILCOW_DIRECTORY__/data/conf/sogo` ausführen

4\. Starten Sie SOGo und Memcached neu: `docker-compose restart sogo-mailcow memcached-mailcow`

### Mail

Im Falle einer versehentlichen Löschung einer Mailbox, können Sie diese (standardmäßig) 5 Tage lang wiederherstellen. Dies hängt von dem `MAILDIR_GC_TIME` Parameter in `mailcow.conf` ab.

Eine gelöschte Mailbox wird in ihrer verschlüsselten Form nach `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/_garbage` kopiert.

Der Ordner innerhalb von `_garbage` folgt der Struktur `[timestamp]_[domain_sanitized][user_sanitized]`, zum Beispiel `1629109708_exampleorgtest` im Falle von test@example.org, das am 1629109708 gelöscht wurde.

Um die Mailbox wiederherzustellen, stellen Sie sicher, dass Sie tatsächlich auf die gleiche Mailcow wiederherstellen, von der sie gelöscht wurde, oder Sie die gleichen Verschlüsselungsschlüssel in `crypt-vol-1` verwenden.

**Stellen Sie sicher, dass der Benutzer, den Sie wiederherstellen wollen, in Ihrer Mailcow existiert**. Legen Sie diesen neu an, wenn der Benutzer fehlt.

Kopieren Sie die Ordner von `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/_garbage/[timestamp]_[domain_sanitized][user_sanitized]` zurück nach `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/[domain]/[user]` und synchronisieren Sie die Ordner neu und berechnen Sie die Quota (Speicherplatz) neu:

```
docker-compose exec dovecot-mailcow doveadm force-resync -u restoreme@example.net '*'
docker-compose exec dovecot-mailcow doveadm quota recalc -u restoreme@example.net
```
