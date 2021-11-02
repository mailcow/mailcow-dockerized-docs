So you deleted a mailbox and have no backups, he?

If you noticed your mistake within a few hours, you can probably recover the users data.

### SOGo

We automatically create daily backups (24h interval starting from running up -d) in `/var/lib/docker/volumes/mailcowdockerized_sogo-userdata-backup-vol-1/_data/`.

**Make sure the user you want to restore exists in your mailcow**. Re-create them if they are missing.

Copy the file named after the user you want to restore to `__MAILCOW_DIRECTORY__/data/conf/sogo`.

1\. Copy the backup: `cp /var/lib/docker/volumes/mailcowdockerized_sogo-userdata-backup-vol-1/_data/restoreme@example.org __MAILCOW_DIRECTORY__/data/conf/sogo`

2\. Run `docker-compose exec -u sogo sogo-mailcow sogo-tool restore -F ALL /etc/sogo restoreme@example.org`

Run `sogo-tool` without parameters to check for possible restore options.

3\. Delete the copied backup by running `rm __MAILCOW_DIRECTORY__/data/conf/sogo`

4\. Restart SOGo and Memcached: `docker-compose restart sogo-mailcow memcached-mailcow`

### Mail

In case of an accidental deletion of a mailbox, you will be able to recover for (by default) 5 days. This depends on the `MAILDIR_GC_TIME` parameter in `mailcow.conf`.

A deleted mailbox is copied in its encrypted form to `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/_garbage`.

The folder inside `_garbage` follows the structure `[timestamp]_[domain_sanitized][user_sanitized]`, for example `1629109708_exampleorgtest` in case of test@example.org deleted on 1629109708.

To restore make sure you are actually restoring to the same mailcow it was deleted from or you use the same encryption keys in `crypt-vol-1`.

**Make sure the user you want to restore exists in your mailcow**. Re-create them if they are missing.

Copy the folders from `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/_garbage/[timestamp]_[domain_sanitized][user_sanitized]` back to `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data/[domain]/[user]` and resync the folder and recalc the quota:

```
docker-compose exec dovecot-mailcow doveadm force-resync -u restoreme@example.net '*'
docker-compose exec dovecot-mailcow doveadm quota recalc -u restoreme@example.net
```
