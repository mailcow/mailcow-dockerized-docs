# Ändern des IMAP-IDLE-Intervalls
## Was ist das IDLE-Intervall?
Standardmäßig sendet Dovecot eine "Ich bin noch da"-Benachrichtigung an jeden Client, der eine offene Verbindung mit Dovecot hat, um Mails so schnell wie möglich zu erhalten, ohne sie manuell abzufragen (IMAP PUSH). Diese Benachrichtigung wird durch die Einstellung [`imap_idle_notify_interval`](https://wiki.dovecot.org/Timeouts) gesteuert, die standardmäßig auf 2 Minuten eingestellt ist. 

Ein kurzes Intervall führt dazu, dass der Client viele Nachrichten für diese Verbindung erhält, was für mobile Geräte schlecht ist, da jedes Mal, wenn das Gerät diese Nachricht erhält, die Mailing-App aufwachen muss. Dies kann zu einer unnötigen Entladung der Batterie führen.

## Bearbeiten Sie den Wert
### Konfiguration ändern
Erstellen Sie eine neue Datei `data/conf/dovecot/extra.conf` (oder bearbeiten Sie sie, falls sie bereits existiert).
Fügen Sie die Einstellung ein, gefolgt von dem neuen Wert. Um zum Beispiel das Intervall auf 5 Minuten zu setzen, können Sie Folgendes eingeben:

```
imap_idle_notify_interval = 5 mins
```

29 Minuten ist der maximale Wert, den der [entsprechende RFC](https://tools.ietf.org/html/rfc2177) erlaubt.

!!! warning "Warnung"
	Dies ist keine Standardeinstellung in mailcow, da wir nicht wissen, wie diese Einstellung das Verhalten anderer Clients verändert. Seien Sie vorsichtig, wenn Sie dies ändern und ein anderes Verhalten beobachten.

### Dovecot neu laden
Nun laden Sie Dovecot neu:

=== "docker compose (Plugin)"

    ``` bash
	docker compose exec dovecot-mailcow dovecot reload
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose exec dovecot-mailcow dovecot reload
    ```

!!! info
	Sie können den Wert dieser Einstellung überprüfen mit 
	=== "docker compose (Plugin)"

		``` bash
		docker compose exec dovecot-mailcow dovecot -a | grep "imap_idle_notify_interval"
		```

	=== "docker-compose (Standalone)"

		``` bash
		docker-compose exec dovecot-mailcow dovecot -a | grep "imap_idle_notify_interval"
		```
	Wenn Sie den Wert nicht geändert haben, sollte er auf 2m stehen. Wenn Sie ihn geändert haben, sollten Sie den neuen Wert sehen.


