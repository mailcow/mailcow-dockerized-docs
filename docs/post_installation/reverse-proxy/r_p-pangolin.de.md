!!! warning "Wichtig"
    Lesen Sie zuerst [die Übersicht](r_p.md).

!!! danger "Vorsicht"
    Dies ist ein von der Community unterstützter Beitrag. Korrekturen sind willkommen.

Die deklarative Konfiguration von Pangolin ist mittels sogenannter Blueprints sehr simpel.

In diesem Beispiel wird die Zertifikatserstellung durch Pangolin übernommen. Das SSO von Pangolin ist aktiv und bieter zusätzlichen Schutz. Autodiscover, Autoconfig und MTA-STS, sowie die API für den Status sind öffentlich zugänglich.

## Blueprint für Pangolin

Es wird angenommen, dass mailcow auf Port 4443 über TLS erreichbar ist.
Die Domain `example.com` ist entsprechend zu ersetzern.
Entsprechende Zeilen sind unten markiert.

```yaml hl_lines="5 12 21 28 37 44 53 60 69 76"
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

## In lokale Pangolin Instanz integrieren

Wenn Pangolin und mailcow auf dem selben Server laufen, kann der Blueprint über das Webinterface hinzugfügt werden.

> Organisation > Blaupausen > Blueprint hinzufügen

## In remote Pangolin Instanz integrieren

Die Einbindung in eine bestehende Pangolin-Instanz ist dank newt schnell erledigt:

> Standorte > Standort hinzufügen > Newt Standort > Docker

Die Umgebungsvariable `BLUEPRINT_FILE` wird hinzugefügt, exemplarisch liegt obrige Konfigurationsdatei unter `/opt/blueprint_mailcow.yml`.

```yaml hl_lines="10"
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

## Zertifikate exportieren

Da Pangolin zukünftig die Zertifikate erneuert, müssen diese auch für mailcow aktualisiert werden.

Pangolins Compose Konfiguration wie folgt erweitern und markierte Zeilen anpassen:

```yaml hl_lines="7 13 20"
services:

  [...]

  traefik_certdumper:
    command:
      - --restart-containers=mailcowdockerized-postfix-mailcow-1,mailcowdockerized-dovecot-mailcow-1,mailcowdockerized-nginx-mailcow-1
    container_name: traefik_certdumper
    depends_on:
      traefik:
        condition: service_started
    environment:
      - DOMAIN=*.example.com
    image: ghcr.io/kereis/traefik-certs-dumper:latest
    network_mode: none
    restart: unless-stopped
    volumes:
      - /run/docker.sock:/var/run/docker.sock:ro
      - ./config/letsencrypt:/traefik:ro
      - /opt/mailcow-dockerized/data/assets/ssl:/output:rw
```
