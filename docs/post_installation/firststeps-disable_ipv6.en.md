## mailcow Versions from 2025-09

Starting with the 2025-09 update, IPv6 in the mailcow stack can be conveniently managed.

Simply adjust the variable in the mailcow.conf file:

```bash
ENABLE_IPV6=false
```

!!! info "Note"
    From 2025-09 onwards, this variable is enabled by default (`true`) if the system supports IPv6 connectivity. This also enables IPv6 within the containers.

After making the change, the entire mailcow stack must be restarted:

=== "docker compose (Plugin)"

    ```bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose down
    docker-compose up -d
    ```

This will recreate the mailcow Docker network based on the setting in mailcow.conf.

??? question "Did you know?"
    Since the 2025-09 update, there is a helper in the update script that can adjust the IPv6 settings in the Docker Daemon based on your host configuration.

    In most cases, this works seamlessly as the JSON file is carefully edited using the `jq` tool to cleanly integrate or remove values.

    The helper will notify you of necessary adjustments until the daemon.json file is correctly configured (either IPv6-compatible or not) to ensure smooth and error-free operation.

No further changes are required, as these settings control all internal IPv6 addresses.

All mailcow services are configured to listen on both IPv4 and IPv6 (if enabled). If only an IPv4 address is available for the container network, only this will be used for the services.

??? warning "Important — if IPv6 was enabled earlier"
    If you had previously enabled IPv6 in the stack or in the Docker daemon and now want to disable it, please also manually adjust the Docker daemon and kernel IPv6 settings. If old Docker or kernel settings remain, unexpected errors may occur (e.g., incorrect address translations). Ideally, this should be done via sysctl, so that IPv6 is completely disabled at the kernel level, and then the Docker service should be restarted.

    Quick overview (example commands, check and adapt to your distribution):

    Check:
    ```bash
    sysctl net.ipv6.conf.all.disable_ipv6 net.ipv6.conf.default.disable_ipv6
    ```

    Temporarily (lasts until reboot):
    ```bash
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    sysctl -w net.ipv6.conf.default.disable_ipv6=1
    sysctl -w net.ipv6.conf.lo.disable_ipv6=1
    ```

    Persistent disabling (create and apply file):
    ```bash
    echo -e "net.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" | tee /etc/sysctl.d/99-disable-ipv6.conf
    sysctl --system
    ```

    Docker Daemon check/adapt:

    - Make sure there is no entry like "ipv6": true or "fixed-cidr-v6" in /etc/docker/daemon.json. If necessary, set "ipv6": false or remove IPv6-related entries.
    - Example (edit carefully or automate with jq):

        ```bash
        mkdir -p /etc/docker
        # manually: edit /etc/docker/daemon.json and set "ipv6": false or remove fixed-cidr-v6
        systemctl restart docker
        ```

    After these changes, restart Docker and recreate the mailcow stack:

    === "docker compose (Plugin)"

        ```bash
        docker compose down
        docker compose up -d
        ```

    === "docker-compose (Standalone)"

        ```bash
        docker-compose down
        docker-compose up -d
        ```


!!! danger "Caution"
    If you are using an IPv6 address on your host and the Docker Daemon is not correctly configured (which is usually detected and resolved by a helper during the update process), this can lead to an open relay.

    This happens because Docker, by default, translates IPv6 addresses into internal IPv4 addresses (NAT). If the Docker Daemon is not properly configured, external IPv6 addresses may be mistakenly interpreted as internal addresses. This could allow spammers to send spam through your server using a misconfigured IPv6 address.

    On the Docker network level, this is particularly critical because internal container addresses often have less stringent security mechanisms. Specifically, communication between the webmail client and the Postfix (SMTP) server could expose security vulnerabilities if the network translation is not functioning correctly.

    It is therefore essential to adjust the Docker Daemon according to the system configuration. The Daemon should be configured to reflect the actual IPv6 connectivity of the host. This prevents incorrect NAT rules and ensures that IPv6 addresses are handled correctly. 
    
    **Always check your Docker network configurations after making network changes to ensure that no unintended security vulnerabilities are introduced.**

---

## Older mailcow Versions (pre 2025-09)

!!! danger
    In installations using a Docker version <b>between 25.0.0 and 25.0.2</b> (to check, use `docker version`) the behavior of IPv6 address allocation has changed due to a bug. Simply using `enable_ipv6: false` is **NO LONGER** sufficient to completely disable IPv6 in the stack. <br>This was a bug in the Docker Daemon, which has been fixed with version 25.0.3.

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

Fix the following Dovecot and php-fpm config files

```
sed -i 's/,\[::\]//g' data/conf/dovecot/dovecot.conf
sed -i 's/\[::\]://g' data/conf/phpfpm/php-fpm.d/pools.conf
```

**6.** Disable IPv6 listeners for NGINX

Set `DISABLE_IPv6=y` in `mailcow.conf`

For this change to be effective, you need to recreate the `nginx-mailcow` Container

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

