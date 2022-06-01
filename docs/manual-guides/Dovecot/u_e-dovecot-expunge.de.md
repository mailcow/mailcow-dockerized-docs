Wenn Sie alte Mails aus den Ordnern `.Junk` oder `.Trash` löschen wollen oder vielleicht alle gelesenen Mails, die älter als eine bestimmte Zeitspanne sind, können Sie das dovecot-Tool doveadm [man doveadm-expunge](https://wiki.dovecot.org/Tools/Doveadm/Expunge) verwenden.

## Der manuelle Weg

Dann wollen wir mal loslegen:

Löschen Sie die Mails eines Benutzers im Junk-Ordner, die **gelesen** und **älter** als 4 Stunden sind

```
docker-compose exec dovecot-mailcow doveadm expunge -u 'mailbox@example.com' mailbox 'Junk' SEEN not SINCE 4h
```

Lösche **alle** Mails des Benutzers im Junk-Ordner, die **älter** als 7 Tage sind

```
docker-compose exec dovecot-mailcow doveadm expunge -A mailbox 'Junk' savedbefore 7d
```

Löscht **alle** Mails (aller Benutzer) in **allen** Ordnern, die **älter** als 52 Wochen sind (internes Datum der Mail, nicht das Datum, an dem sie auf dem System gespeichert wurde => `before` statt `savedbefore`). Nützlich zum Löschen sehr alter Mails in allen Benutzern und Ordnern (daher besonders nützlich für GDPR-Compliance).

```
docker-compose exec dovecot-mailcow doveadm expunge -A mailbox % before 52w
```

Löschen von Mails in einem benutzerdefinierten Ordner **innerhalb** des Posteingangs eines Benutzers, die **nicht** gekennzeichnet und **älter** als 2 Wochen sind

```
docker-compose exec dovecot-mailcow doveadm expunge -u 'mailbox@example.com' mailbox 'INBOX/custom-folder' not FLAGGED not SINCE 2w
```

!!! info
    Für mögliche [Zeitspannen](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_date_specification) oder [SearchQuery](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_search_keys) schauen Sie bitte in [man doveadm-search-query](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery)

## Job-Scheduler

### über das Host-System cron

Wenn Sie eine solche Aufgabe automatisieren wollen, können Sie einen Cron-Job auf Ihrem Rechner erstellen, der ein Skript wie das folgende aufruft:

```
#!/bin/bash
# Pfad zu mailcow-dockerized, z.B. /opt/mailcow-dockerized
cd /pfad/zu/ihrem/mailcow-dockerized

/usr/local/bin/docker-compose exec -T dovecot-mailcow doveadm expunge -A mailbox 'Junk' savedbefore 2w
/usr/local/bin/docker-compose exec -T dovecot-mailcow doveadm expunge -A mailbox 'Junk' SEEN not SINCE 12h
[...]
```

Um einen Cronjob zu erstellen, können Sie `crontab -e` ausführen und etwas wie das Folgende einfügen, um ein Skript auszuführen:

```
# Jeden Tag um 04:00 Uhr morgens ausführen.
0 4 * * * /pfad/zu/ihr/expunge_mailboxes.sh
```

### über Docker Job Scheduler

Um dies mit einem Docker-Job-Scheduler zu archivieren, verwenden Sie diese docker-compose.override.yml mit Ihrer Mailcow: 


```
version: '2.1'

services:
  
  ofelia:
    image: mcuadros/ofelia:latest
    restart: always
    command: daemon --docker
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro   
    network_mode: none

  dovecot-mailcow:
    labels:
      - "ofelia.enabled=true"
      - "ofelia.job-exec.dovecot-expunge-trash.schedule=0 4 * * *"
      - "ofelia.job-exec.dovecot-expunge-trash.command=doveadm expunge -A mailbox 'Junk' savedbefore 2w"
      - "ofelia.job-exec.dovecot-expunge-trash.tty=false"

```

Der Job-Controller braucht nur Zugriff auf den Docker Control Socket, um das Verhalten von "exec" zu emulieren. Dann fügen wir unserem Dovecot-Container ein paar Labels hinzu, um den Job-Scheduler zu aktivieren und ihm in einem Cron-kompatiblen Scheduling-Format mitzuteilen, wann er laufen soll. Wenn Sie Probleme mit dem Scheduling-String haben, können Sie [crontab guru](https://crontab.guru/) verwenden. 
Diese docker-compose.override.yml löscht jeden Tag um 4 Uhr morgens alle Mails, die älter als 2 Wochen sind, aus dem Ordner "Junk". Um zu sehen, ob alles richtig gelaufen ist, können Sie nicht nur in Ihrer Mailbox nachsehen, sondern auch im Docker-Log von Ofelia, ob es etwa so aussieht:

```
common.go:124 ▶ NOTICE [Job "dovecot-expunge-trash" (8759567efa66)] Started - doveadm expunge -A mailbox 'Junk' savedbefore 2w,
common.go:124 ▶ NOTICE [Job "dovecot-expunge-trash" (8759567efa66)] Finished in "285.032291ms", failed: false, skipped: false, error: none,
```

Wenn der Vorgang fehlgeschlagen ist, wird dies angegeben und die Ausgabe von doveadm im Protokoll aufgeführt, um Ihnen die Fehlersuche zu erleichtern.

Falls Sie weitere Jobs hinzufügen wollen, stellen Sie sicher, dass Sie den "dovecot-expunge-trash"-Teil nach "ofelia.job-exec." in etwas anderes ändern, er definiert den Namen des Jobs. Die Syntax der Labels finden Sie unter [mcuadros/ofelia](https://github.com/mcuadros/ofelia).

