## FTS Solr
Solr wird für Setups mit Speicher >= 3,5 GiB verwendet, um eine Volltextsuche in Dovecot zu ermöglichen.

Bitte beachten Sie, dass Anwendungen wie Solr _vielleicht_ von Zeit zu Zeit gewartet werden müssen.

Außerdem verbraucht Solr eine Menge RAM, abhängig von der Nutzung Ihres Servers. Bitte vermeiden Sie es auf Maschinen mit weniger als 3 GB RAM.

Die Standard-Heap-Größe (1024 M) ist in mailcow.conf definiert.

Da wir in Docker laufen und unsere Container mit dem "restart: always" Flag erstellen, wird eine oom Situation zumindest nur einen Neustart des Containers auslösen.

### FTS-bezogene Dovecot-Befehle

```
# Einzelbenutzer
docker-compose exec dovecot-mailcow doveadm fts rescan -u user@domain
# alle Benutzer
docker-compose exec dovecot-mailcow doveadm fts rescan -A

```
Dovecot Wiki: "Scannt, welche Mails im Volltextsuchindex vorhanden sind und vergleicht diese mit den tatsächlich in den Postfächern vorhandenen Mails. Dies entfernt Mails aus dem Index, die bereits gelöscht wurden und stellt sicher, dass der nächste doveadm-Index alle fehlenden Mails (falls vorhanden) indiziert."

Dies indiziert **nicht** eine Mailbox neu. Es repariert im Grunde einen gegebenen Index.

Wenn Sie die Daten sofort neu indizieren wollen, können Sie den folgenden Befehl ausführen, wobei '*' auch eine Postfachmaske wie 'Sent' sein kann. Sie müssen diese Befehle nicht ausführen, aber es wird die Dinge ein wenig beschleunigen:

```
# einzelner Benutzer
docker-compose exec dovecot-mailcow doveadm index -u user@domain '*'
# alle Benutzer, aber offensichtlich langsamer und gefährlicher
docker-compose exec dovecot-mailcow doveadm index -A '*'
```

Dies **wird** einige Zeit in Anspruch nehmen, abhängig von Ihrer Maschine und Solr kann oom ausführen, überwachen Sie es!

Da die Neuindizierung sehr sinnvoll ist, haben wir sie nicht in die mailcow UI integriert. Sie müssen sich um eventuelle Fehler beim Re-Indizieren einer Mailbox kümmern.

### Löschen der Mailbox-Daten

mailcow wird die Indexdaten eines Benutzers löschen, wenn eine Mailbox gelöscht wird.

