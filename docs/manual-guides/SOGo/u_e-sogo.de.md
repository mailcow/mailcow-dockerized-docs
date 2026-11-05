SOGo wird verwendet, um über einen Webbrowser auf Ihre Mails zuzugreifen und Ihre Kontakte oder Kalender hinzuzufügen und zu teilen. Für eine ausführlichere Dokumentation zu SOGo besuchen Sie bitte die [Dokumentation von SOGo](https://www.sogo.nu/files/docs/SOGoInstallationGuide.html).

## Theme, Logo und Favicon

Theme, Logo und Favicon von SOGo sind unter [Design anpassen](../mailcow-UI/u_e-mailcow_ui-design.md#sogo) beschrieben.

## Domains verbinden (untereinander sichtbar machen)
Domains sind normalerweise voneinander isoliert.

Sie können das ändern, indem Sie `data/conf/sogo/sogo.conf` modifizieren:

Suche...
```
   // SOGoDomainsVisibility = (
    // (domain1.tld, domain5.tld),
    // (domain3.tld, domain2.tld)
    // );
```
...und ersetzen Sie diese durch - zum Beispiel:

```
    SOGoDomainsVisibility = (
      (beispiel.org, beispiel.com, beispiel.net)
    );
```

SOGo neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart sogo-mailcow
    ```

## Aktivieren der Passwortänderung in SOGo

Die Möglichkeit ihr Passwort in SOGo zu ändern wurde standardmäßig deaktiviert, da:

+ es nicht die Passwortrichtlinien der mailcow UI beachten kann.
+ es nicht funktioniert, wenn ein User sich direkt in SOGo angemeldet hat (über die mailcow UI) `In Webmail einloggen` (Auth Proxy)

Sollten Sie diese Funktion dennoch aktiviert haben wollen bearbeiten Sie einfach `data/conf/sogo/sogo.conf` und **ändern** `SOGoPasswordChangeEnabled` zu `YES`. Bitte hier keine anderen Parameter außer `YES` oder `NO` verwenden.

Anschließend SOGo neustarten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow sogo-mailcow
    ```

## TOTP zurücksetzen / TOTP deaktivieren

Führen Sie folgenden Befehl aus dem mailcow Verzeichnis aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec -u sogo sogo-mailcow sogo-tool user-preferences set defaults user@example.com SOGoTOTPEnabled '{"SOGoTOTPEnabled":0}'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec -u sogo sogo-mailcow sogo-tool user-preferences set defaults user@example.com SOGoTOTPEnabled '{"SOGoTOTPEnabled":0}'
    ```

