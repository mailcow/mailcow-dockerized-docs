## Spam & Ham lernen

Rspamd lernt, ob es sich um Spam oder Ham handelt, wenn Sie eine Nachricht in oder aus dem Junk-Ordner in ein anderes Postfach als den Papierkorb verschieben.
Dies wird durch die Verwendung des Sieve-Plugins "sieve_imapsieve" und Parser-Skripte erreicht.

Rspamd liest auch automatisch Mails, wenn eine hohe oder niedrige Punktzahl erkannt wird (siehe https://rspamd.com/doc/configuration/statistic.html#autolearning). Wir haben das Plugin so konfiguriert, dass es ein vernünftiges Verhältnis zwischen Spam- und Ham-Learnings beibehält.

Die Bayes-Statistiken werden in Redis als Schlüssel `BAYES_HAM` und `BAYES_SPAM` gespeichert.

Neben Bayes wird ein lokaler Fuzzy-Speicher verwendet, um wiederkehrende Muster in Texten oder Bildern zu lernen, die auf Ham oder Spam hinweisen.

Sie können auch die Web-UI von Rspamd verwenden, um Ham und/oder Spam zu lernen oder bestimmte Einstellungen von Rspamd anzupassen.

### Spam oder Ham aus bestehendem Verzeichnis lernen


Sie können einen Einzeiler verwenden, um Mails im Klartextformat (unkomprimiert) zu lernen:
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

Erwägen Sie, einen lokalen Ordner als neues Volume an `rspamd-mailcow` in `docker-compose.yml` anzuhängen und die gegebenen Dateien innerhalb des Containers zu lernen. Dies kann als Workaround verwendet werden, um komprimierte Daten mit zcat zu parsen. Beispiel:

```bash
for file in /data/old_mail/.Junk/cur/*; do rspamc learn_spam < zcat $file; done
```

## Gelernte Daten zurücksetzen (Bayes, Neural)

Sie müssen die Schlüssel in Redis löschen, um die gelernten Daten zurückzusetzen, also erstellen Sie zuerst eine Kopie Ihrer Redis-Datenbank:

### Kopie der Redis Datenbank

```bash
# Es ist besser, Redis zu stoppen, bevor Sie die Datei kopieren.
cp /var/lib/docker/volumes/mailcowdockerized_redis-vol-1/_data/dump.rdb /root/
```

!!! Info
    Wenn $REDISPASS in mailcow.conf gesetzt ist sollten die Befehle wie hier am besipiel gezeigt angepasst werden.
    ```
    source mailcow.conf
    docker compose exec redis-mailcow env REDISCLI_AUTH="$REDISPASS" sh -c '..'
    ```

### Bayes-Daten zurücksetzen
=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf
    docker compose exec redis-mailcow sh -c 'redis-cli -a ${REDISPASS} --scan --pattern BAYES_* | xargs redis-cli -a ${REDISPASS} del'
    docker compose exec redis-mailcow sh -c 'redis-cli -a ${REDISPASS} --scan --pattern RS* | xargs redis-cli -a ${REDISPASS} del'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf
    docker-compose exec redis-mailcow sh -c 'redis-cli -a ${REDISPASS} --scan --pattern BAYES_* | xargs redis-cli -a ${REDISPASS} del'
    docker-compose exec redis-mailcow sh -c 'redis-cli -a ${REDISPASS} --scan --pattern RS* | xargs redis-cli -a ${REDISPASS} del'
    ```

### Neurale Daten zurücksetzen
=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf
    docker compose exec redis-mailcow sh -c 'redis-cli -a ${REDISPASS} --scan --pattern rn_* | xargs redis-cli -a ${REDISPASS} del'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf
    docker-compose exec redis-mailcow sh -c 'redis-cli -a ${REDISPASS} --scan --pattern rn_* | xargs redis-cli -a ${REDISPASS} del'
    ```

### Fuzzy-Daten zurücksetzen
=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf
    # Wir müssen zuerst die redis-cli aufrufen:
    docker compose exec redis-mailcow redis-cli -a ${REDISPASS}
    # In redis-cli geben wir nun ein:
    127.0.0.1:6379> EVAL "for i, name in ipairs(redis.call('KEYS', ARGV[1])) do redis.call('DEL', name); end" 0 fuzzy*
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf
    # Wir müssen zuerst die redis-cli aufrufen:
    docker-compose exec redis-mailcow redis-cli -a ${REDISPASS}
    # In redis-cli geben wir nun ein:
    127.0.0.1:6379> EVAL "for i, name in ipairs(redis.call('KEYS', ARGV[1])) do redis.call('DEL', name); end" 0 fuzzy*
    ```

!!! info
    Wenn redis-cli sich darüber beschwert...
    ```Text
    (error) ERR wrong number of arguments for 'del' command
    ```
    ...,dass das Schlüsselmuster nicht gefunden wurde und somit keine Daten zum Löschen vorhanden sind - ist dies in Ordnung.
