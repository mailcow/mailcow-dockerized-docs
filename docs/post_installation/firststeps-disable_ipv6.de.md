## mailcow Versionen ab 2025-08

Ab dem Update 2025-08 kann IPv6 im mailcow Stack bequem gesteuert werden.

Dazu genügt eine einfache Anpassung der Variable in der mailcow.conf:

```bash
ENABLE_IPv6=false
```

!!! info "Hinweis"
    Ab 2025-08 ist diese Variable standardmäßig aktiviert (`true`), sofern das System IPv6-Konnektivität unterstützt. Dadurch wird IPv6 auch innerhalb der Container aktiviert.

Nach der Änderung muss der gesamte mailcow Stack neu gestartet werden:

=== "docker compose (Plugin)"

    ```bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose down
    docker-compose up -d
    ```

Dabei wird das mailcow Docker-Netzwerk basierend auf der Einstellung in der mailcow.conf neu erstellt.

??? question "Schon gewusst?"
    Seit dem Update 2025-08 gibt es einen Helfer im Update-Skript, der die IPv6-Einstellungen im Docker Daemon basierend auf Ihrer Hostkonfiguration anpassen kann.

    In den meisten Fällen funktioniert dies problemlos, da die JSON-Datei mit dem Werkzeug `jq` vorsichtig bearbeitet wird, um Werte sauber zu integrieren oder zu entfernen.

    Der Helfer weist Sie so lange auf notwendige Anpassungen hin, bis die Datei daemon.json korrekt konfiguriert ist (entweder IPv6-kompatibel oder nicht), um einen reibungslosen und fehlerfreien Betrieb zu gewährleisten.

Weitere Änderungen sind nicht erforderlich, da diese Einstellungen alle internen IPv6-Adressen steuern.

Alle mailcow-Dienste sind so konfiguriert, dass sie sowohl auf IPv4 als auch auf IPv6 (falls aktiviert) lauschen. Wenn nur eine IPv4-Adresse für das Container-Netzwerk verfügbar ist, wird ausschließlich diese für die Dienste verwendet.

!!! danger "Aber Achtung"
    Sollten Sie eine IPv6-Adresse auf Ihrem Host verwenden und der Docker Daemon nicht korrekt konfiguriert sein (was normalerweise durch einen Helfer im Update-Prozess erkannt und behoben wird), kann dies zu einem Open-Relay führen. 

    Dies geschieht, weil Docker standardmäßig IPv6-Adressen in interne IPv4-Adressen übersetzt (NAT). Wenn der Docker Daemon nicht korrekt konfiguriert ist, kann es passieren, dass externe IPv6-Adressen fälschlicherweise als interne Adressen interpretiert werden. Dadurch könnten Spammer über eine fehlerhaft übersetzte IPv6-Adresse Spam über Ihren Server versenden. 

    Auf Docker Netzwerkebene ist dies besonders kritisch, da interne Container-Adressen oft weniger strengen Sicherheitsmechanismen unterliegen. Insbesondere bei der Kommunikation zwischen dem Webmailer und dem Postfix (SMTP)-Server könnten Sicherheitslücken entstehen, wenn die Netzwerkübersetzung nicht korrekt funktioniert.

    Es ist daher essenziell, den Docker Daemon anhand der Systemkonfiguration anzupassen. Der Daemon sollte so konfiguriert sein, dass er die tatsächliche IPv6-Konnektivität des Hosts widerspiegelt. Dies verhindert fehlerhafte NAT-Regeln und stellt sicher, dass IPv6-Adressen korrekt behandelt werden. 
    
    **Kontrollieren Sie nach Netzwerkänderungen immer Ihre Docker Netzwerk-Konfigurationen, um sicherzustellen, dass keine ungewollten Sicherheitslücken entstehen.**

---    

## Ältere mailcow Versionen (pre 2025-08)

