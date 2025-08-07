Rspamd wird für die AV-Verarbeitung, DKIM-Signierung und SPAM-Verarbeitung verwendet. Es ist ein leistungsfähiges und schnelles Filtersystem. Für eine ausführlichere Dokumentation über Rspamd besuchen Sie bitte die [Rspamd Dokumentation] (https://docs.rspamd.com/).

## UI Zugang

Rspamd bietet eine umfangreiche WebUI, welche jeder mailcow: dockerized Installation beiliegt.

Diese ist mit einem Login versehen, welcher während der initialen Installation auf ein zufälliges Passwort gesetzt wird um den Zugang dritter zu verweigern.

Damit Sie sich in die Rspamd UI einloggen können müssen Sie zunächst ein eigenes Passwort für die Rspamd Oberfläche setzen.

Dies tun Sie wie folgt:

1. Loggen Sie sich als Administrator in ihrer **mailcow UI** ein.
2. Wechseln Sie auf den Reiter (oben links) `System` :material-chevron-right: `Konfiguration` und dort den Unterreiter: `Zugang` :material-chevron-right: `Rspamd UI`.
3. Ändern Sie hier das Rspamd UI Passwort, bzw. legen Sie eines fest.
4. Gehen Sie in einem Browser zu https://${MAILCOW_HOSTNAME}/rspamd und melden Sie sich an!

Weitere Konfigurationsoptionen und Dokumentation zur WebUI finden Sie hier: https://docs.rspamd.com/

---

## CLI-Werkzeuge

Rspamd bietet eine vielzahl von Befehlen, welche via CLI benutzt werden können.

Geben Sie folgende Befehle ein, um einen Überblick auf diese zu erhalten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec rspamd-mailcow rspamc --help
    docker compose exec rspamd-mailcow rspamadm --help
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec rspamd-mailcow rspamc --help
    docker-compose exec rspamd-mailcow rspamadm --help
    ```
---

## Speicherung der Historie erhöhen

Standardmäßig speichert Rspamd 1000 Elemente in der Historie.

Die Historie wird komprimiert gespeichert.

Es wird empfohlen, hier keinen unverhältnismäßig hohen Wert zu verwenden, probieren Sie etwas in der Größenordnung von 5000 oder 10000 und sehen Sie, wie Ihr Server damit umgeht:

Bearbeiten Sie `data/conf/rspamd/local.d/history_redis.conf`:

```
nrows = 1000; # Ändern Sie diesen Wert
```

Starten Sie anschließend Rspamd neu:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```
---


## Lösche alle Ratelimit-Schlüssel

Wenn Sie die mailcow UI nicht verwenden wollen und stattdessen alle Schlüssel in der Redis-Datenbank löschen wollen, können Sie redis-cli für diese Aufgabe verwenden:
=== "docker compose (Plugin)"

    ``` bash
    docker compose exec redis-mailcow sh
    # Unlink (verfügbar in Redis >=4.) löscht im Hintergrund
    redis-cli --scan --pattern RL* | xargs redis-cli unlink
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec redis-mailcow sh
    # Unlink (verfügbar in Redis >=4.) löscht im Hintergrund
    redis-cli --scan --pattern RL* | xargs redis-cli unlink
    ```

Starten Sie Rspamd neu:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```
