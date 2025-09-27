!!! warning "Wichtig"
    Lesen Sie zuerst [die Übersicht](r_p.md).

!!! danger "Vorsicht"
    Dies ist ein von der Community unterstützter Beitrag. Korrekturen sind willkommen.

Dieses Tutorial erklärt, wie man mailcow mit Traefik als Reverse-Proxy einrichtet, um HTTPS-Verbindungen, Domain-Routing und Zertifikatsmanagement zu handhaben.

## Voraussetzungen

- Traefik v3.x installiert und lauffähig
- Domainnamen konfiguriert, die auf Ihren Server zeigen, gemäß [diesem Leitfaden](https://docs.mailcow.email/getstarted/prerequisite-dns/)

## Überblick

Traefik übernimmt den gesamten eingehenden Webverkehr und leitet die entsprechenden Anfragen an mailcow weiter. Diese Konfiguration ermöglicht es Traefik:

- SSL-Zertifikate zu verwalten
- Autodiscover- und Autoconfig-Dienste bereitzustellen
- Die Frontend-Benutzeroberfläche zu bedienen
- ACME-Challenge-Antworten für die Zertifikatsvalidierung des Mail-Servers zu übernehmen

## Schritt 1: Aktualisieren der mailcow-Konfiguration

Ändern Sie zunächst Ihre `mailcow.conf` oder `.env` Datei, um die SSL-Handhabung von mailcow zu deaktivieren:

```bash
# Deaktiviere mailcow Autodiscover SAN
AUTODISCOVER_SAN=n

# Überspringe ACME (acme-mailcow, Let's Encrypt Zertifikate) - y/n
SKIP_LETS_ENCRYPT=y
```

## Traefik-Konfiguration

=== "Dynamische Konfiguration"

    Erstellen oder aktualisieren Sie Ihre dynamische Traefik-Konfigurationsdatei mit dem folgenden Inhalt:

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

      services:
        mailcow-svc:
          loadBalancer:
            servers:
              - url: "http://mailcow-nginx-mailcow-1:8080"
    ```

=== "Traefik Label Konfiguration"

    Fügen Sie folgendes in ihrer `docker-compose.yaml` Datei hinzu:

    ```yaml
    services:
      certdumper:
        image: ghcr.io/kereis/traefik-certs-dumper:latest
        container_name: traefik_certdumper
        restart: unless-stopped
        network_mode: none
        command: --restart-containers mailcow_postfix-mailcow_1,mailcow_dovecot-mailcow_1
        volumes:
          - traefik_certs:/traefik:ro # Traefik Zertifikate einhängen
          - /var/run/docker.sock:/var/run/docker.sock:ro
          - ./data/assets/ssl:/output:rw
        environment:
          - DOMAIN=domain.com
          - ACME_FILE_PATH=/traefik/cloudflare-acme.json # Dateipfad zur acme Datei

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

**Wichtige Hinweise zu dieser Konfiguration:**

- Ersetzen Sie `mail.domain.com`, `autoconfig.domain.com` und `autodiscover.domain.com` durch Ihre tatsächlichen Domainnamen
- `entryPoints: "websecure"` - ersetzen Sie dies durch Ihren tatsächlichen Traefik-HTTPS-Entrypoint
- `certResolver: cloudflare` - ersetzen Sie dies durch Ihren tatsächlichen Zertifikatsresolver

## Schritt 3: Neustarten der Dienste

Starten Sie beide Dienste neu, um die Änderungen zu übernehmen:

=== "docker compose (Plugin)"

    ``` bash
    # mailcow neustarten
    cd /path/to/mailcow-dockerized
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    # mailcow neustarten
    cd /path/to/mailcow-dockerized
    docker-compose up -d
    ```

## Testen der Konfiguration

1. Besuchen Sie `https://mail.domain.com`, um zu prüfen, ob die mailcow-Web-Oberfläche ordnungsgemäß geladen wird
2. Konfigurieren Sie einen E-Mail-Client, um die Autodiscover-Funktionalität zu testen
3. Überwachen Sie die Traefik-Protokolle auf eventuelle Routing- oder Zertifikatsfehler

## Problembehandlung

### Zertifikatsprobleme

- Prüfen Sie die Traefik-Certdumper Protokolle nach Fehlern
- Stellen Sie sicher, dass die acme Datei korrekt eingehängt ist

### Routing-Probleme

- Überprüfen Sie die Netzwerkverbindung zwischen Traefik und mailcow
- Stellen Sie sicher, dass die mailcow IP-Adresse in der Traefik-Konfiguration korrekt ist
- Vergewissern Sie sich, dass alle erforderlichen Ports in den Firewalls geöffnet sind
