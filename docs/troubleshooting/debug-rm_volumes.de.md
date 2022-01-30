Es kann sein, dass Sie einen Satz persistenter Daten entfernen wollen, um einen Konflikt zu lösen oder um neu zu beginnen.

`mailcowdockerized` kann variieren und hängt von Ihrem Compose-Projektnamen ab (wenn er unverändert ist, ist `mailcowdockerized` der richtige Wert). Wenn Sie sich unsicher sind, führen Sie `docker volume ls` aus, um eine vollständige Liste zu erhalten.

Löschen Sie ein einzelnes Volume:

```
docker volume rm mailcowdockerized_${VOLUME_NAME}
```

- Entfernen Sie Volume `mysql-vol-1`, um alle MySQL-Daten zu entfernen.
- Entfernen Sie Volume `redis-vol-1` um alle Redis Daten zu entfernen.
- Volume `vmail-vol-1` entfernen, um alle Inhalte von `/var/vmail` zu entfernen, die in `dovecot-mailcow` eingebunden sind.
- Entfernen Sie das Volume `rspamd-vol-1`, um alle Rspamd-Daten zu entfernen.
- Entfernen Sie Volume `crypt-vol-1`, um alle Crypto-Daten zu entfernen. Dies wird **alle Mails** unlesbar machen.

Alternativ dazu wird die Ausführung von `docker-compose down -v` **alle mailcow: dockerized volumes** zerstören und alle zugehörigen Container und Netzwerke löschen.
