## Client

Redis is used as a key-value store for (some of) mailcow's and rspamd's settings and data. If you are unfamilliar with redis please read the [introduction to redis](https://redis.io/topics/introduction) and maybe visit this [wonderfull guide](http://try.redis.io/) on how to use it.

To connect to the redis cli execute:

```
docker-compose exec redis-mailcow redis-cli
```

Here are some usefull commands for the redis-cli for debugging:

**MONITOR**

Listens for all requests received by the server in real time:

```
# docker-compose exec redis-mailcow redis-cli
127.0.0.1:6379> monitor
OK
1494077286.401963 [0 172.22.1.253:41228] "SMEMBERS" "BAYES_SPAM_keys"
1494077288.292970 [0 172.22.1.253:41229] "SMEMBERS" "BAYES_SPAM_keys"
[...]
```

**KEYS**

Get all keys matching your pattern:

```

```

**PING**

Test a connection:

```
127.0.0.1:6379> PING
PONG
```

If you want to know more, here is a [cheat sheet](https://www.cheatography.com/tasjaevan/cheat-sheets/redis/).
