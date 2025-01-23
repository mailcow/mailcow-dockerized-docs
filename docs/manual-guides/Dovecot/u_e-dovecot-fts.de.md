!!! success "Neue Volltextsuche-Engine"
    Mit dem Januar 2025 Update wurde Solr durch Flatcurve ersetzt. Alle bestehenden FTS-Indizes sind daher **obsolet** und können entfernt werden.

    mailcow verweist auf das alte solr-vol-1 und fragt bei jedem Update-Vorgang, ob es entfernt werden soll, falls es noch existiert.

Flatcurve ist die neue Volltextsuche, die auch auf leistungsschwächeren Systemen besser funktioniert und langfristig auch zum Standard von Dovecot selbst wird.

Anders als bei Solr ist für Flatcurve **kein** weiteres Docker-Volume notwendig. Flatcurve speichert seine FTS-Datenbanken im `vmail-index`-Volume und erzeugt eine ähnliche Ordnerstruktur wie:

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

Jeder Unterordner im IMAP-Server erhält entsprechend einen eigenen `fts-flatcurve`-Ordner mit den jeweiligen Indizes der Mails des Ordners.

!!! danger "Wichtig"
    Sollten Sie bisher Solr verwendet haben, ist eine komplette Reindexierung erforderlich, da die beiden FTS-Engines **nicht** miteinander **kompatibel** sind.

    **Eine automatische Indexierung des Postfachs wird aktiviert, sobald 20 oder mehr E-Mails eingehen oder eine Volltextsuche durchgeführt wird.**

    Wir empfehlen, eine manuelle Reindexierung nur unter Aufsicht durchzuführen, da trotz niedriger Systemanforderungen eine übermäßige Systemauslastung nicht ausgeschlossen werden kann.

    [Weiter unten erfahren Sie, wie Sie eine Reindexierung anstoßen können](#fts-datenbank-neu-indizieren-reindex).

## FTS-bezogene Dovecot-Befehle

### FTS-Datenbank auf Fehler überprüfen und ggf. reparieren

=== "docker compose (Plugin)"

    ```bash
    # Einzelbenutzer
    docker compose exec dovecot-mailcow doveadm fts rescan -u user@domain
    # Alle Benutzer
    docker compose exec dovecot-mailcow doveadm fts rescan -A
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Einzelbenutzer
    docker-compose exec dovecot-mailcow doveadm fts rescan -u user@domain
    # Alle Benutzer
    docker-compose exec dovecot-mailcow doveadm fts rescan -A
    ```

Dovecot-Wiki: "Scannt, welche Mails im Volltextsuchindex vorhanden sind, und vergleicht diese mit den tatsächlich in den Postfächern vorhandenen Mails. Dies entfernt Mails aus dem Index, die bereits gelöscht wurden, und stellt sicher, dass der nächste doveadm-Index alle fehlenden Mails (falls vorhanden) indiziert."

Dies indiziert **nicht** eine Mailbox neu, sondern repariert lediglich einen vorhandenen Index.

### FTS-Datenbank neu indizieren (Reindex)

Wenn Sie die Daten sofort neu indizieren möchten, können Sie den folgenden Befehl ausführen, wobei `*` auch eine Postfachmaske wie 'Sent' sein kann. Diese Befehle sind optional, können jedoch den Prozess beschleunigen:

=== "docker compose (Plugin)"

    ```bash
    # Einzelner Benutzer
    docker compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # Alle Benutzer, langsamer und risikoreicher
    docker compose exec dovecot-mailcow doveadm index -A '*'
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Einzelner Benutzer
    docker-compose exec dovecot-mailcow doveadm index -u user@domain '*'
    # Alle Benutzer, langsamer und risikoreicher
    docker-compose exec dovecot-mailcow doveadm index -A '*'
    ```

!!! info "Hinweis"
    Die Indizierung **wird** einige Zeit in Anspruch nehmen.

    Es besteht die Möglichkeit einer übermäßigen Systemauslastung, bis hin zu Systemabstürzen in seltenen Fällen. **Beobachten Sie daher den Indizierungsprozess und Ihre Systemauslastung aufmerksam!**

Da die Neuindizierung ressourcenintensiv sein kann, wurde sie nicht in die mailcow-UI integriert. 

**Fehler beim Re-Indizieren müssen manuell über die CLI behoben werden.**

### FTS-Datenbank löschen

mailcow entfernt die Indexdaten eines Benutzers automatisch, wenn das entsprechende Postfach gelöscht wird.

Alternativ können Sie den Index für Flatcurve manuell über die CLI entfernen:

=== "docker compose (Plugin)"

    ```bash
    # Einzelner Benutzer
    docker compose exec dovecot-mailcow doveadm fts-flatcurve remove -u user@domain '*'
    # Alle Benutzer
    docker compose exec dovecot-mailcow doveadm fts-flatcurve remove -A '*'
    ```

=== "docker-compose (Standalone)"

    ```bash
    # Einzelner Benutzer
    docker-compose exec dovecot-mailcow doveadm fts-flatcurve remove -u user@domain '*'
    # Alle Benutzer
    docker-compose exec dovecot-mailcow doveadm fts-flatcurve remove -A '*'
    ```

## FTS-spezifische Optionen in mailcow.conf

mailcow liefert standardmäßig niedrige Parameter für die neue FTS-Engine, um sie auch auf schwächeren Systemen nutzbar zu machen.

Für leistungsstärkere Systeme können Sie einige Parameter anpassen, um eine effizientere Indexierung zu ermöglichen.

### `SKIP_FTS` (Volltextsuche deaktivieren)

In der mailcow.conf können Sie die Volltextsuche komplett deaktivieren. Dies ist vor allem auf Low-End-Systemen zu empfehlen, welche Probleme haben mailcow sowie die Indexierung flüssig laufen zu lassen.

Flatcurve ist ressourcenschonender als Solr, benötigt jedoch mehr Speicherplatz und gegebenenfalls mehr CPU-Leistung (abhängig vom Setup).

!!! abstract "mailcow-Standard"
    ^^Standardmäßig^^ ist dieser Parameter auf **n** gesetzt, wodurch die Volltextsuche aktiviert ist.

??? success "Best Practice"
    Lassen Sie die Indexierung zunächst aktiviert. Sollte die neue FTS-Engine zu viele Ressourcen beanspruchen, können Sie die Einstellung später anpassen.

### `FTS_PROCS` (Anzahl der Indexierungsprozesse)

Mit der Variablen `FTS_PROCS` in der mailcow.conf können Sie die Anzahl der Indexierungsprozesse anpassen, die gleichzeitig arbeiten.

!!! abstract "mailcow-Standard"
    ^^Standardmäßig^^ ist dieser Wert auf **1 Thread** limitiert.

!!! danger "**ACHTUNG**"
    Die Indexierungsprozesse verwenden jeweils einen CPU-Thread vollständig. Systeme mit wenigen Kernen sollten eine niedrige Anzahl einstellen, um die restliche Systemleistung nicht zu beeinträchtigen.

??? success "Best Practice"
    Planen Sie etwa **die Hälfte der CPU-Threads** Ihres Systems für die Indexierungsprozesse ein. Bei ungerader Kernzahl verwenden Sie die niedrigere Anzahl an Threads, um genügend Ressourcen für das Hauptsystem zu lassen.

    **Dual-Core**- oder **Single-Core-Systeme** sollten die Volltextsuche deaktivieren.

### `FTS_HEAP` (Max. Arbeitsspeicher pro Indexierungsprozess)

Mit `FTS_HEAP` in der mailcow.conf legen Sie den Arbeitsspeicher pro Indexierungsprozess fest.

!!! abstract "mailcow-Standard"
    ^^Standardmäßig^^ ist dieser Wert auf **128 MB** ==pro Prozess== limitiert.

??? success "Best Practice"
    Weisen Sie jedem Prozess idealerweise **512 MB** Arbeitsspeicher zu. Systeme mit weniger als 8 GB RAM sollten bei **128 MB** bleiben oder höchstens auf 256 MB erhöhen.

    Bei ausgeschöpftem RAM kann Dovecot zwar weiterarbeiten, wird jedoch langsamer.

## Erweiterte Konfigurationsmöglichkeiten

Die Integration von Flatcurve erlaubt es, FTS-Optionen individuell anzupassen.

!!! notice "Hinweis"
    Jedes Setup ist anders, daher gibt es kein allgemeingültiges Optimum.

    **Die Erfahrung mit der Engine variiert je nach System.**

Beispielsweise können Sie eine detailliertere Volltextsuche (Substring Search) aktivieren, die genauere Ergebnisse liefert, aber auch mehr Speicherplatz und Zeit erfordert.

### Substring Search aktivieren (Detailiertere Volltextsuche)

Bearbeiten Sie die Datei `data/conf/dovecot/conf.d/fts.conf`:

```conf
plugin {
    [...]

    fts_flatcurve_substring_search=yes # Kann entweder yes oder no sein
}
```

Ein Neustart von Dovecot aktiviert die Änderungen:

=== "docker compose (Plugin)"

    ```bash
    docker compose restart dovecot-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose restart dovecot-mailcow
    ```

### Weitere Tweaks

Wir nehmen gerne von der Community vorgeschlagene Tweaks auf.

In der Zwischenzeit können Sie sich die offiziellen Dokumentationen zu Dovecot und Flatcurve ansehen:

- [Dovecot FTS Modul Dokumentation](https://doc.dovecot.org/2.3/settings/plugin/fts-plugin/){:target="_blank"}
- [Flatcurve FTS Engine Dokumentation](https://slusarz.github.io/dovecot-fts-flatcurve/configuration.html){:target="_blank"}