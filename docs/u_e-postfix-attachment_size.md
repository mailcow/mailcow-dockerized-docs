Open `data/conf/postfix/main.cf` and set the `message_size_limit` accordingly in bytes.

Restart Postfix:

```
docker-compose restart postfix-mailcow
```
