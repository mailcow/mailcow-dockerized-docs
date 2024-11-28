!!! success "Neue Volltextsuche Engine"
    Mit 2024-12 wurde Solr mit Flatcurve ausgewechselt. Alle bestehenden FTS Indexe sind daher **obsolet** und können entfernt werden.

    mailcow weißt auf das alte solr-vol-1 hin und fragt bei jedem Update vorgang, um es entfernen zu lassen, sollte es noch exisiteren.

Flatcurve ist die neue Volltextsuche auch auf leistungsschwächeren Systemen besser funktioniert.

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

!!! danger "Wichtig"
    Sollten Sie bisher Solr verwendet haben, ist eine komplette Reindexierung vonnöten, da die beiden FTS Engines **nicht** untereinander **kompatibel** sind.

    **Neue E-Mails** werden automatisch **indexiert**, **bestehende Mails** sind allerdings **nicht indexiert**!

    Wir empfehlen, diese Reindexierung nur unter Aufsicht durchzuführen, da trotz niedriger Systemanforderungen eine übermäßige Systemauslastung nicht ausgeschlossen werden kann!

    [Weiter unten erfahren Sie, wie Sie eine Reindexierung anstoßen können](#fts-datenbank-neu-indizieren-reindex).

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
    
    Es besteht, die Möglichkeit einer übermäßig starken Systemnutzung, bis hin zu Systemabstürzen in seltenen Fällen. **Überwachen Sie also den Indizierungsprozess und Ihre Systemauslastung wachsam!**

Da die Neuindizierung teilweise etwas fragil und gerade im Bezug auf Systemressourcen sensibel reagieren kann, haben wir sie vorerst nicht in die mailcow UI integriert. 

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


