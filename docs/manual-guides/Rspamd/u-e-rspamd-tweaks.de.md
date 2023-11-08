## Spamfilter-Schwellenwerte (global)

Jeder Benutzer kann [seine Spam-Bewertung](../mailcow-UI/u_e-mailcow_ui-spamfilter.de.md) individuell ändern. 

Um eine neue **serverweite** Grenze zu definieren, editieren Sie `data/conf/rspamd/local.d/actions.conf`:

```cpp
reject = 15;
add_header = 8;
greylist = 7;
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

!!! warning "Achtung"
    Bestehende Einstellungen der Benutzer werden nicht überschrieben!

Um benutzerdefinierte Schwellenwerte zurückzusetzen, führen Sie aus:
=== "docker compose (Plugin)"

    ``` bash
    source mailcow.conf
    docker compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel';"
    # oder:
    docker compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel' and object = 'only-this-mailbox@example.org';"
    ```

=== "docker-compose (Standalone)"

    ``` bash
    source mailcow.conf
    docker-compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel';"
    # oder:
    docker-compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel' and object = 'only-this-mailbox@example.org';"
    ```

---

## Benutzerdefinierte Ablehnungsnachrichten

Die Standard-Spam-Reject-Meldung kann durch Hinzufügen einer neuen Datei `data/conf/rspamd/override.d/worker-proxy.custom.inc` mit dem folgenden Inhalt geändert werden:

```
reject_message = "Meine eigene Ablehnungsnachricht";
```

Speichern Sie die Datei und starten Sie Rspamd neu:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

Während das oben genannte für abgelehnte Mails mit einem hohen Spam-Score funktioniert, ignorieren Prefilter-Aktionen diese Einstellung. Für diese muss das Multimap-Modul in Rspamd angepasst werden:

1. Finden Sie das Prefilet-Reject-Symbol, für das Sie die Nachricht ändern wollen, führen Sie dazu aus: `grep -R "SYMBOL_WELCHES_ANGEPASST_WERDEN_SOLL" /opt/mailcow-dockerized/data/conf/rspamd/`

2. Fügen Sie Ihre eigene Nachricht als neue Zeile hinzu:

    ```
    GLOBAL_RCPT_BL {
    Typ = "rcpt";
    map = "${LOCAL_CONFDIR}/custom/global_rcpt_blacklist.map";
    regexp = true;
    prefilter = true;
    action = "reject";
    message = "Der Versand von E-Mails an diesen Empfänger ist durch postmaster@your.domain verboten";
    }
    ```

3. Speichern Sie die Datei und starten Sie Rspamd neu:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

---

## E-Mails verwerfen (discard) anstatt zurückzuweisen (reject)

Wenn Sie eine Nachricht stillschweigend verwerfen wollen, erstellen oder bearbeiten Sie die Datei `data/conf/rspamd/override.d/worker-proxy.custom.inc` und fügen Sie den folgenden Inhalt hinzu:

```
discard_on_reject = true;
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