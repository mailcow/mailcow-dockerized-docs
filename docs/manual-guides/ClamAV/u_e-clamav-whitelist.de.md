## Whitelist für bestimmte ClamAV-Signaturen

Es kann vorkommen, dass legitime (saubere) Mails von ClamAV blockiert werden (Rspamd markiert die Mail mit `VIRUS_FOUND`). So werden beispielsweise interaktive PDF-Formularanhänge standardmäßig blockiert, da der eingebettete Javascript-Code für schädliche Zwecke verwendet werden könnte. Überprüfen Sie dies anhand der clamd-Protokolle, z.B.:

```bash
docker-compose logs clamd-mailcow | grep "FOUND"
```

Diese Zeile bestätigt, dass ein solcher identifiziert wurde:

```text
clamd-mailcow_1 | Sat Sep 28 07:43:24 2019 -> instream(local): PUA.Pdf.Trojan.EmbeddedJavaScript-1(e887d2ac324ce90750768b86b63d0749:363325) FOUND
```

Um diese spezielle Signatur auf die Whitelist zu setzen (und den Versand dieses Dateityps im Anhang zu ermöglichen), fügen Sie sie der ClamAV-Signatur-Whitelist-Datei hinzu:

```bash
echo 'PUA.Pdf.Trojan.EmbeddedJavaScript-1' >> data/conf/clamav/whitelist.ign2
```

Dann starten Sie den clamd-mailcow Service Container in der mailcow UI oder mit docker-compose neu:

```bash
docker-compose restart clamd-mailcow
```

Bereinigen Sie zwischengespeicherte ClamAV-Ergebnisse in Redis:

```
# docker-compose exec redis-mailcow /bin/sh
/data # redis-cli KEYS rs_cl* | xargs redis-cli DEL
/data # exit
```
