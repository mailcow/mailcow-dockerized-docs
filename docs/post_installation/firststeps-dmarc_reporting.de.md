Die DMARC-Berichterstattung erfolgt über das Rspamd DMARC-Modul.

Die Rspamd-Dokumentation finden Sie hier: https://rspamd.com/doc/modules/dmarc.html

**Wichtig:**

1. Ändern Sie `example.com`, `mail.example.com` und `Example` so, dass sie Ihrer Einrichtung entsprechen

2. Die DMARC-Berichterstattung erfordert zusätzliche Aufmerksamkeit, insbesondere in den ersten Tagen

3. Alle empfangenden Domains, die auf mailcow gehostet werden, senden von einer Reporting-Domain. Es wird empfohlen, die übergeordnete Domain Ihres `MAILCOW_HOSTNAME` zu verwenden:
    - Wenn Ihr `MAILCOW_HOSTNAME` `mail.example.com` ist, ändern Sie die folgende Konfiguration in `domain = "example.com";`
    - Setzen Sie `email` gleich, z.B. `email = "noreply-dmarc@example.com";`

4. Es ist optional, aber empfohlen, einen E-Mail-Benutzer `noreply-dmarc` in mailcow zu erstellen, um Bounces zu behandeln.

## Aktivieren Sie DMARC-Berichterstattung

Erstellen Sie die Datei `data/conf/rspamd/local.d/dmarc.conf` und setzen Sie den folgenden Inhalt:

```
reporting {
    enabled = true;
    email = 'noreply-dmarc@example.com';
    domain = 'example.com';
    org_name = 'Example';
    helo = 'rspamd';
    smtp = 'postfix';
    smtp_port = 25;
    from_name = 'Example DMARC Report';
    msgid_from = 'rspamd.mail.example.com';
    max_entries = 2k;
    keys_expire = 2d;
}
```

Erstellen oder ändern Sie `docker-compose.override.yml` im mailcow-dockerized Basisverzeichnis:

```
version: '2.1'

services:
  rspamd-mailcow:
    environment:
      - MASTER=${MASTER:-y}
    labels:
      ofelia.enabled: "true"
      ofelia.job-exec.rspamd_dmarc_reporting.schedule: "@every 24h"
      ofelia.job-exec.rspamd_dmarc_reporting.command: "/bin/bash -c \"[[ $${MASTER} == y ]] && /usr/bin/rspamadm dmarc_report > /var/lib/rspamd/dmarc_reports_last_log 2>&1 || exit 0\""
  ofelia-mailcow:
    depends_on:
      - rspamd-mailcow
```

Starte `docker-compose up -d`

## Senden Sie eine Kopie der Berichte an sich selbst

Um eine versteckte Kopie der von Rspamd erzeugten Berichte zu erhalten, können Sie eine `bcc_addrs` Liste im `reporting` Konfigurationsabschnitt von `data/conf/rspamd/local.d/dmarc.conf` setzen:

```
reporting {
    enabled = true;
    email = 'noreply-dmarc@example.com';
    bcc_addrs = ["noreply-dmarc@example.com", "parsedmarc@example.com"];
[...]
```

Rspamd lädt Änderungen in Echtzeit, so dass Sie den Container zu diesem Zeitpunkt nicht neu starten müssen.

Dies kann nützlich sein, wenn Sie...

- ...überprüfen wollen, ob Ihre DMARC-Berichte korrekt und authentifiziert gesendet werden.
- ...Ihre eigenen Berichte analysieren wollen, um Statistiken zu erhalten, z.B. um sie mit ParseDMARC oder anderen Analysesystemen zu verwenden.

## Fehlersuche

Prüfen Sie, wann der Berichtsplan zuletzt ausgeführt wurde:

```
docker-compose exec rspamd-mailcow date -r /var/lib/rspamd/dmarc_reports_last_log
```

Sehen Sie sich die letzte Berichtsausgabe an:

```
docker-compose exec rspamd-mailcow cat /var/lib/rspamd/dmarc_reports_last_log
```

Manuelles Auslösen eines DMARC-Berichts:

```
docker-compose exec rspamd-mailcow rspamadm dmarc_report
```

Bestätigen Sie, dass Rspamd Daten in Redis aufgezeichnet hat:

```
docker-compose exec redis-mailcow redis-cli KEYS 'dmarc;*'
docker-compose exec redis-mailcow redis-cli HGETALL "dmarc;example.com;20211231"
```

## Ändern Sie die Häufigkeit der DMARC-Berichte

Im obigen Beispiel werden die Berichte einmal alle 24 Stunden gesendet.

Der Olefia-Zeitplan hat die gleiche Implementierung wie `cron` in Go, die unterstützte Syntax ist beschrieben in [cron Documentation](https://pkg.go.dev/github.com/robfig/cron)

Um den Zeitplan zu ändern:

1. Bearbeiten Sie `docker-compose.override.yml` und stellen Sie `ofelia.job-exec.rspamd_dmarc_reporting.schedule: "@every 24h"` auf einen gewünschten Wert, zum Beispiel auf `"@midnight"`

2. Führen Sie `docker-compose up -d` aus.

3. Führen Sie `docker-compose restart ofelia-mailcow` aus

## DMARC-Berichterstattung deaktivieren

Zum Deaktivieren der Berichterstattung:

1. Setzen Sie `enabled` auf `false` in `data/conf/rspamd/local.d/dmarc.conf`.

2. Machen Sie Änderungen in `docker-compose.override.yml` an `rspamd-mailcow` und `ofelia-mailcow` rückgängig

3. Führen Sie `docker-compose up -d` aus
