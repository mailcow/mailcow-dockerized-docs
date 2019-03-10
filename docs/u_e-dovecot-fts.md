Solr is used for setups with memory >= 3.5 GiB to provide full-text search in Dovecot.

Please be aware that applications like Solr _may_ need maintenance from time to time.

Besides that, Solr will eat a lot of RAM, depending on the usage of your server. Please avoid it on machines with less than 3 GB RAM.

The default heap size (1024 M) is defined in mailcow.conf.

Since we run in Docker and create our containers with the "restart: always" flag, a oom situation will at least only trigger a restart of the container.

## FTS related Dovecot commands

```
# single user
docker-compose exec dovecot-mailcow doveadm fts rescan -u user@domain
# all users
docker-compose exec dovecot-mailcow doveadm fts rescan -A
```

Dovecot Wiki: "Scan what mails exist in the full text search index and compare those to what actually exist in mailboxes. This removes mails from the index that have already been expunged and makes sure that the next doveadm index will index all the missing mails (if any)."

This does **not** re-index a mailbox. It basically repairs a given index.

If you want to re-index data immediately, you can run the followig command, where '*' can also be a mailbox mask like 'Sent'. You do not need to run these commands, but it will speed things up a bit:

```
# single user
docker-compose exec dovecot-mailcow doveadm index -u user@domain '*'
# all users, but obviously slower and more dangerous
docker-compose exec dovecot-mailcow doveadm index -A '*'
```

This **will** take some time depending on your machine and Solr can run oom, monitor it!

Because re-indexing is very sensible, we did not include it to mailcow UI. You will need to take care of any errors while re-indexing a mailbox.

## Delete mailbox data

mailcow will purge index data of a user when deleting a mailbox.
