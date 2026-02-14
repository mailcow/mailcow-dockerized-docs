!!! warning "Important"
    First read [the overview](r_p.md).

!!! danger
    This is an community supported contribution. Feel free to provide fixes.

This tutorial explains how to set up mailcow with Traefik as a reverse proxy to handle HTTPS connections, domain routing, and certificate management.

## Prerequisites

- Traefik v3.x installed and running
- Domain names configured to point to your server according to [this guide](../../getstarted/prerequisite-dns.md)

## Overview

Traefik will handle all incoming web traffic and route appropriate requests to mailcow. This setup allows Traefik to:

- Manage SSL certificates
- Handle autodiscover and autoconfig services
- Handle frontend UI
- Pass ACME challenge responses for certificate validation of the mail server

## Update mailcow Configuration

First, modify your `mailcow.conf` or `.env` file to disable mailcow's built-in SSL handling:

```bash
# Disable mailcow autodiscover SAN
AUTODISCOVER_SAN=n

# Skip running ACME (acme-mailcow, Let's Encrypt certs) - y/n
SKIP_LETS_ENCRYPT=y
```

## Configure Traefik

=== "Traefik Dynamic Configuration"

    Create or update your Traefik dynamic configuration file with the following content:

    ```yaml
    http:
      routers:
        mailcow:
          entryPoints: "websecure"
          rule: "Host(`mail.domain.com`)"
          service: mailcow-svc
          tls:
            certResolver: cloudflare

        mailcow-autoconfig:
          entryPoints: "websecure"
          rule: "(Host(`autoconfig.domain.com`) && Path(`/mail/config-v1.1.xml`))"
          service: mailcow-svc
          tls:
            certResolver: cloudflare

        mailcow-autodiscover:
          entryPoints: "websecure"
          rule: "(Host(`autodiscover.domain.com`) && Path(`/autodiscover/autodiscover.xml`))"
          service: mailcow-svc
          tls:
            certResolver: cloudflare

        mailcow-mta-sts:
          entryPoints: "websecure"
          rule: "(Host(`mta-sts.domain.com`) && Path(`/.well-known/mta-sts.txt`))"
          service: mailcow-svc
          tls:
            certResolver: cloudflare

      services:
        mailcow-svc:
          loadBalancer:
            servers:
              - url: "http://mailcow-nginx-mailcow-1:8080"
    ```

=== "Traefik Label Configuration"

    Add / Update your `docker-compose.yaml` file:

    ```yaml
    services:
      certdumper:
        image: ghcr.io/kereis/traefik-certs-dumper:latest
        container_name: traefik_certdumper
        restart: unless-stopped
        network_mode: none
        command: --restart-containers mailcow_postfix-mailcow_1,mailcow_dovecot-mailcow_1
        volumes:
          - traefik_certs:/traefik:ro # mount your traefik certificate file
          - /var/run/docker.sock:/var/run/docker.sock:ro
          - ./data/assets/ssl:/output:rw
        environment:
          - DOMAIN=domain.com
          - ACME_FILE_PATH=/traefik/cloudflare-acme.json # your traefik acme file

      # ...

      nginx:
        # ...
        expose:
          - 8080
        labels:
          - traefik.enable=true
          - traefik.http.routers.mailcow-autodiscover.entrypoints=websecure
          - traefik.http.routers.mailcow-autodiscover.rule=Host(`autodiscover.domain.com`) && Path(`/autodiscover/autodiscover.xml`)
          - traefik.http.routers.mailcow-autodiscover.tls.certresolver=cloudflare
          - traefik.http.routers.mailcow-autodiscover.service=mailcow-svc

          - traefik.http.routers.mailcow-autoconfig.entrypoints=websecure
          - traefik.http.routers.mailcow-autoconfig.rule=Host(`autoconfig.domain.com`)&& Path(`/mail/config-v1.1.xml`)
          - traefik.http.routers.mailcow-autoconfig.tls.certresolver=cloudflare
          - traefik.http.routers.mailcow-autoconfig.service=mailcow-svc

          - traefik.http.routers.mailcow-mta-sts.entrypoints=websecure
          - traefik.http.routers.mailcow-mta-sts.rule=Host(`mta-sts.domain.com`)&& Path(`/.well-known/mta-sts.txt`)
          - traefik.http.routers.mailcow-mta-sts.tls.certresolver=cloudflare
          - traefik.http.routers.mailcow-mta-sts.service=mailcow-svc

          - traefik.http.routers.mailcow.entrypoints=websecure
          - traefik.http.routers.mailcow.rule=Host(`mail.domain.com`)
          - traefik.http.routers.mailcow.tls=true
          - traefik.http.routers.mailcow.tls.certresolver=cloudflare
          - traefik.http.routers.mailcow.service=mailcow-svc

          - traefik.http.services.mailcow-svc.loadbalancer.server.port=8080
          - traefik.docker.network=proxy
        restart: always
        networks:
          mailcow-network:
            aliases:
              - nginx
          proxy:
    ```

**Important notes about this configuration:**

- Replace `mail.domain.com`, `autoconfig.domain.com` `autoconfig.domain.com`, and `mta-sts.domain.com` with your actual domain names
- `entryPoints: "websecure"` - replace it with your actual Traefik https entrypoint
- `certResolver: cloudflare` - replace it with your actual certificate resolver

## Step 3: Restart Services

Restart both Traefik and mailcow to apply the changes:

=== "docker compose (Plugin)"

    ``` bash
    # Restart mailcow
    cd /path/to/mailcow-dockerized
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    # Restart mailcow
    cd /path/to/mailcow-dockerized
    docker-compose up -d
    ```

## Testing Your Configuration

1. Visit `https://mail.domain.com` to check if the mailcow web interface loads properly
2. Configure an email client to test autodiscover functionality
3. Monitor Traefik logs for any routing or certificate errors

## Troubleshooting

### Certificate Issues

- Check `traefik_certsdumper` for any errors / missing acme file
- Ensure the Certificate file is correctly mounted

### Routing Problems

- Verify network connectivity between Traefik and mailcow
- Check that the mailcow IP address is correct in Traefik configuration
- Make sure all required ports are open in firewalls
