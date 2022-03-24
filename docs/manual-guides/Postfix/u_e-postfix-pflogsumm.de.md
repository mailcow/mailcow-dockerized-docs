Um pflogsumm mit dem Standard-Logging-Treiber zu verwenden, müssen wir postfix-mailcow über docker logs abfragen und die Ausgabe zu pflogsumm leiten:

```
docker logs --since 24h $(docker ps -qf name=postfix-mailcow) | pflogsumm
```

Die obige Log-Ausgabe ist auf die letzten 24 Stunden beschränkt.

Es ist auch möglich, einen täglichen pflogsumm-Bericht über cron zu erstellen. Erstellen Sie die Datei /etc/cron.d/pflogsumm mit dem folgenden Inhalt:

```
SHELL=/bin/bash
59 23 * * * root docker logs --since 24h $(docker ps -qf name=postfix-mailcow) | /usr/sbin/pflogsumm -d today | mail -s "Postfix Report of $(date)" postmaster@example.net
```

Um zu funktionieren muss ein lokaler Postfix auf dem Server installiert werden, welcher an den Postfix der mailcow relayed.

Genauere Informationen lassen sich unter Sektion [Post-Installationsaufgaben -> Lokaler MTA auf Dockerhost](https://mailcow.github.io/mailcow-dockerized-docs/de/post_installation/firststeps-local_mta/) finden.

Basierend auf den Postfix-Logs der letzten 24 Stunden sendet dieses Beispiel dann jeden Tag um 23:59:00 Uhr einen pflogsumm-Bericht an postmaster@example.net.
