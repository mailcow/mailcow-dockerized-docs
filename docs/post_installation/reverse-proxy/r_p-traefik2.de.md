!!! warning "Wichtig"
    Lesen Sie zuerst [die Übersicht](r_p.md).

!!! warning "Warnung"
    Dies ist ein nicht unterstützter Community Beitrag. Korrekturen sind immer erwünscht!

**Wichtig**: Diese Konfiguration deckt nur das "Reverseproxing" des Webpanels (nginx-mailcow) unter Verwendung von Traefik v2 ab. Wenn Sie auch die Mail-Dienste wie dovecot, postfix... reproxen wollen, müssen Sie die folgende Konfiguration an jeden Container anpassen und einen [EntryPoint](https://docs.traefik.io/routing/entrypoints/) in Ihrer `traefik.toml` oder `traefik.yml` (je nachdem, welche Konfiguration Sie verwenden) für jeden Port erstellen. 

In diesem Abschnitt gehen wir davon aus, dass Sie Ihren Traefik 2 `[certificatesresolvers]` in Ihrer Traefik-Konfigurationsdatei richtig konfiguriert haben und auch acme verwenden. Das folgende Beispiel verwendet Lets Encrypt, aber Sie können es gerne auf Ihren eigenen Zertifikatsresolver ändern. Eine grundlegende Traefik 2 toml-Konfigurationsdatei mit allen oben genannten Elementen, die für dieses Beispiel verwendet werden kann, finden Sie hier [traefik.toml](https://github.com/Frenzoid/TraefikBasicConfig/blob/master/traefik.toml), falls Sie eine solche Datei benötigen oder einen Hinweis, wie Sie Ihre Konfiguration anpassen können.

Zuallererst werden wir den acme-mailcow-Container deaktivieren, da wir die von traefik bereitgestellten Zertifikate verwenden werden.
Dazu müssen wir `SKIP_LETS_ENCRYPT=y` in unserer `mailcow.conf` setzen und den folgenden Befehl ausführen, um die Änderungen zu übernehmen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Dann erstellen wir eine `docker-compose.override.yml` Datei, um die Hauptdatei `docker-compose.yml` zu überschreiben, die sich im mailcow-Stammverzeichnis befindet. 

```yaml
services:
    nginx-mailcow:
      networks:
        # Traefiks Netzwerk hinzufügen
        web:
      labels:
        - traefik.enable=true
        # Erstellt einen Router namens "moo" für den Container und richtet eine Regel ein, um den Container mit einer bestimmten Regel zu verknüpfen,
        # in diesem Fall eine Host-Regel mit unserer MAILCOW_HOSTNAME-Variable.
        - traefik.http.routers.moo.rule=Host(`${MAILCOW_HOSTNAME}`)
        # Aktiviert tls über den zuvor erstellten Router.
        - traefik.http.routers.moo.tls=true
        # Gibt an, welche Art von Cert-Resolver wir verwenden werden, in diesem Fall le (Lets Encrypt).
        - traefik.http.routers.moo.tls.certresolver=le
        # Erzeugt einen Dienst namens "moo" für den Container und gibt an, welchen internen Port des Containers
        # Traefik die eingehenden Daten weiterleiten soll.
        - traefik.http.services.moo.loadbalancer.server.port=${HTTP_PORT}
        # Gibt an, welchen Eingangspunkt (externer Port) traefik für diesen Container abhören soll.
        # Websecure ist Port 443, siehe die Datei traefik.toml wie oben.
        - traefik.http.routers.moo.entrypoints=websecure
        # Stellen Sie sicher, dass traefik das Web-Netzwerk verwendet, nicht das mailcowdockerized_mailcow-network
        - traefik.docker.network=traefik_web

    certdumper:
        image: ghcr.io/kereis/traefik-certs-dumper
        command: --restart-containers ${COMPOSE_PROJECT_NAME}-postfix-mailcow-1,${COMPOSE_PROJECT_NAME}-nginx-mailcow-1,${COMPOSE_PROJECT_NAME}-dovecot-mailcow-1
        network_mode: none
        volumes:
          # Binden Sie das Volume, das Traefiks `acme.json' Datei enthält, ein
          - acme:/traefik:ro
          # SSL-Ordner von mailcow einhängen
          - ./data/assets/ssl/:/output:rw
          # Binden Sie den Docker Socket ein, damit traefik-certs-dumper die Container neu starten kann
          - /var/run/docker.sock:/var/run/docker.sock:ro
        restart: always
        environment:
          # Ändern Sie dies nur, wenn Sie eine andere Domain für mailcows Web-Frontend verwenden als in der Standard-Konfiguration
          - DOMAIN=${MAILCOW_HOSTNAME}

networks:
  web:
    external: true
    # Name des externen Netzwerks
    name: traefik_web

volumes:
  acme:
    external: true
    # Name des externen Docker Volumes, welches Traefiks `acme.json' Datei enthält
    name: traefik_acme
```

Starten Sie die neuen Container mit:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

Da Traefik 2 ein acme v2 Format verwendet, um ALLE Zertifikaten von allen Domains zu speichern, müssen wir einen Weg finden, die Zertifikate auszulagern. Zum Glück haben wir [diesen kleinen Container] (https://hub.docker.com/r/humenius/traefik-certs-dumper), der die Datei `acme.json` über ein Volume und eine Variable `DOMAIN=example. org`, und damit wird der Container die `cert.pem` und `key.pem` Dateien ausgeben, dafür lassen wir einfach den `traefik-certs-dumper` Container laufen, binden das `/traefik` Volume an den Ordner, in dem unsere `acme.json` gespeichert ist, binden das `/output` Volume an unseren mailcow `data/assets/ssl/` Ordner, und setzen die `DOMAIN=example.org` Variable auf die Domain, von der wir die Zertifikate ausgeben wollen. 

Dieser Container überwacht die Datei `acme.json` auf Änderungen und generiert die Dateien `cert.pem` und `key.pem` direkt in `data/assets/ssl/`, wobei der Pfad mit dem `/output`-Pfad des Containers verbunden ist.

Sie können es über die Kommandozeile ausführen oder das [hier](https://hub.docker.com/r/humenius/traefik-certs-dumper) gezeigte docker-compose.yml verwenden.

Nachdem wir die Zertifikate übertragen haben, müssen wir die Konfigurationen aus unseren Postfix- und Dovecot-Containern neu laden und die Zertifikate überprüfen. Wie das geht, sehen Sie [hier](https://docs.mailcow.email/de/post_installation/firststeps-ssl/#ein-eigenes-zertifikat-verwenden).

Und das sollte es gewesen sein 😊, Sie können überprüfen, ob der Traefik-Router einwandfrei funktioniert, indem Sie das Dashboard von Traefik / traefik logs / über https auf die eingestellte Domain zugreifen, oder / und HTTPS, SMTP und IMAP mit den Befehlen auf der zuvor verlinkten Seite überprüfen.
