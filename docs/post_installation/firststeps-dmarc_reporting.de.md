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
      ofelia.job-exec.rspamd_dmarc_reporting_yesterday.schedule: "@every 24h"
      ofelia.job-exec.rspamd_dmarc_reporting_yesterday.command: "/bin/bash -c \"[[ $${MASTER} == y ]] && /usr/bin/rspamadm dmarc_report $(date --date yesterday '+%Y%m%d') > /var/lib/rspamd/dmarc_reports_last_log 2>&1 || exit 0\""
  ofelia-mailcow:
    depends_on:
      - rspamd-mailcow
```

Starten Sie den mailcow Stack mit:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

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

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow date -r /var/lib/rspamd/dmarc_reports_last_log
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow date -r /var/lib/rspamd/dmarc_reports_last_log
    ```

Sehen Sie sich die letzte Berichtsausgabe an:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow cat /var/lib/rspamd/dmarc_reports_last_log
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow cat /var/lib/rspamd/dmarc_reports_last_log
    ```

Manuelles Auslösen eines DMARC-Berichts:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow rspamadm dmarc_report
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow rspamadm dmarc_report
    ```

Bestätigen Sie, dass Rspamd Daten in Redis aufgezeichnet hat:
Ändern Sie `20220428` in Ihr gewünschtes Datum zum überprüfen.

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec redis-mailcow redis-cli SMEMBERS "dmarc_idx;20220428"
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec redis-mailcow redis-cli SMEMBERS "dmarc_idx;20220428"
    ```

Nehmen Sie eine der Zeilen aus der Ausgabe, die Sie interessiert, und fordern Sie sie an, z. B.:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec redis-mailcow redis-cli ZRANGE "dmarc_rpt;microsoft.com;mailto:d@rua.agari.com;20220428" 0 49
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec redis-mailcow redis-cli ZRANGE "dmarc_rpt;microsoft.com;mailto:d@rua.agari.com;20220428" 0 49
    ```


## Ändern Sie die Häufigkeit der DMARC-Berichte

Im obigen Beispiel werden die Berichte einmal alle 24 Stunden sowie für den gestrigen Tag versendet. Dies ist für die meisten Konfigurationen ausreichend.

Wenn Sie ein großes E-Mail-Aufkommen haben und die DMARC-Berichterstattung mehr als einmal am Tag durchführen wollen, müssen Sie einen zweiten Zeitplan erstellen und ihn mit `dmarc_report $(date '+%Y%m%d')` ausführen, um den aktuellen Tag zu verarbeiten. Sie müssen sicherstellen, dass der erste Lauf an jedem Tag auch den letzten Bericht vom Vortag verarbeitet, also muss er zweimal gestartet werden, einmal mit `$(date --date yesterday '+%Y%m%d')` um `0 5 0 * * *` (00:05 AM) und dann mit `$(date '+%Y%m%d')` mit dem gewünschten Intervall.

Der Ofelia-Zeitplan hat die gleiche Implementierung wie `cron` in Go, die unterstützte Syntax ist beschrieben in [cron Documentation](https://pkg.go.dev/github.com/robfig/cron)

Um den Zeitplan zu ändern:

1. `docker-compose.override.yml` bearbeiten:
    ```
    version: '2.1'

    services:
      rspamd-mailcow:
        environment:
          - MASTER=${MASTER:-y}
        labels:
          ofelia.enabled: "true"
          ofelia.job-exec.rspamd_dmarc_reporting_yesterday.schedule: "0 5 0 * * *"
          ofelia.job-exec.rspamd_dmarc_reporting_yesterday.command: "/bin/bash -c \"[[ $${MASTER} == y ]] && /usr/bin/rspamadm dmarc_report $(date --date yesterday '+%Y%m%d') > /var/lib/rspamd/dmarc_reports_last_log 2>&1 || exit 0\""
          ofelia.job-exec.rspamd_dmarc_reporting_today.schedule: "@every 12h"
          ofelia.job-exec.rspamd_dmarc_reporting_today.command: "/bin/bash -c \"[[ $${MASTER} == y ]] && /usr/bin/rspamadm dmarc_report $(date '+%Y%m%d') > /var/lib/rspamd/dmarc_reports_last_log 2>&1 || exit 0\""
      ofelia-mailcow:
        depends_on:
          - rspamd-mailcow
    ```

2. Starten Sie die betroffenen Container neu:

    === "docker compose (Plugin)"

        ``` bash
        docker compose up -d
        ```

    === "docker-compose (Standalone)"

        ``` bash
        docker-compose up -d
        ```

3. Führen Sie einen Neustart nur von Ofelia aus:

    === "docker compose (Plugin)"

        ``` bash
        docker compose restart ofelia-mailcow
        ```

    === "docker-compose (Standalone)"

        ``` bash
        docker-compose restart ofelia-mailcow
        ```

## DMARC-Berichterstattung deaktivieren

Zum Deaktivieren der Berichterstattung:

1. Setzen Sie `enabled` auf `false` in `data/conf/rspamd/local.d/dmarc.conf`.

2. Machen Sie Änderungen in `docker-compose.override.yml` an `rspamd-mailcow` und `ofelia-mailcow` rückgängig

3. Starten Sie die betroffenen Container neu:

    === "docker compose (Plugin)"

        ``` bash
        docker compose up -d
        ```

    === "docker-compose (Standalone)"

        ``` bash
        docker-compose up -d
        ```
