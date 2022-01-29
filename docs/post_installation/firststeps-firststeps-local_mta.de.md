Die einfachste Möglichkeit wäre, den Listener an Port 25/tcp zu deaktivieren.

**Postfix**-Benutzer deaktivieren den Listener, indem sie die folgende Zeile (beginnend mit `smtp` oder `25`) in `/etc/postfix/master.cf` auskommentieren:
```
#smtp      inet  n       -       -       -       -       smtpd
```

Außerdem, um über eine Dockerized mailcow weiterzuleiten, sollten Sie `172.22.1.1` als Relayhost hinzufügen und das Docker-Interface aus "inet_interfaces" entfernen:

```
postconf -e 'relayhost = 172.22.1.1'
postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
postconf -e "inet_interfaces = loopback-only"
postconf -e "relay_transport = relay"
postconf -e "default_transport = smtp"
```

**Jetzt ist es wichtig**, dass Sie nicht denselben FQDN in `myhostname` haben, den Sie für Ihre mailcow verwenden. Prüfen Sie Ihre lokale (nicht-Docker) Postfix' main.cf auf `myhostname` und setzen Sie ihn auf etwas anderes, zum Beispiel `local.my.fqdn.tld`.

"172.22.1.1" ist das von mailcow erstellte Netzwerk-Gateway in Docker.
Das Relaying über diese Schnittstelle ist notwendig (anstatt - zum Beispiel - direkt über ${MAILCOW_HOSTNAME}), um über ein bekanntes internes Netzwerk weiterzuleiten.

Starten Sie Postfix neu, nachdem Sie Ihre Änderungen vorgenommen haben.