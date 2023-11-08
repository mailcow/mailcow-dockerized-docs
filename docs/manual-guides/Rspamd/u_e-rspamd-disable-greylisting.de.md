!!! info "Hinweis"
    In dieser Anleitung gehen wir von dem standard mailcow Pfad (`/opt/mailcow-dockerized`) aus.<br>
    *Der Pfad in Ihrer Installation kann möglicherweise variieren!*

---

Nur Nachrichten mit einem höheren Rspamd Score werden Greylisted (soft rejected). 

Wir selbst empfehlen **NICHT** das Greylisting zu deaktivieren.

Falls Sie einen validen Grund dafür sehen, dass Greylisting zu deaktivieren, können Sie dies serverweit durch das Editieren der `greylist.conf` deaktivieren:

`/opt/mailcow-dockerized/data/conf/rspamd/local.d/greylist.conf`

Fügen Sie die Zeile hinzu:

```cpp
enabled = false;
```

Speichern Sie die Datei und starten Sie "rspamd-mailcow" neu:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

Das Greylisting ist nun **serverweit** deaktiviert!