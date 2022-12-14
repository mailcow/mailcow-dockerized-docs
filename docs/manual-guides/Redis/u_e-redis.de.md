Redis wird als Key-Value-Speicher für die Einstellungen und Daten von rspamd und (einige von) mailcow verwendet. Wenn Sie mit Redis nicht vertraut sind, lesen Sie bitte die [Einführung in Redis](https://redis.io/topics/introduction) und besuchen Sie gegebenenfalls diese [wunderbare Anleitung](http://try.redis.io/), um zu erfahren, wie man Redis benutzt.

## Client

Um sich mit dem redis cli zu verbinden, führen Sie aus:
=== "docker compose"

    ``` bash
    docker compose exec redis-mailcow redis-cli
    ```

=== "docker-compose"

    ``` bash
    docker-compose exec redis-mailcow redis-cli
    ```

### Fehlersuche

Hier sind einige nützliche Befehle für den redis-cli zur Fehlersuche:

##### MONITOR

Überwacht alle vom Server empfangenen Anfragen in Echtzeit:
=== "docker compose"

    ``` bash
    #docker compose exec redis-mailcow redis-cli
    127.0.0.1:6379> monitor
    OK
    1494077286.401963 [0 172.22.1.253:41228] "SMEMBERS" "BAYES_SPAM_keys"
    1494077288.292970 [0 172.22.1.253:41229] "SMEMBERS" "BAYES_SPAM_keys"
    [...]
    ```

=== "docker-compose"

    ``` bash
    #docker-compose exec redis-mailcow redis-cli
    127.0.0.1:6379> monitor
    OK
    1494077286.401963 [0 172.22.1.253:41228] "SMEMBERS" "BAYES_SPAM_keys"
    1494077288.292970 [0 172.22.1.253:41229] "SMEMBERS" "BAYES_SPAM_keys"
    [...]
    ```

##### SCHLÜSSEL (Keys)

Ermittelt alle Schlüssel, die dem Muster entsprechen:

```
KEYS *
```

##### PING

Testen Sie eine Verbindung:

```
127.0.0.1:6379> PING
PONG
```

Wenn Sie mehr wissen wollen, hier ist ein [Cheat-Sheet](https://www.cheatography.com/tasjaevan/cheat-sheets/redis/).