!!! danger "ACHTUNG"
    Bei Installationen, welche eine Docker Version <b>zwischen 25.0.0 und 25.0.2</b> (zum überprüfen nutzt `docker version`) verwenden hat sich das Verhalten der IPv6-Adressen Allokation durch einen Bug verändert. Ein simples `enable_ipv6: false` reicht damit **NICHT** mehr aus, um IPv6 komplett im Stack zu deaktivieren. <br>Dies war ein Bug im Docker Daemon, welcher mit Version 25.0.3 gefixt wurde.

Dies wird **NUR** empfohlen, wenn Sie kein IPv6-fähiges Netzwerk auf Ihrem Host haben!

Wenn Sie es wirklich brauchen, können Sie die Verwendung von IPv6 in der Compose-Datei deaktivieren.
Zusätzlich können Sie auch den Start des Containers "ipv6nat-mailcow" deaktivieren, da er nicht benötigt wird, wenn Sie IPv6 nicht verwenden.

Anstatt die Datei docker-compose.yml direkt zu bearbeiten, ist es besser, eine Override-Datei zu erstellen
zu erstellen und Ihre Änderungen am Dienst dort zu implementieren. Leider scheint dies im Moment nur für Dienste zu funktionieren, nicht für Netzwerkeinstellungen.

Um IPv6 im mailcow-Netzwerk zu deaktivieren, öffnen Sie docker-compose.yml mit Ihrem bevorzugten Texteditor und suchen Sie nach dem Netzwerk-Abschnitt (er befindet sich am Ende der Datei).

**1.** Ändern Sie docker-compose.yml

Ändern Sie `enable_ipv6: true` in `enable_ipv6: false`:

```
networks:
  mailcow-network:
    [...]
    enable_ipv6: true # <<< auf false setzen
    ipam:
      driver: default
      config:
        - subnet: ${IPV4_NETWORK:-172.22.1}.0/24
    [...]
```

**2.** ipv6nat-mailcow deaktivieren

Um den ipv6nat-mailcow Container ebenfalls zu deaktivieren, gehen Sie in Ihr mailcow Verzeichnis und erstellen Sie eine neue Datei namens "docker-compose.override.yml":

**HINWEIS:** Wenn Sie bereits eine Override-Datei haben, erstellen Sie diese natürlich nicht neu, sondern fügen Sie die untenstehenden Zeilen entsprechend in Ihre bestehende Datei ein!

```
# cd /opt/mailcow-dockerized
# touch docker-compose.override.yml
```

Öffnen Sie die Datei in Ihrem bevorzugten Texteditor und tragen Sie folgendes ein:

```
services:

    ipv6nat-mailcow:
      image: bash:latest
      restart: "no"
      entrypoint: ["echo", "ipv6nat disabled in compose.override.yml"]
```

Damit diese Änderungen wirksam werden, müssen Sie den Stack vollständig stoppen und dann neu starten, damit Container und Netzwerke neu erstellt werden:


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

**3.** Deaktivieren Sie IPv6 in unbound-mailcow

Bearbeiten Sie `data/conf/unbound/unbound.conf` und setzen Sie `do-ip6` auf "no":

```
Server:
  [...]
  do-ip6: no
  [...]
```

unbound neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart unbound-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart unbound-mailcow
    ```

**4.** Deaktivieren Sie IPv6 in postfix-mailcow

Erstellen Sie `data/conf/postfix/extra.cf` und setzen Sie `smtp_address_preference` auf `ipv4`:

```
smtp_address_preference = ipv4
inet_protocols = ipv4
```

Starten Sie Postfix neu:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

**5.** Wenn im Docker Daemon IPv6 komplett deaktiviert ist:

Folgende Dovecot und Php-fpm Konfigurationsdateien anpassen

```
sed -i 's/,\[::\]//g' data/conf/dovecot/dovecot.conf
sed -i 's/\[::\]://g' data/conf/phpfpm/php-fpm.d/pools.conf
```

**6.** IPv6 Listener für NGINX deaktivieren

Setze `DISABLE_IPv6=y` in der Datei `mailcow.conf`.

Damit diese Änderung wirksam wird, muss der Container `nginx-mailcow` neu erstellt werden.

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```
