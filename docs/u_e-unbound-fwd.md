If you want or have to use an external DNS service, you can either set a forwarder in Unbound or copy an override file to define external DNS servers:

   !!! warning
   Please do not use a public resolver like we did in the example above. Many - if not all - blacklist lookups will fail with public resolvers.
   **Important**: Only DNSSEC validating DNS services will work.

## Method A, Unbound

Edit `data/conf/unbound/unbound.conf` and append the following parameters:

```
forward-zone:
  name: "."
  forward-addr: 8.8.8.8 # DO NOT USE PUBLIC DNS SERVERS - JUST AN EXAMPLE
  forward-addr: 8.8.4.4 # DO NOT USE PUBLIC DNS SERVERS - JUST AN EXAMPLE
```

Restart Unbound:

```
docker-compose restart unbound-mailcow
```


## Method B, Override file

```
cd /opt/mailcow-dockerized
cp helper-scripts/docker-compose.override.yml.d/EXTERNAL_DNS/docker-compose.override.yml .
```

Edit `docker-compose.override.yml` and adjust the IP.

Run `docker-compose down ; docker-compose up -d`.
