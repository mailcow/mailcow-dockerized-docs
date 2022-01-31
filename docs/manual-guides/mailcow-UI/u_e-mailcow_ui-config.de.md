Mehrere Konfigurationsparameter der mailcow-Benutzeroberfläche können geändert werden, indem eine Datei `data/web/inc/vars.local.inc.php` erstellt wird, die die Standardeinstellungen in `data/web/inc/vars.inc.php` überschreibt.

Die lokale Konfigurationsdatei ist über Updates von mailcow hinweg beständig. Versuchen Sie nicht, die Werte in `data/web/inc/vars.inc.php` zu ändern, sondern verwenden Sie diese als Vorlage für die lokale Überschreibung.

mailcow UI Konfigurationsparameter können verwendet werden, um...

- ...die Standardsprache zu ändern[^1]
- ...das Standard-Bootstrap-Theme zu ändern
- ...eine Passwort-Komplexitäts-Regex zu setzen
- ...die Sichtbarkeit des privaten DKIM-Schlüssels aktivieren
- ...eine Größe für den Paginierungsauslöser festlegen
- ...Standard-Postfach-Attribute festlegen
- ...Sitzungs-Lebensdauern ändern
- ...feste App-Menüs erstellen (die nicht in der mailcow UI geändert werden können)
- ...ein Standard "To"-Feld für Relayhost-Tests einstellen
- ...ein Timeout für Docker API Anfragen setzen
- ...IP-Anonymisierung umschalten

[^1]: Um SOGos Standardsprache zu ändern, müssen Sie `data/conf/sogo/sogo.conf` bearbeiten und "English" durch Ihre bevorzugte Sprache ersetzen.