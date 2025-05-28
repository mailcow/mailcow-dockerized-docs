!!! failure "Action Required"
    Older setups must follow this guide after the 2025-06 update to ensure full compatibility.

??? warning "Caution with Docker version 25"
    For installations using Docker versions <b>between 25.0.0 and 25.0.2</b> (check with `docker version`), a bug changed how IPv6 address allocation works. Setting `enable_ipv6: false` alone is **not** sufficient to fully disable IPv6 in the stack.<br>This bug was fixed in Docker version 25.0.3.

!!! danger "Warning: Open Relay Risk"
    Even with IPv6 disabled in Docker, your system can still become an open relay if the host has a public IPv6 address. 
    
    Reason: Docker disables IPv6 only inside the container, not on the host. IPv6 traffic still reaches the container and appears as internal IPv4 — a major security risk.

    mailcow allows unauthenticated connections from **any** internal container IP address (IPv4 or IPv6) for internal communication, e.g., with Postfix.

    If IPv6 is misconfigured, external traffic may appear as an internal Docker IP and bypass authentication — resulting in a fully functional open relay.

These steps are **only recommended** if your host system does not need IPv6 connectivity.

## 0. Disable IPv6 on the host system

??? question "Why is this necessary?"
    Disabling IPv6 only inside Docker is **not enough**. If the host keeps a public IPv6 address (e.g. on a public interface), IPv6 traffic can still reach the container network. This traffic may be translated into internal IPv4 (via NAT or Docker's internal routing) and appear to services like Postfix as internal and trusted — even though it originated externally. This results in a working open relay.

    Only by **completely disabling IPv6 on the host** can you ensure that no IPv6 connections reach mailcow or its containers.

### Temporary (until reboot):

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
```

### Permanent:

Add the following to `/etc/sysctl.conf`:

```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

Apply afterwards:

```bash
sysctl -p
```

## 1. Disable IPv6 in the mailcow network

=== "New logic (since 2025-06)"

    Set `ENABLE_IPV6=false` in `mailcow.conf`.

=== "Legacy installations"

    In `docker-compose.yml`, find the `networks` section:

    ```yml
    networks:
      mailcow-network:
        [...]
        enable_ipv6: false # set from true to false
        ipam:
          driver: default
          config:
            - subnet: ${IPV4_NETWORK:-172.22.1}.0/24
        [...]
    ```

## 2. Disable ipv6nat-mailcow

=== "New logic (since 2025-06)"

    !!! warning "Attention"
        The ipv6nat-mailcow container is no longer part of mailcow since the 2025-06 update.

        This step is no longer required.

=== "Legacy installations"

    ```bash
    cd /opt/mailcow-dockerized
    touch docker-compose.override.yml
    ```

    Fill with the following content:

    ```yml
    services:
      ipv6nat-mailcow:
        image: bash:latest
        restart: "no"
        entrypoint: ["echo", "ipv6nat disabled in compose.override.yml"]
    ```

## 3. Restart the stack

!!! notice
    Applies to all setups.

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

## 4. Disable IPv6 in unbound (optional)

!!! notice
    Applies to all setups.

In `data/conf/unbound/unbound.conf`:

    server:
      [...]
      do-ip6: no
      [...]

=== "docker compose (Plugin)"

    ```bash
    docker compose restart unbound-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose restart unbound-mailcow
    ```

## 5. Disable IPv6 in postfix (optional)

!!! notice
    Applies to all setups.

In `data/conf/postfix/extra.cf`:

    smtp_address_preference = ipv4
    inet_protocols = ipv4

=== "docker compose (Plugin)"

    ```bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose restart postfix-mailcow
    ```

## 6. Disable IPv6 in dovecot and php-fpm (optional)

!!! notice "Note"
    Applies to all setups.

```bash
sed -i 's/,\[::\]//g' data/conf/dovecot/dovecot.conf
sed -i 's/\[::\]://g' data/conf/phpfpm/php-fpm.d/pools.conf
```

## 7. Disable IPv6 listener in nginx

=== "New logic (since 2025-06)"

    Automatically handled when setting `ENABLE_IPV6=false` in `mailcow.conf` [(see Step 1)](#1-disable-ipv6-in-the-mailcow-network)

=== "Legacy installations"

    In `mailcow.conf`:

        DISABLE_IPv6=y

    === "docker compose (Plugin)"

        ```bash
        docker compose up -d
        ```

    === "docker-compose (Standalone)"

        ```bash
        docker-compose up -d
        ```