This is **NOT** recommended!

If IPv6 MUST be disabled to fit a network, open `docker-compose.yml`, search for `enable_ipv6`...


```
networks:
  mailcow-network:
    [...]
    enable_ipv6: true
    [...]
```

...change it to `enable_ipv6: false`.

mailcow needs to be shutdown, the containers removed and the network recreated:

```
docker-compose down
docker-compose up -d
```

