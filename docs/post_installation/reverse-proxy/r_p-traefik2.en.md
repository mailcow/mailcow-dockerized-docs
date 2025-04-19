# Configuring Mailcow with Traefik: Complete Tutorial

This tutorial explains how to set up Mailcow with Traefik as a reverse proxy to handle HTTPS connections, domain routing, and certificate management.

## Prerequisites

- Traefik v2.x installed and running
- Domain names configured to point to your server according to [this guide](https://docs.mailcow.email/getstarted/prerequisite-dns/)

## Overview

Traefik will handle all incoming web traffic and route appropriate requests to Mailcow. This setup allows Traefik to:

- Manage SSL certificates
- Handle autodiscover and autoconfig services
- Handle frontend UI
- Pass ACME challenge responses for certificate validation of the mail server

## Step 1: Update Mailcow Configuration

First, modify your `mailcow.conf` or `.env` file to disable Mailcow's built-in SSL handling:

```bash
# Disable Mailcow autodiscover SAN
AUTODISCOVER_SAN=n
```

## Step 2: Configure Traefik Dynamic Configuration

Create or update your Traefik dynamic configuration file with the following content:

```yaml
http:
  routers:
    mailcow-acme:
      entryPoints: web
      rule: "(Host(`mx.domain.com`) && PathPrefix(`/.well-known/acme-challenge/`))" # "Host" should be equal to your `MAILCOW_HOSTNAME` 
      service: mailcow-acme
      tls: false

    mailcow-frontend:
      entryPoints: "websecure"
      rule: "Host(`mail.domain.com`)"
      service: mailcow-frontend
      tls:
        certResolver: cloudflare

    mailcow-autoconfig:
      entryPoints: "websecure"
      rule: "Host(`autoconfig.domain.com`)" 
      service: mailcow-frontend
      tls:
        certResolver: cloudflare

    mailcow-autodiscover:
      entryPoints: "websecure"
      rule: "Host(`autodiscover.domain.com`)"
      service: mailcow-frontend
      tls:
        certResolver: cloudflare

  services:
    mailcow-acme:
      loadBalancer:
        servers:
          - url: "http://10.0.0.16:80" # mailcow local IP and web port
    mailcow-frontend:
      loadBalancer:
        servers:
          - url: "http://10.0.0.16:80" # mailcow local IP and web port
```

**Important notes about this configuration:**
 
- Replace `mx.domain.com`, `mail.domain.com`, `autoconfig.domain.com`, and `autodiscover.domain.com` with your actual domain names
- Update `10.0.0.16` with the actual IP address of your Mailcow server
- `entryPoints: "websecure"` - replace it with your actual Traefik https entrypoint
- `certResolver: cloudflare` - replace it with your actual certificate resolver


## Step 3: Restart Services

Restart both Traefik and Mailcow to apply the changes:

```bash
# Restart Mailcow
cd /path/to/mailcow-dockerized
docker-compose up -d
```

## Testing Your Configuration

1. Visit `https://mail.domain.com` to check if the Mailcow web interface loads properly
2. Configure an email client to test autodiscover functionality
3. Monitor Traefik logs for any routing or certificate errors

## Troubleshooting

### Certificate Issues
- Check Traefik logs for certificate request failures
- Ensure DNS records are properly configured
- Check the logs of the `mailcow_acme` container

### Routing Problems
- Verify network connectivity between Traefik and Mailcow
- Check that the Mailcow IP address is correct in Traefik configuration
- Make sure all required ports are open in firewalls

### Service Access Issues
- Verify the `Host` rules match your actual domain names
- Check that Mailcow services are running and accessible on port 80 internally
