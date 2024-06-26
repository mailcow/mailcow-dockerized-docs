## FTS Solr (Deprecated)

!!! danger "Achtung"
    Solr wird nur noch bis Dezember 2024 unterstützt und anschließend aus mailcow entfernt und mit Flatcurve ersetzt.

Solr wird für Setups mit Speicher >= 3,5 GiB verwendet, um eine Volltextsuche in Dovecot zu ermöglichen.

Bitte beachten Sie, dass Anwendungen wie Solr _vielleicht_ von Zeit zu Zeit gewartet werden müssen.

Außerdem verbraucht Solr eine Menge RAM, abhängig von der Nutzung Ihres Servers. Bitte vermeiden Sie es auf Maschinen mit weniger als 3 GiB RAM.

Die Standard-Heap-Größe (1024 M) ist in `mailcow.conf` definiert.

Da wir in Docker laufen und unsere Container mit dem "restart: always" Flag erstellen, wird eine OOM-Situation zumindest nur einen Neustart des Containers auslösen.

## FTS Flatcurve (Experimentell seit 2024-06)

Flatcurve wird in naher Zukunft die bisherige FTS Engine Solr ablösen, damit eine Volltextsuche auch auf leistungsschwächeren Systemen besser funktioniert.

Beginnend mit dem Juni 2024 Update wurde eine experimentelle Unterstützung für Flatcurve als Volltextsuche eingebaut, welche sich in der experimentellen Phase ausschließlich über eine `mailcow.conf`-Variable aktivieren lässt.

!!! info "Hinweis"
    mailcow gibt in der Übergangszeit die Konfiguration für die FTS Engine innerhalb Dovecots vor und überschreibt etwaige eigene Änderungen (wenn nicht explizit in der `extra.conf` definiert). Dies wird aber mit dem Full Release der Engine innerhalb mailcows nicht mehr der Fall sein.

### Aktivierung der experimentellen Flatcurve-Nutzung

Die Aktivierung ist simpel und erfordert nur zwei kleine Handgriffe:

1. `mailcow.conf` bearbeiten und folgenden Wert ergänzen:

    ```bash
    FLATCURVE_EXPERIMENTAL=y
    ```

2. mailcow neu starten:

    === "docker compose (Plugin)"

        ```bash
        docker compose up -d
        ```

    === "docker-compose (Standalone)"

        ```bash
        docker-compose up -d
        ```

mailcow wird nun Flatcurve als FTS Backend nutzen.

Anders als bei Solr ist für Flatcurve **kein** weiteres Docker-Volume notwendig. Flatcurve speichert seine FTS-Datenbanken in dem `vmail-index`-Volume und führt zu einer ähnlichen Ordnerstruktur wie:

```
/var/vmail_index/tester@develcow.de/.INBOX/
├── dovecot.index
├── dovecot.index.cache
├── dovecot.index.log
└── fts-flatcurve
    └── index.814
        ├── flintlock
        ├── iamglass
        ├── postlist.glass
        └── termlist.glass
```


Jeder Unterordner im IMAP-Server erhält so analog einen eigenen `fts-flatcurve`-Ordner mit den jeweiligen Indizes der Mails des Ordners.

!!! info "Hinweis"
    Der Solr-Container bleibt in der Übergangszeit (voraussichtlich bis Dezember 2024) noch immer erhalten, um einen fließenden Übergang zu ermöglichen.

!!! warning "Achtung"
    Sollten Sie sich für den Wechsel der FTS Engine entscheiden, ist eine komplette Reindexierung vonnöten, da die beiden Systeme nicht untereinander kompatibel sind.
    [Weiter unten erfahren Sie, wie Sie eine Reindexierung anstoßen können](#fts-datenbank-neu-indizieren-reindex).

    Wir empfehlen allerdings, diese Reindexierung nur unter Aufsicht durchzuführen, da trotz niedriger Systemanforderungen eine übermäßige Systemauslastung nicht ausgeschlossen werden kann!

## FTS-bezogene Dovecot-Befehle

### FTS-Datenbank auf Fehler überprüfen und ggfs. reparieren

=== "docker compose (Plugin)"

    ```bash
    # Einzelbenutzer
    docker compose exec dovecot-mailcow doveadm fts rescan -u user@domain
    # alle Benutzer
    docker compose exec dovecot-mailcow doveadm fts rescan -A
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Einzelbenutzer
    docker-compose exec dovecot-mailcow doveadm fts rescan -u user@domain
    # alle Benutzer
    docker-compose exec dovecot-mailcow doveadm fts rescan -A
    ```

Dovecot Wiki: "Scannt, welche Mails im Volltextsuchindex vorhanden sind und vergleicht diese mit den tatsächlich in den Postfächern vorhandenen Mails. Dies entfernt Mails aus dem Index, die bereits gelöscht wurden und stellt sicher, dass der nächste doveadm-Index alle fehlenden Mails (falls vorhanden) indiziert."

Dies indiziert **nicht** eine Mailbox neu. Es repariert im Grunde einen gegebenen Index.

### FTS-Datenbank neu indizieren (Reindex)

Wenn Sie die Daten sofort neu indizieren wollen, können Sie den folgenden Befehl ausführen, wobei `*` auch eine Postfachmaske wie 'Sent' sein kann. Sie müssen diese Befehle nicht ausführen, aber es wird die Dinge ein wenig beschleunigen:

=== "docker compose (Plugin)"

    ```bash
    # einzelner Benutzer
    docker compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # alle Benutzer, aber offensichtlich langsamer und gefährlicher
    docker compose exec dovecot-mailcow doveadm index -A '*'
    ```

=== "docker-compose (Standalone)"

    ```bash
    # einzelner Benutzer
    docker-compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # alle Benutzer, aber offensichtlich langsamer und gefährlicher
    docker-compose exec dovecot-mailcow doveadm index -A '*'
    ```

!!! info "Hinweis"
    Die Indizierung **wird** einige Zeit in Anspruch nehmen.
    
    Es besteht, je nach FTS Engine, die Möglichkeit einer übermäßig starken Systemnutzung, bis hin zu Systemabstürzen in seltenen Fällen. **Überwachen Sie also den Indizierungsprozess und Ihre Systemauslastung wachsam!**

Da die Neuindizierung teilweise etwas fragil und gerade im Bezug auf Systemressourcen sensibel reagieren kann, haben wir sie nicht in die mailcow UI integriert. 

**Sie müssen sich manuell via CLI um eventuelle Fehler beim Re-Indizieren einer Mailbox kümmern.**

### FTS-Datenbank löschen

mailcow wird die Indexdaten eines Benutzers automatisch löschen, wenn die entsprechende Mailbox gelöscht wird.

Alternativ kann der Index für Flatcurve via CLI manuell gelöscht werden:

=== "docker compose (Plugin)"

    ```bash
    # einzelner Benutzer
    docker compose exec dovecot-mailcow doveadm fts-flatcurve remove -u user@domain '*'
    # alle Benutzer
    docker compose exec dovecot-mailcow doveadm fts-flatcurve remove -A '*'
    ```

=== "docker-compose (Standalone)"

    ```bash
    # einzelner Benutzer
    docker-compose exec dovecot-mailcow doveadm fts-flatcurve remove -u user@domain '*'
    # alle Benutzer
    docker-compose exec dovecot-mailcow doveadm fts-flatcurve remove -A '*'
    ```


