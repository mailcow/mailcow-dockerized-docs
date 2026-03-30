!!! warning "Important"
    First read [the overview](r_p.md).

!!! danger
    This is an community supported contribution. Feel free to provide fixes.

Pangolin's declarative configuration is very simple using so-called Blueprints.

In this example, certificate creation is handled by Pangolin. Pangolin's SSO is active and provides additional protection. Autodiscover, Autoconfig, and MTA-STS, as well as the API for status, are publicly accessible.

It is assumed that mailcow is accessible on port 4443 via TLS.
The domain `example.com` should be replaced accordingly.

```yaml
public-resources:
  mailcow:
    auth:
      sso-enabled: true
    full-domain: autoconfig.example.com
    name: Mail - mailcow - Autoconfig
    protocol: http
    ssl: true
    targets:
      - hostname: localhost
        method: https
        port: 4443
    rules:
      - action: allow
        match: path
        value: /api/v1/get/status/*

  mailcow-autoconfig:
    auth:
      sso-enabled: true
    full-domain: autoconfig.example.com
    name: Mail - mailcow - Autoconfig
    protocol: http
    ssl: true
    targets:
      - hostname: localhost
        method: https
        port: 4443
    rules:
      - action: allow
        match: path
        value: /mail/config-v1.1.xml
        
  mailcow-autodiscover:
    auth:
      sso-enabled: true
    full-domain: autodiscover.example.com
    name: Mail - mailcow - Autodiscover
    protocol: http
    ssl: true
    targets:
      - hostname: localhost
        method: https
        port: 4443
    rules:
      - action: allow
        match: path
        value: /autodiscover/autodiscover.xml

  mailcow-mta-sts:
    auth:
      sso-enabled: true
    full-domain: mta-sts.example.com
    name: Mail - mailcow - MTA-STS
    protocol: http
    ssl: true
    targets:
      - hostname: localhost
        method: https
        port: 4443
    rules:
      - action: allow
        match: path
        value: /.well-known/mta-sts.txt

  mailcow-openpgpkey:
    auth:
      sso-enabled: true
    full-domain: openpgpkey.example.com
    name: Mail - mailcow - OpenPGP-Key
    protocol: http
    ssl: true
    targets:
      - hostname: localhost
        method: https
        port: 4443
    rules:
      - action: allow
        match: path
        value: /.well-known/openpgpkey/*
```

Integration into an existing Pangolin instance is quick and easy with newt:

> Sites > Create Sites > Newt Site > Docker

The environment variable `BLUEPRINT_FILE` is added. As an example, the configuration file above is located at `/opt/blueprint_mailcow.yml`.

```yaml
services:
  newt:
    image: fosrl/newt
    container_name: newt
    restart: unless-stopped
    environment:
      - PANGOLIN_ENDPOINT=https://pangolin.example.com
      - NEWT_ID=<YOUR_ID>
      - NEWT_SECRET=<YOUR_SECRET>
      - BLUEPRINT_FILE=/opt/blueprint_mailcow.yml
```
