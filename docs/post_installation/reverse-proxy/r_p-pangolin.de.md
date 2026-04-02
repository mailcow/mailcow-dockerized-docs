!!! warning "Wichtig"
    Lesen Sie zuerst [die Übersicht](r_p.md).

!!! danger "Vorsicht"
    Dies ist ein von der Community unterstützter Beitrag. Korrekturen sind willkommen.

Die deklarative Konfiguration von Pangolin ist mittels sogenannter Blueprints sehr simpel.

In diesem Beispiel wird die Zertifikatserstellung durch Pangolin übernommen. Das SSO von Pangolin ist aktiv und bieter zusätzlichen Schutz. Autodiscover, Autoconfig und MTA-STS, sowie die API für den Status sind öffentlich zugänglich.

Es wird angenommen, dass mailcow auf Port 4443 über TLS erreichbar ist.
Die Domain `example.com` ist entsprechend zu ersetzern.

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

Die Einbindung in eine bestehende Pangolin-Instanz ist dank newt schnell erledigt:

> Standorte > Standort hinzufügen > Newt Standort > Docker

Die Umgebungsvariable `BLUEPRINT_FILE` wird hinzugefügt, exemplarisch liegt obrige Konfigurationsdatei unter `/opt/blueprint_mailcow.yml`.

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
