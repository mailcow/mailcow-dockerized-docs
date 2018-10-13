If you want or have to use an external DNS service, you can define it in `data/conf/unbound/unbound.conf`:

```
forward-zone:
  name: "."
  forward-addr: 8.8.8.8
  forward-addr: 8.8.4.4
```

Please do not use a public resolver like we did in the example above. Many - if not all - blacklist lookups will fail with public resolvers.

**Important**: Only DNSSEC validating DNS services will work.

Restart Unbound after changing its config file:

```
docker-compose restart unbound-mailcow
```

