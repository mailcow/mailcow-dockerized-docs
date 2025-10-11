## Learn Spam & Ham

Rspamd learns mail as spam or ham when you move a message in or out of the junk folder to any mailbox besides trash.
This is achieved by using the Sieve plugin "sieve_imapsieve" and parser scripts.

Rspamd also auto-learns mail when a high or low score is detected (see https://rspamd.com/doc/configuration/statistic.html#autolearning). We configured the plugin to keep a sane ratio between spam and ham learns.

The bayes statistics are written to Redis as keys `BAYES_HAM` and `BAYES_SPAM`.

Besides bayes, a local fuzzy storage is used to learn recurring patterns in text or images that indicate ham or spam.

You can also use Rspamd's web UI to learn ham and / or spam or to adjust certain settings of Rspamd.

### Learn Spam or Ham from existing directory

You can use a one-liner to learn mail in plain-text (uncompressed) format:
=== "docker compose (Plugin)"

    ``` bash
    # Ham
    for file in /my/folder/cur/*; do docker exec -i $(docker compose ps -q rspamd-mailcow) rspamc learn_ham < $file; done
    # Spam
    for file in /my/folder/.Junk/cur/*; do docker exec -i $(docker compose ps -q rspamd-mailcow) rspamc learn_spam < $file; done
    ```

=== "docker-compose (Standalone)"

    ``` bash
    # Ham
    for file in /my/folder/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_ham < $file; done
    # Spam
    for file in /my/folder/.Junk/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_spam < $file; done
    ```

Consider attaching a local folder as new volume to `rspamd-mailcow` in `docker-compose.yml` and learn given files inside the container. This can be used as workaround to parse compressed data with zcat. Example:

```bash
for file in /data/old_mail/.Junk/cur/*; do rspamc learn_spam < zcat $file; done
```

## Reset learned data (Bayes, Neural)

You need to delete keys in Redis to reset learned data, so create a copy of your Redis database now:

### Copy of Redis database

```bash
# It is better to stop Redis before you copy the file.
cp /var/lib/docker/volumes/mailcowdockerized_redis-vol-1/_data/dump.rdb /root/
```

!!! Info
    If $REDISPASS is set in mailcow.conf adjust the commands like this:
    ```
    source mailcow.conf
    docker compose exec redis-mailcow env REDISCLI_AUTH="$REDISPASS" sh -c '..'
    ```

### Reset Bayes data
=== "docker compose (Plugin)"

    ``` bash
    docker compose exec redis-mailcow sh -c 'redis-cli --scan --pattern BAYES_* | xargs redis-cli del'
    docker compose exec redis-mailcow sh -c 'redis-cli --scan --pattern RS* | xargs redis-cli del'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern BAYES_* | xargs redis-cli del'
    docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern RS* | xargs redis-cli del'
    ```

### Reset Neural data
=== "docker compose (Plugin)"

    ``` bash
    docker compose exec redis-mailcow sh -c 'redis-cli --scan --pattern rn_* | xargs redis-cli del'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern rn_* | xargs redis-cli del'
    ```

### Reset Fuzzy data
=== "docker compose (Plugin)"

    ``` bash
    # We need to enter the redis-cli first:
    docker compose exec redis-mailcow redis-cli
    # In redis-cli:
    127.0.0.1:6379> EVAL "for i, name in ipairs(redis.call('KEYS', ARGV[1])) do redis.call('DEL', name); end" 0 fuzzy*
    ```

=== "docker-compose (Standalone)"

    ``` bash
    # We need to enter the redis-cli first:
    docker-compose exec redis-mailcow redis-cli
    # In redis-cli:
    127.0.0.1:6379> EVAL "for i, name in ipairs(redis.call('KEYS', ARGV[1])) do redis.call('DEL', name); end" 0 fuzzy*
    ```

!!! info
    If redis-cli complains about...
    ```text
    (error) ERR wrong number of arguments for 'del' command
    ```
    ...the key pattern was not found and thus no data is available to delete - it is fine.
