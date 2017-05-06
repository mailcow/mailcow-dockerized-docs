Rspamd is used for av handling, dkim signing and spam handling. It's a powerfull and fast filter system. For a more in-depth documentation on Rspamd please visit it's [own documentation](https://rspamd.com/doc/index.html).

## Learn Spam & Ham

Rspamd learns mail as spam or ham when you move a message in or out of the junk folder to any mailbox besides trash.
This is archived by using the Dovecot plugin "antispam" and a simple parser script.

Rspamd also auto-learns mail when a high or low score is detected (see https://rspamd.com/doc/configuration/statistic.html#autolearning)

The bayes statistics are written to Redis as keys `BAYES_HAM` and `BAYES_SPAM`.

You can also use Rspamd's web ui to learn ham and/or spam.

### Learn Spam or Ham from existing directory

You can use a one-liner to learn mail in plain-text (uncompressed) format:
```
# Ham
for file in /my/folder/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_ham < $file; done
# Spam
for file in /my/folder/.Junk/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_spam < $file; done
```

Consider attaching a local folder as new volume to `rspamd-mailcow` in `docker-compose.yml` and learn given files inside the container. This can be used as workaround to parse compressed data with zcat. Example:

```
for file in /data/old_mail/.Junk/cur/*; do rspamc learn_spam < zcat $file; done
```

## CLI tools

```
docker-compose exec rspamd-mailcow rspamc --help
docker-compose exec rspamd-mailcow rspamadm --help
```

See [Rspamd documentation](https://rspamd.com/doc/index.html)
