Über die mailcow API können andere Anwendungen die Konfiguration von mailcow lesen und ändern, z. B. für Monitoring oder automatisches Anlegen von Mailboxen. Alle Endpunkte sind auf der eigenen Instanz unter `https://<mailcow-host>/api` dokumentiert.

---

## API-Key anlegen

Unter `System > Konfiguration > Zugang > Administratoren` die Karte **API** öffnen und im Abschnitt **API-Keys** auf **API-Key hinzufügen** klicken:

* `Beschreibung`: Wofür der Key genutzt wird.
* `Zugang`: `Schreibgeschützter Zugriff` erlaubt nur Lesen, `Lese-Schreib-Zugriff` auch Änderungen.
* `IP-Adressen oder Netzwerke (CIDR Notation) für Zugriff auf API`: IP-Adressen oder Netzwerke, die den Key nutzen dürfen, eine pro Zeile, z. B. `192.0.2.10` oder `2001:db8::/64`.
* `IP-Check für API nicht ausführen`: Der Key funktioniert von jeder IP-Adresse. Nur sinnvoll, wenn die API nicht aus dem Internet erreichbar ist.
* `Aktiv`: Inaktive Keys werden abgewiesen.

Am besten pro Anwendung einen eigenen Key anlegen, dann lässt er sich einzeln deaktivieren oder löschen. Die Liste zeigt alle Keys, das Zwischenablage-Symbol daneben kopiert einen Key. **API-Key regenerieren** (unter **Aktionen** oder auf der Bearbeiten-Seite eines Keys) ersetzt einen Key durch einen neuen.

## Service-Keys aus der mailcow.conf

Keys für Skripte und automatisierte Setups lassen sich in der `mailcow.conf` festlegen:

```
API_KEY=
API_KEY_READ_ONLY=
API_ALLOW_FROM=172.22.1.1,127.0.0.1
```

* `API_KEY` hat Lese-Schreib-Zugriff, `API_KEY_READ_ONLY` nur Lesezugriff. Erlaubte Zeichen: `a-z`, `A-Z`, `0-9` und `-`.
* `API_ALLOW_FROM` ist eine kommagetrennte Liste von IP-Adressen oder Netzwerken. Ohne gültigen Eintrag werden beide Keys ignoriert.

mailcow übernimmt die Werte beim Start von PHP-FPM. Nach einer Änderung an der `mailcow.conf` die Container neu erstellen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

* Die Liste der API-Keys zeigt die Service-Keys als `API_KEY` und `API_KEY_READ_ONLY` mit einem Schloss-Symbol. Sie lassen sich nur in der `mailcow.conf` ändern: UI und API können sie weder deaktivieren noch regenerieren oder löschen.
* Ein aus der `mailcow.conf` entfernter Key wird gelöscht.
* Hat ein in der UI angelegter Key denselben Wert, wird er zum Service-Key.
* Ungültige Einträge in `API_ALLOW_FROM` und ungültige Keys werden übersprungen. Das Log von PHP-FPM zeigt dann eine Warnung, die mit `API service keys:` beginnt, z. B. mit `docker compose logs php-fpm-mailcow | grep "API service keys"`.

---

## API nutzen

Der Key wird im Header `X-API-Key` mitgeschickt:

```bash
curl -H "X-API-Key: API-KEY" https://mail.example.org/api/v1/get/domain/all
```

Anfragen werden unter `System > Information > Protokolle > API` protokolliert.

Eine Anfrage mit gültigem Key startet eine Sitzung. Clients, die das Sitzungs-Cookie behalten, können weitere Anfragen ohne Key schicken. Wird ein Key gelöscht, deaktiviert oder regeneriert oder sein Zugang geändert, enden alle Sitzungen, die mit ihm gestartet wurden. Clients müssen dann den aktuellen Key erneut mitschicken.
