Wenn Sie einen externen DNS-Dienst verwenden wollen oder müssen, können Sie entweder einen Forwarder in Unbound einstellen oder eine Override-Datei kopieren, um externe DNS-Server zu definieren:

!!! warning "Warnung"
    Bitte verwenden Sie keinen öffentlichen Resolver, wie wir es im obigen Beispiel getan haben. Viele - wenn nicht sogar alle - Blacklist-Lookups werden mit öffentlichen Resolvern fehlschlagen, da der Blacklist-Server Grenzen hat, wie viele Anfragen von einer IP gestellt werden können und öffentliche Resolver diese Grenzen normalerweise erreichen. <br>
    **Wichtig**: Nur DNSSEC-validierende DNS-Dienste werden funktionieren.

## Methode A, Unbound

Bearbeiten Sie `data/conf/unbound/unbound.conf` und fügen Sie die folgenden Parameter hinzu:

```
forward-zone:
  name: "."
  forward-addr: 8.8.8.8 # VERWENDEN SIE KEINE ÖFFENTLICHEN DNS-SERVER - NUR EIN BEISPIEL
  forward-addr: 8.8.4.4 # VERWENDET KEINE ÖFFENTLICHEN DNS-SERVER - NUR EIN BEISPIEL
```

Unbound neu starten:

=== "docker compose (Plugin)"

    ``` bash
      docker compose restart unbound-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
      docker-compose restart unbound-mailcow
    ```


## Methode B, Überschreiben der Datei

```
cd /opt/mailcow-dockerized
cp helper-scripts/docker-compose.override.yml.d/EXTERNAL_DNS/docker-compose.override.yml .
```

Bearbeiten Sie `docker-compose.override.yml` und passen Sie die IP an.

Stoppen und starten Sie bitte im Anschluss noch den Docker Stack:

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