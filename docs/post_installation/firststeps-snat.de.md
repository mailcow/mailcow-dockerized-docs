SNAT wird verwendet, um die Quelladresse der von mailcow gesendeten Pakete zu ändern.
Es kann verwendet werden, um die ausgehende IP-Adresse auf Systemen mit mehreren IP-Adressen zu ändern.

Öffnen Sie `mailcow.conf`, setzen Sie einen oder beide der folgenden Parameter:

```
# Benutze diese IPv4 für ausgehende Verbindungen (SNAT)
SNAT_TO_SOURCE=1.2.3.4

# Benutze dieses IPv6 für ausgehende Verbindungen (SNAT)
SNAT6_TO_SOURCE=dead:beef
```

Führen Sie folgendes aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Die Werte werden von netfilter-mailcow gelesen. netfilter-mailcow stellt sicher, dass die Post-Routing-Regeln auf Position 1 in der Netfilter-Tabelle stehen. Es löscht sie automatisch und legt sie neu an, wenn sie an einer anderen Position als 1 gefunden werden.

Überprüfen Sie die Ausgabe mit hilfe des folgendem Befehles um sicherzustellen, dass die SNAT-Einstellungen angewendet wurden:

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs --tail=200 netfilter-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose logs --tail=200 netfilter-mailcow
    ```