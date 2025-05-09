!!! warning "Wichtig"
    Lesen Sie zuerst [die Übersicht](r_p.md).

!!! danger "Vorsicht"
    Dies ist ein von der Community unterstützter Beitrag. Korrekturen sind willkommen.

Dieses Tutorial erklärt, wie man mailcow mit Traefik als Reverse-Proxy einrichtet, um HTTPS-Verbindungen, Domain-Routing und Zertifikatsmanagement zu handhaben.

## Voraussetzungen

- Traefik v2.x installiert und lauffähig
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
```

## Schritt 2: Konfigurieren der dynamischen Traefik-Konfiguration

Erstellen oder aktualisieren Sie Ihre dynamische Traefik-Konfigurationsdatei mit dem folgenden Inhalt:

```yaml
http:
  routers:
    mailcow-acme:
      entryPoints: web
      rule: "(Host(`mx.domain.com`) && PathPrefix(`/.well-known/acme-challenge/`))" # Der Host sollte gleich Ihrem MAILCOW_HOSTNAME sein
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
          - url: "http://10.0.0.16:80" # mailcow lokale IP und Webport
    mailcow-frontend:
      loadBalancer:
        servers:
          - url: "http://10.0.0.16:80" # mailcow lokale IP und Webport
```

**Wichtige Hinweise zu dieser Konfiguration:**

- Ersetzen Sie `mx.domain.com`, `mail.domain.com`, `autoconfig.domain.com` und `autodiscover.domain.com` durch Ihre tatsächlichen Domainnamen
- Aktualisieren Sie `10.0.0.16` mit der tatsächlichen IP-Adresse Ihres mailcow-Servers
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
- Prüfen Sie die Traefik-Protokolle auf Fehlschläge bei Zertifikatsanfragen
- Stellen Sie sicher, dass die DNS-Einträge ordnungsgemäß konfiguriert sind
- Prüfen Sie die Protokolle des `acme-mailcow` Containers

### Routing-Probleme
- Überprüfen Sie die Netzwerkverbindung zwischen Traefik und mailcow
- Stellen Sie sicher, dass die mailcow IP-Adresse in der Traefik-Konfiguration korrekt ist
- Vergewissern Sie sich, dass alle erforderlichen Ports in den Firewalls geöffnet sind

### Dienstzugriffsprobleme
- Prüfen Sie, ob die `Host` Regeln mit Ihren tatsächlichen Domainnamen übereinstimmen
- Stellen Sie sicher, dass die mailcow-Dienste intern auf Port 80 laufen und erreichbar sind
