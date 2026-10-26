# mailcow Alias Generator

[mailcow Alias Generator](https://github.com/Upellift99/mailcow-alias-generator) ist eine kleine,
selbst gehostete Webanwendung, die E-Mail-Aliase über die mailcow-API anlegt. Damit erhält jeder
Dienst seinen eigenen Wegwerf-Alias (z. B. `supabase1234@example.com`), der an Ihr echtes Postfach
weiterleitet — nützlich, um Anmeldungen voneinander zu trennen und zu erkennen, welcher Dienst
Ihre Adresse weitergegeben hat.

## Funktionen

- Alias-Erstellung mit einem Klick, mit zufälliger Endung, Live-Vorschau und QR-Code
- Mehrere Domains, auswählbar über ein Dropdown-Menü
- Mehrbenutzerfähig (eigenes Passwort und eigene Standard-Weiterleitung je Benutzer)
- Gehashte Passwörter, Rate-Limiting bei der Anmeldung und optional das datenschutzfreundliche
  [ALTCHA](https://altcha.org/)-Captcha
- Veröffentlichtes Docker-Image und Bereitstellung per Docker Compose

## Voraussetzungen

- Eine erreichbare mailcow-Instanz mit aktivierter API
- Ein mailcow-API-Schlüssel mit **Lese-/Schreibrechten** auf `alias` (und Leserechten auf `domains`)
- Docker und Docker Compose auf dem Host, der die Anwendung ausführt

!!! warning "Schützen Sie den API-Schlüssel"
    Die Anwendung speichert Ihren mailcow-API-Schlüssel in ihrer `config.json`. Binden Sie diese
    Datei schreibgeschützt ein, beschränken Sie den Zugriff auf die Anwendung (Reverse Proxy +
    HTTPS, Firewall/VPN) und verwenden Sie gehashte Passwörter.

## Installation

Ein vorgefertigtes Image wird in der GitHub Container Registry veröffentlicht. Das Repository muss
daher nicht geklont werden — es werden nur eine `docker-compose.yml` und eine `config.json`
benötigt:

``` bash
mkdir mailcow-alias-generator && cd mailcow-alias-generator

# Compose-Datei und Konfigurationsvorlage herunterladen
curl -O https://raw.githubusercontent.com/Upellift99/mailcow-alias-generator/main/docker-compose.yml
curl -o config.json https://raw.githubusercontent.com/Upellift99/mailcow-alias-generator/main/config.sample.json
```

Tragen Sie in der `config.json` Ihre `mailcow_url`, den API-Schlüssel, die Domains und die Benutzer
ein und starten Sie die Anwendung:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Die Oberfläche ist anschließend über den konfigurierten Port erreichbar (Standard `5000`, festgelegt
über `HOST_PORT`).

## Konfiguration

Minimale `config.json`:

``` json
{
  "mailcow_url": "https://mail.example.com",
  "api_key": "YOUR_MAILCOW_API_KEY",
  "domains": ["example.com"],
  "users": {
    "admin": {
      "password": "pbkdf2:sha256:...",
      "default_redirect": "admin@example.com",
      "description": "Administrator"
    }
  }
}
```

!!! tip
    Gehashte Passwörter erzeugen Sie mit `python generate_password_hash.py`. Die vollständige
    Konfiguration, die Einrichtung für mehrere Benutzer und die ALTCHA-Optionen sind in der
    [README](https://github.com/Upellift99/mailcow-alias-generator#readme) des Projekts beschrieben.

## Links

- Quellcode: <https://github.com/Upellift99/mailcow-alias-generator>
- Container-Image: `ghcr.io/upellift99/mailcow-alias-generator:latest`

!!! note
    Dies ist ein von der Community gepflegtes Projekt eines Drittanbieters und steht in keiner
    Verbindung zum mailcow-Team.
