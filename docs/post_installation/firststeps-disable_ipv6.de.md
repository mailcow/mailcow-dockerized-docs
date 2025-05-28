!!! failure "Anpassung erforderlich"
    Bei älteren Setups muss diese Anleitung mit Update 2025-06 erneuert werden um die vollständige Kompatibilität zu gewährleisten.

??? warning "Vorsicht bei Docker Version 25"
    Bei Installationen mit Docker-Versionen <b>zwischen 25.0.0 und 25.0.2</b> (Version prüfen mit `docker version`) hat sich das Verhalten der IPv6-Adressvergabe durch einen Bug verändert. Ein einfaches `enable_ipv6: false` reicht **nicht** mehr aus, um IPv6 im Stack vollständig zu deaktivieren. <br>Der Bug wurde mit Version 25.0.3 im Docker Daemon behoben.

!!! danger "Vorsicht: Open Relay-Gefahr"
    Auch bei deaktiviertem IPv6 in Docker kann es zu einem Open Relay kommen, wenn der Server weiterhin eine öffentliche IPv6-Adresse besitzt. 
    
    Grund: Docker deaktiviert IPv6 nur im Container, nicht jedoch auf dem Host. Anfragen über IPv6 erreichen den Container weiterhin und erscheinen dort als interne IPv4 – was ein Sicherheitsrisiko darstellt.

    mailcow erlaubt zur internen Kommunikation **alle** internen Container-IP-Adressen aus dem Docker-Netzwerk (IPv4 und IPv6) ohne Authentifizierung, z. B. zum Postfix.

    Bei fehlerhafter IPv6-Konfiguration erscheinen externe Zugriffe als interne Docker-IP und werden nicht geprüft – dies führt zu einem Open Relay.

Diese Schritte werden **nur empfohlen**, wenn Ihr Hostsystem kein funktionierendes IPv6-Netzwerk verwendet!

## 0. IPv6 am Hostsystem deaktivieren

??? question "Warum das?"
    Wird IPv6 nur im Docker-Netzwerk deaktiviert, aber bleibt auf dem Host aktiv (z. B. durch eine öffentliche IPv6-Adresse am Interface), dann können weiterhin Verbindungen über IPv6 auf die Container geroutet werden. Dabei wird die ursprüngliche IPv6-Verbindung in eine interne IPv4-Verbindung übersetzt (z. B. über NAT oder das interne Routing-Verhalten von Docker). Das führt dazu, dass Postfix die Anfrage als vertrauenswürdig einstuft, weil sie scheinbar aus dem internen Netzwerk stammt – obwohl sie tatsächlich extern ist. Das Resultat: ein funktionierender Open Relay.

    Nur wenn IPv6 **am Hostsystem selbst** komplett deaktiviert ist, wird verhindert, dass überhaupt IPv6-Verbindungen in das Docker-Netz oder zu mailcow durchdringen.

### Temporär (bis zum Reboot):

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
```

### Permanent:

In `/etc/sysctl.conf` eintragen:

```bash
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
```

Dann anwenden:

```bash
sysctl -p
```

## 1. Im mailcow Netzwerk deaktivieren

=== "Neue Logik (Ab Update 2025-06)"

    In `mailcow.conf` den Wert: `ENABLE_IPV6` auf `false` setzen.

=== "Vorherige Installationen"

    In `docker-compose.yml` im Abschnitt `networks`:

    ``` yml
    networks:
      mailcow-network:
        [...]
        enable_ipv6: false # von true auf false setzen
        ipam:
          driver: default
          config:
            - subnet: ${IPV4_NETWORK:-172.22.1}.0/24
        [...]
    ```

## 2. ipv6nat-mailcow deaktivieren

=== "Neue Logik (Ab Update 2025-06)"

    !!! warning "Vorsicht"
        Der ipv6nat-mailcow Container ist seit dem Update 2025-06 nicht mehr teil der mailcow Container.
        
        Dieser Schritt entfällt demnach.

=== "Vorherige Installationen"

    ```bash
    cd /opt/mailcow-dockerized
    touch docker-compose.override.yml
    ```

    Mit dem folgenden Inhalt füllen:

    ```yml
    services:
    ipv6nat-mailcow:
        image: bash:latest
        restart: "no"
        entrypoint: ["echo", "ipv6nat disabled in compose.override.yml"]
    ```

## 3. Stack neu starten

!!! notice "Hinweis" 
    Dies betrifft alle Setups.

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

## 4. IPv6 in unbound deaktivieren (Optional)

!!! notice "Hinweis" 
    Dies betrifft alle Setups.

In `data/conf/unbound/unbound.conf`:

    server:
      [...]
      do-ip6: no
      [...]

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart unbound-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart unbound-mailcow
    ```

## 5. IPv6 in postfix deaktivieren (Optional)

!!! notice "Hinweis" 
    Dies betrifft alle Setups.

In `data/conf/postfix/extra.cf`:

    smtp_address_preference = ipv4
    inet_protocols = ipv4

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

## 6. IPv6 in dovecot und php-fpm deaktivieren (Optional)

!!! notice "Hinweis" 
    Dies betrifft alle Setups.

```bash
sed -i 's/,\[::\]//g' data/conf/dovecot/dovecot.conf
sed -i 's/\[::\]://g' data/conf/phpfpm/php-fpm.d/pools.conf
```


## 7. IPv6 Listener in nginx deaktivieren

=== "Neue Logik (Ab Update 2025-06)"

    Wird durch `ENABLE_IPV6=false` in `mailcow.conf` automatisch gepatcht [(siehe Schritt 1)](#1-im-mailcow-netzwerk-deaktivieren)

=== "Vorherige Installationen"

    In `mailcow.conf`:

        DISABLE_IPv6=y

    === "docker compose (Plugin)"

        ``` bash
        docker compose up -d
        ```

    === "docker-compose (Standalone)"

        ``` bash
        docker-compose up -d
        ```