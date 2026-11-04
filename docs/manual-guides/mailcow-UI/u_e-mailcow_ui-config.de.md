Mehrere Konfigurationsparameter der mailcow-Benutzeroberfläche können geändert werden, indem eine Datei `data/web/inc/vars.local.inc.php` erstellt wird, die die Standardeinstellungen in `data/web/inc/vars.inc.php` überschreibt.

Die lokale Konfigurationsdatei ist über Updates von mailcow hinweg beständig. Versuchen Sie nicht, die Werte in `data/web/inc/vars.inc.php` zu ändern, sondern verwenden Sie diese als Vorlage für die lokale Überschreibung.

mailcow UI Konfigurationsparameter können verwendet werden, um...

- ...die Standardsprache zu ändern[^1]
- ...das Standard-Theme zu ändern (siehe [Design anpassen](u_e-mailcow_ui-design.md#standard-theme))
- ...eine Passwort-Komplexitäts-Regex zu setzen
- ...die Sichtbarkeit des privaten DKIM-Schlüssels aktivieren
- ...eine Größe für den Paginierungsauslöser festlegen
- ...Standard-Postfach-Attribute festlegen
- ...Sitzungs-Lebensdauern ändern
- ...feste App-Menüs erstellen (die nicht in der mailcow UI geändert werden können)
- ...ein Standard "To"-Feld für Relayhost-Tests einstellen
- ...ein Timeout für Docker API Anfragen setzen
- ...IP-Anonymisierung umschalten
- ...das Limit für falsche 2FA-Codes ändern (siehe [Zwei-Faktor-Authentifizierung](u_e-mailcow_ui-tfa.md#falsche-codes))
- ...festlegen, welche imapsync-Optionen als eigene Parameter in Sync-Jobs erlaubt sind (siehe [Sync Jobs](../../post_installation/firststeps-sync_jobs_migration.md#eigene-parameter))

PHP-FPM hält die PHP-Dateien im Cache (OPcache) und liest geänderte Dateien nicht neu ein. Nach einer Änderung an `data/web/inc/vars.local.inc.php` PHP-FPM neu starten:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart php-fpm-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart php-fpm-mailcow
    ```

[^1]: Um SOGos Standardsprache zu ändern, müssen Sie `data/conf/sogo/sogo.conf` bearbeiten und "English" durch Ihre bevorzugte Sprache ersetzen.