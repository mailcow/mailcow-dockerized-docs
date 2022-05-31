Öffnen Sie `data/conf/postfix/extra.cf` und setzen Sie das `message_size_limit` entsprechend in Bytes. Siehe `main.cf` für den Standardwert.

Starten Sie Postfix neu:

```
docker compose restart postfix-mailcow
```