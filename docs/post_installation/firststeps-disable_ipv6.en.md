!!! danger
    For installations that use Docker version **>= 25** (to check use `docker version`), the behavior of the IPv6 address allocation has changed. A simple `enable_ipv6: false` is **NOT** sufficient anymore to disable IPv6 completely in the stack. Whether this is a bug or intentional remains open ([see open issue at Docker](https://github.com/moby/moby/issues/47202)). **In any case, a manual adjustment is necessary if IPv6 was deactivated in the past!!!**

This is **ONLY** recommended if you do not have an IPv6 enabled network on your host!

If you really need to, you can disable the usage of IPv6 in the compose file.
Additionally, you can  also disable the startup of container "ipv6nat-mailcow", as it's not needed if you won't use IPv6.

Instead of editing docker-compose.yml directly, it is preferable to create an override file for it 
and implement your changes to the service there. Unfortunately, this right now only seems to work for services, not for network settings.

To disable IPv6 on the mailcow network, open docker-compose.yml with your favourite text editor and search for the network section (it's near the bottom of the file). 

**1.** Modify docker-compose.yml

Change `enable_ipv6: true` to `enable_ipv6: false` and comment out the IPv6 subnet:

```
networks:
  mailcow-network:
    [...]
    enable_ipv6: true # <<< set to false
    ipam:
      driver: default
      config:
        - subnet: ${IPV4_NETWORK:-172.22.1}.0/24
        - subnet: ${IPV6_NETWORK:-fd4d:6169:6c63:6f77::/64} # <<< comment out with #
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
      image: bash:latest
      restart: "no"
      entrypoint: ["echo", "ipv6nat disabled in compose.override.yml"]
```

For these changes to be effective, you need to fully stop and then restart the stack, so containers and networks are recreated:

=== "docker compose (Plugin)"

    ``` bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
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

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart unbound-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart unbound-mailcow
    ```

**4.** Disable IPv6 in postfix-mailcow

Create `data/conf/postfix/extra.cf` and set `smtp_address_preference` to `ipv4`:

```
smtp_address_preference = ipv4
inet_protocols = ipv4
```

Restart Postfix:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

**5.** If your docker daemon completly disabled IPv6:

Fix the following NGINX, Dovecot and php-fpm config files

```
sed -i '/::/d' data/conf/nginx/listen_*
sed -i '/::/d' data/conf/nginx/templates/listen*
sed -i '/::/d' data/conf/nginx/dynmaps.conf
sed -i 's/,\[::\]//g' data/conf/dovecot/dovecot.conf
sed -i 's/\[::\]://g' data/conf/phpfpm/php-fpm.d/pools.conf
```

