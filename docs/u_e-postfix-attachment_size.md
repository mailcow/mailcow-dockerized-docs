Open `data/conf/postfix/extra.cf` and set the `message_size_limit` accordingly in bytes. See `main.cf` for the default value.

Restart Postfix:

```
docker-compose restart postfix-mailcow
```
