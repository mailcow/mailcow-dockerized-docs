## Weitere Datenbanken für ClamAV

Die Standard ClamAV Datenbanken haben keine hohe Trefferquote, können aber durch kostenlose und kostenpflichtige Datenbanken erweitert werden.

### Liste von bekannten (kostenfreien) Datenbanken | Stand April 2022

- [SecurityInfo](https://www.securiteinfo.com/) - kostenlose ClamAV DBs für Testzwecke. Registrierung der IP Adresse des Servers erforderlich (dann nutzbar für besagte IP).
- [InterServer](http://rbluri.interserver.net/) - kostenlose ClamAV DBs. Für E-Mail Zwecke eher ungeeignet.

### SecuriteInfo Datenbank aktivieren
#### Arbeiten im ClamAV

1. Kostenfreien Account auf https://www.securiteinfo.com/clients/customers/signup erstellen.
2. Sie erhalten eine E-Mail um Ihren Account zu aktivieren gefolgt von einer E-Mail mit Ihrem Login Namen.
3. Loggen Sie sich ein und navigieren Sie zu Ihrem Account https://www.securiteinfo.com/clients/customers/account
4. Klicken Sie auf den 'Setup' Reiter.
5. Sie brauchen `your_id` von den Downloadlinks. **Diese sind pro User individuell**.
7. Fügen Sie diese wie folgt in die `data/conf/clamav/freshclam.conf` ein und ersetzen Sie den `your_id` Teil mit Ihrer ID:
```
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.ign2
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/javascript.ndb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfohtml.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoascii.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoandroid.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoold.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfopdf.hdb
# Kostenpflichtige Datenbanken
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo0hour.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.mdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.yara
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.pdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.wdb
```

!!! danger "Achtung"
    Die SecuriteInfo-Datenbank spam_marketing.ndb weist bekanntermaßen erhebliche falsch-positive Regeln auf. Sie gehen damit Ihr eigenes Risiko ein!

8. Bei den kostenlosen SecuriteInfo Datenbanken ist die Download-Geschwindigkeit auf 300 kB/s begrenzt. Ändern Sie in `data/conf/clamav/freshclam.conf` den Standardwert `ReceiveTimeout 20` auf `ReceiveTimeout 90` (Zeitangabe in Sekunden), da ansonsten einige der Datenbank-Downloads aufgrund ihrer Größe abbrechen können.

9. Passen Sie `data/conf/clamav/clamd.conf` mit den folgenden Einstellungen an:
```
DetectPUA yes
ExcludePUA PUA.Win.Packer
ExcludePUA PUA.Win.Trojan.Packed
ExcludePUA PUA.Win.Trojan.Molebox
ExcludePUA PUA.Win.Packer.Upx
ExcludePUA PUA.Doc.Packed
MaxScanSize 150M
MaxFileSize 100M
MaxRecursion 40
MaxEmbeddedPE 100M
MaxHTMLNormalize 50M
MaxScriptNormalize 50M
MaxZipTypeRcg 50M
```
10. Starten Sie den ClamAV Container neu:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart clamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart clamd-mailcow
    ```

**Bitte beachten Sie**:

- Sie können `ExcludePUA` und `IncludePUA` in der `clamd.conf` nicht gleichzeitig nutzen! Kommentieren Sie bitte `IncludePUA` aus, sollte es nicht auskommentiert sein.
- Die Liste der Datenbanken genutzt in diesem Beispiel sollten für die meisten Fälle passen. SecuriteInfo bietet jedoch noch andere Datenbanken an. Bitte schauen Sie sich das SecuriteInfo FAQ für weitere Informationen an.
- Mit den neu eingestellten Datenbanken (und den Standard Datenbanken) ClamAV verbraucht ClamAV etwa 1,3 GB RAM des Servers.
- Sollten Sie `message_size_limit` in Postfix verändert haben müssen Sie die `MaxSize` Einstellung in ClamAV auf den selben Wert eintragen.

#### Arbeiten im Rspamd

!!! danger "Achtung"
    mailcow mit der Version **`>= 2023-07`** wird benötigt, damit die folgende Anleitung funktioniert, da sie die vordefinierten Scores für SecuriteInfo-Signaturen enthält!

Nun haben Sie zwar die ClamAV-Signaturen hinzugefügt, werden aber feststellen, dass Rspamd diese nicht korrekt verwendet bzw. ALLES gnadenlos als VIRUS abstempelt.

Wir können Rspamd aber mit ein wenig Handarbeit zähmen, so dass er nicht völlig aus dem Ruder läuft.

Dazu gehen wir wie folgt vor:

1. Fügen Sie innerhalb des bestehenden `clamav { ... }` block in `data/conf/rspamd/local.d/antivirus.conf`:

```
patterns {
  # Extra Signatures (Securite) Not shipped with mailcow.
  CLAM_SECI_SPAM = "^SecuriteInfo\.com\.Spam.*";
  CLAM_SECI_JPG = "^SecuriteInfo\.com\.JPG.*";
  CLAM_SECI_PDF = "^SecuriteInfo\.com\.PDF.*";
  CLAM_SECI_HTML = "^SecuriteInfo\.com\.HTML.*";
  CLAM_SECI_JS = "^SecuriteInfo\.com\.JS.*";
}
```

2. Starten Sie den Rspamd neu:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart rspamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart rspamd-mailcow
    ```

Nun wird Rspamd die von uns angegebene Gewichtung für die einzelnen Signaturen anwenden, anstatt alles mit einem Wert von 2000 als VIRUS zu markieren und damit abzulehnen.

!!! info

    Sie können die Gewichtungen jederzeit ändern:

    `data/conf/rspamd/local.d/composites.conf`

    Auch die zu registrierenden Strings des ClamAV können Sie manuell einstellen/anpassen.

    Nutzen Sie dazu einfach das gerade eben vorgegebene Schema in der `antivirus.conf` des Rspamd.


!!! warning "Achtung"
    Bitte beachten Sie, dass die Dateien `antivirus.conf` und `composites.conf` durch ein mailcow-Update überschrieben werden können.


### InterServer Datenbanken aktivieren

1. Fügen Sie folgendes in `data/conf/clamav/freshclam.conf` ein:
```
DatabaseCustomURL http://sigs.interserver.net/interserver256.hdb
DatabaseCustomURL http://sigs.interserver.net/interservertopline.db
DatabaseCustomURL http://sigs.interserver.net/shell.ldb
DatabaseCustomURL http://sigs.interserver.net/whitelist.fp
```
2. Starten Sie den ClamAV Container neu:
=== "docker compose (Plugin)"

    ``` bash
    docker compose restart clamd-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart clamd-mailcow
    ```
