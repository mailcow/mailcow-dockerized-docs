### Client

```
docker-compose exec redis-mailcow redis-cli
```

## Remove persistent data

- Remove volume `mysql-vol-1` to remove all MySQL data.
- Remove volume `redis-vol-1` to remove all Redis data.
- Remove volume `vmail-vol-1` to remove all contents of `/var/vmail` mounted to `dovecot-mailcow`.
- Remove volume `dkim-vol-1` to remove all DKIM keys.
- Remove volume `rspamd-vol-1` to remove all Rspamd data.

Running `docker-compose down -v` will **destroy all mailcow: dockerized volumes** and delete any related containers.

## Reset admin password
Reset mailcow admin to `admin:moohoo`:

```
cd mailcow_path
bash mailcow-reset-admin.sh
```
