## Weitere Datenbanken für ClamAV

Die Standard ClamAV Datenbanken haben keine hohe Trefferquote, können aber durch kostenlose und kostenpflichtige Datenbanken erweitert werden.

### Liste von bekannten (kostenfreien) Datenbanken | Stand April 2022

- [SecurityInfo](https://www.securiteinfo.com/) - kostenlose ClamAV DBs für Testzwecke. Registrierung der IP Adresse des Servers erforderlich (dann nutzbar für besagte IP).
- [InterServer](http://rbluri.interserver.net/) - kostenlose ClamAV DBs. Für E-Mail Zwecke eher ungeeignet.

### SecuriteInfo Datenbank aktivieren

1. Kostenfreien Account auf https://www.securiteinfo.com/clients/customers/signup erstellen.
2. Sie erhalten eine E-Mail um Ihren Account zu aktivieren gefolgt von einer E-Mail mit Ihrem Login Namen.
3. Loggen Sie sich ein und navigieren Sie zu ihrem Account https://www.securiteinfo.com/clients/customers/account
4. Klicken Sie auf den 'Setup' Reiter.
5. Sie brauchen `your_id` von den Downloadlinks. **Diese sind pro User individuell**.
7. Fügen Sie diese wie folgt in die `data/conf/clamav/freshclam.conf` ein und ersetzen Sie den `your_id` Teil mit Ihrer ID:
```
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfo.ign2
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/javascript.ndb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/spam_marketing.ndb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfohtml.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfoascii.hdb
DatabaseCustomURL https://www.securiteinfo.com/get/signatures/your_id/securiteinfopdf.hdb
```

8. Passen Sie `data/conf/clamav/clamd.conf` mit den folgenden Einstellungen an:
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
9. Starten Sie den ClamAV Container neu:
```bash
docker-compose restart clamd-mailcow
```

**Bitte beachten Sie**:

- Sie können `ExcludePUA` und `IncludePUA` in der `clamd.conf` nicht gleichzeitig nutzen! Kommentieren Sie bitte `IncludePUA` aus, sollte es nicht auskommentiert sein. 
- Die Liste der Datenbanken genutzt in diesem Beispiel sollten für die meisten Fälle passen. SecuriteInfo bietet jedoch noch andere Datenbanken an. Bitte schauen Sie sich das SecuriteInfo FAQ für weitere Informationen an.
- Mit den neu eingestellten Datenbanken (und den Standard Datenbanken) ClamAV verbraucht ClamAV etwa 1,3 GB RAM des Servers.
- Sollten Sie `message_size_limit` in Postfix verändert haben müssen Sie die `MaxSize` Einstellung in ClamAV auf den selben Wert eintragen.

### InterServer Datenbanken aktivieren

1. Fügen Sie folgendes in `data/conf/clamav/freshclam.conf` ein:
```
DatabaseCustomURL http://sigs.interserver.net/interserver256.hdb
DatabaseCustomURL http://sigs.interserver.net/interservertopline.db
DatabaseCustomURL http://sigs.interserver.net/shell.ldb
DatabaseCustomURL http://sigs.interserver.net/whitelist.fp
```
2. Starten Sie den ClamAV Container neu:
```bash
docker-compose restart clamd-mailcow
```
