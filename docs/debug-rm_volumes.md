You may want to remove a set of persistent data to resolve a conflict or to start over:

```
docker volume rm mailcowdockerized_${VOLUME_NAME}
```

- Remove volume `mysql-vol-1` to remove all MySQL data.
- Remove volume `redis-vol-1` to remove all Redis data.
- Remove volume `vmail-vol-1` to remove all contents of `/var/vmail` mounted to `dovecot-mailcow`.
- Remove volume `rspamd-vol-1` to remove all Rspamd data.
- Remove volume `crypt-vol-1` to remove all crypto data. This will render **all mails** unreadable.

Running `docker-compose down -v` will **destroy all mailcow: dockerized volumes** and delete any related containers and networks.
