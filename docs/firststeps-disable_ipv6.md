This is **ONLY** recommended if you do not have an IPv6 enabled network on your host!

If you really need to, you can disable the usage of IPv6 in the compose file.
Additionally, you can  also disable the startup of container "ipv6nat-mailcow", as it's not needed if you won't use IPv6.

Instead of editing docker-compose.yml directly, it is preferable to create an override file for it 
and implement your changes to the service there. Unfortunately, this right now only seems to work for services, not for network settings.

To disable IPv6 on the mailcow network, open docker-compose.yml with your favourite text editor and search for the network section (it's near the bottom of the file). 

**1.** Modify docker-compose.yml

Change `enable_ipv6: true` to `enable_ipv6: false`:

```
networks:
  mailcow-network:
    [...]
    enable_ipv6: true # <<< set to false
    [...]
```

**2.** Disable ipv6nat-mailcow

To disable the ipv6nat-mailcow container as well, go to your mailcow directory and create a new file called "docker-compose.override.yml": 

**NOTE:** If you already have an override file, of course don't recreate it, but merge the lines below into your existing one accordingly!

```
# cd /opt/mailcow-dockerized
# touch docker-compose.override.yml
```

Open the file in your favourite text editor and fill in the following:

```
version: '2.1'
services:

    ipv6nat-mailcow:
      restart: "no"
      entrypoint: ["echo", "ipv6nat disabled in compose.override.yml"]
```

For these changes to be effective, you need to fully stop and then restart the stack, so containers and networks are recreated:

```
docker-compose down
docker-compose up -d
```

**3.** Disable IPv6 in unbound-mailcow

Edit `data/conf/unbound/unbound.conf` and set `do-ip6` to "no":

```
server:
  [...]
  do-ip6: no
  [...]
```

Restart Unbound:

```
docker-compose restart unbound-mailcow
```

**4.** Disable IPv6 in postfix-mailcow

Create `data/conf/postfix/extra.cf` and set `smtp_address_preference` to `ipv4`:

```
smtp_address_preference = ipv4
inet_protocols = ipv4
```

Restart Postfix:

```
docker-compose restart postfix-mailcow
```
