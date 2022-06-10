!!! warning "Warnung"
    Das Ändern der Bindung hat keinen Einfluss auf Source-NAT. Siehe [SNAT](../post_installation/firststeps-snat.de.md) für die erforderlichen Schritte.

## IPv4-Binding

Um eine oder mehrere IPv4-Bind(ings) anzupassen, öffne `mailcow.conf` und editiere eine, mehrere oder alle Variablen nach deinen Bedürfnissen:

```
# Aus technischen Gründen unterscheiden sich die http-Bindungen ein wenig von anderen Service-Bindungen.
# Sie werden die folgenden Variablen finden, getrennt durch eine Bindungsadresse und deren Port:
# Beispiel: HTTP_BIND=1.2.3.4

HTTP_PORT=80
HTTP_BIND=
HTTPS_PORT=443
HTTPS_BIND=

# Andere Dienste werden nach folgendem Format gebunden:
# SMTP_PORT=1.2.3.4:25 bindet SMTP an die IP 1.2.3.4 auf Port 25
# Wichtig! Durch die Angabe einer IPv4-Adresse werden alle IPv6-Bindungen seit Docker 20.x übersprungen.
# doveadm, SQL sowie Solr sind nur an lokale Ports gebunden, bitte ändern Sie das nicht, es sei denn, Sie wissen, was Sie tun.

SMTP_PORT=25
SMTPS_PORT=465
SUBMISSION_PORT=587
IMAP_PORT=143
IMAPS_PORT=993
POP_PORT=110
POPS_PORT=995
SIEVE_PORT=4190
DOVEADM_PORT=127.0.0.1:19991
SQL_PORT=127.0.0.1:13306
SOLR_PORT=127.0.0.1:18983
```

Um Ihre Änderungen zu übernehmen, führen Sie `docker compose down` gefolgt von `docker compose up -d` aus.

## IPv6-Binding

Das Ändern von IPv6-Bindings ist anders als bei IPv4. Auch dies hat einen technischen Hintergrund.

Eine `docker-compose.override.yml` Datei wird verwendet, anstatt die `docker-compose.yml` Datei direkt zu bearbeiten. Dies geschieht, um die Aktualisierbarkeit zu erhalten, da die Datei `docker-compose.yml` regelmäßig aktualisiert wird und Ihre Änderungen höchstwahrscheinlich überschrieben werden.

Bearbeiten Sie die Datei "docker-compose.override.yml" und erstellen Sie sie mit dem folgenden Inhalt. Ihr Inhalt wird mit der produktiven Datei "docker-compose.yml" zusammengeführt.

Es wird eine **beispielhafte** IPv6 **2001:db8:dead:beef::123** in [] angegeben. Das erste Suffix `:PORT1` definiert den externen Port, während das zweite Suffix `:PORT2` zu dem entsprechenden Port innerhalb des Containers führt und <u>**nicht**</u> verändert werden darf.

```
version: '2.1'
services:

    dovecot-mailcow:
      ports:
        - '[2001:db8:dead:beef::123]:143:143'
        - '[2001:db8:dead:beef::123]:993:993'
        - '[2001:db8:dead:beef::123]:110:110'
        - '[2001:db8:dead:beef::123]:995:995'
        - '[2001:db8:dead:beef::123]:4190:4190'

    postfix-mailcow:
      ports:
        - '[2001:db8:dead:beef::123]:25:25'
        - '[2001:db8:dead:beef::123]:465:465'
        - '[2001:db8:dead:beef::123]:587:587'

    nginx-mailcow:
      ports:
        - '[2001:db8:dead:beef::123]:80:80'
        - '[2001:db8:dead:beef::123]:443:443'
```

!!! info
    Alternativ kann auch die [::] Schreibweise benutzt werden um den jeweiligen Dienst auf allen IPv6 Interfaces lauschen zu lassen.

Um Ihre Änderungen zu übernehmen, führen Sie `docker compose down` gefolgt von `docker compose up -d` aus.