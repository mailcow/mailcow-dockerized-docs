Rspamd wird für die AV-Verarbeitung, DKIM-Signierung und SPAM-Verarbeitung verwendet. Es ist ein leistungsfähiges und schnelles Filtersystem. Für eine ausführlichere Dokumentation über Rspamd besuchen Sie bitte die [Rspamd Dokumentation] (https://rspamd.com/doc/index.html).

## Spam & Ham lernen

Rspamd lernt, ob es sich um Spam oder Ham handelt, wenn Sie eine Nachricht in oder aus dem Junk-Ordner in ein anderes Postfach als den Papierkorb verschieben.
Dies wird durch die Verwendung des Sieve-Plugins "sieve_imapsieve" und Parser-Skripte erreicht.

Rspamd liest auch automatisch Mails, wenn eine hohe oder niedrige Punktzahl erkannt wird (siehe https://rspamd.com/doc/configuration/statistic.html#autolearning). Wir haben das Plugin so konfiguriert, dass es ein vernünftiges Verhältnis zwischen Spam- und Ham-Learnings beibehält.

Die Bayes-Statistiken werden in Redis als Schlüssel `BAYES_HAM` und `BAYES_SPAM` gespeichert.

Neben Bayes wird ein lokaler Fuzzy-Speicher verwendet, um wiederkehrende Muster in Texten oder Bildern zu lernen, die auf Ham oder Spam hinweisen.

Sie können auch die Web-UI von Rspamd verwenden, um Ham und/oder Spam zu lernen oder bestimmte Einstellungen von Rspamd anzupassen.

### Spam oder Ham aus bestehendem Verzeichnis lernen

Sie können einen Einzeiler verwenden, um Mails im Klartextformat (unkomprimiert) zu lernen:

```bash
# Ham
for file in /my/folder/cur/*; do docker exec -i $(docker compose ps -q rspamd-mailcow) rspamc learn_ham < $file; done
# Spam
for file in /my/folder/.Junk/cur/*; do docker exec -i $(docker compose ps -q rspamd-mailcow) rspamc learn_spam < $file; done
```

Erwägen Sie, einen lokalen Ordner als neues Volume an `rspamd-mailcow` in `docker compose.yml` anzuhängen und die gegebenen Dateien innerhalb des Containers zu lernen. Dies kann als Workaround verwendet werden, um komprimierte Daten mit zcat zu parsen. Beispiel:

``bash
for file in /data/old_mail/.Junk/cur/*; do rspamc learn_spam < zcat $file; done
```

### Gelernte Daten zurücksetzen (Bayes, Neural)

Sie müssen die Schlüssel in Redis löschen, um die gelernten Daten zurückzusetzen, also erstellen Sie jetzt eine Kopie Ihrer Redis-Datenbank:

**Backup Datenbank**

```bash
# Es ist besser, Redis zu stoppen, bevor Sie die Datei kopieren.
cp /var/lib/docker/volumes/mailcowdockerized_redis-vol-1/_data/dump.rdb /root/
```

**Bayes-Daten zurücksetzen**

```bash
docker compose exec redis-mailcow sh -c 'redis-cli --scan --pattern BAYES_* | xargs redis-cli del'
docker compose exec redis-mailcow sh -c 'redis-cli --scan --pattern RS* | xargs redis-cli del'
```

**Neurale Daten zurücksetzen**

```bash
docker compose exec redis-mailcow sh -c 'redis-cli --scan --pattern rn_* | xargs redis-cli del'
```

**Fuzzy-Daten zurücksetzen**

```bash
# Wir müssen zuerst das redis-cli eingeben:
docker compose exec redis-mailcow redis-cli
# In redis-cli:
127.0.0.1:6379> EVAL "for i, name in ipairs(redis.call('KEYS', ARGV[1])) do redis.call('DEL', name); end" 0 fuzzy*
```

**Info**

Wenn redis-cli sich beschwert über...

```Text
(error) ERR wrong number of arguments for 'del' command
```

...das Schlüsselmuster nicht gefunden wurde und somit keine Daten zum Löschen vorhanden sind - ist es in Ordnung.

## CLI-Werkzeuge

``bash
docker compose exec rspamd-mailcow rspamc --help
docker compose exec rspamd-mailcow rspamadm --help
```

## Greylisting deaktivieren

Nur Nachrichten mit einer höheren Punktzahl werden als Greylisting betrachtet (soft rejected). Es ist schlechte Praxis, Greylisting zu deaktivieren.

Sie können Greylisting serverweit durch Editieren deaktivieren:

`{mailcow-dir}/data/conf/rspamd/local.d/greylist.conf`

Fügen Sie die Zeile hinzu:

```cpp
enabled = false;
```

Speichern Sie die Datei und starten Sie "rspamd-mailcow" neu: `docker compose restart rspamd-mailcow`

## Spamfilter-Schwellenwerte (global)

Jeder Benutzer kann [seine Spam-Bewertung](../mailcow-UI/u_e-mailcow_ui-spamfilter.md) individuell ändern. Um eine neue **serverweite** Grenze zu definieren, editieren Sie `data/conf/rspamd/local.d/actions.conf`:

```cpp
reject = 15;
add_header = 8;
greylist = 7;
```

Speichern Sie die Datei und starten Sie "rspamd-mailcow" neu: `docker compose restart rspamd-mailcow`

Bestehende Einstellungen der Benutzer werden nicht überschrieben!

Um benutzerdefinierte Schwellenwerte zurückzusetzen, führen Sie aus:

```
source mailcow.conf
docker compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel';"
# oder:
# docker compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel' and object = 'only-this-mailbox@example.org';"
```

## Benutzerdefinierte Ablehnungsnachrichten

Die Standard-Spam-Reject-Meldung kann durch Hinzufügen einer neuen Datei `data/conf/rspamd/override.d/worker-proxy.custom.inc` mit dem folgenden Inhalt geändert werden:

```
reject_message = "Meine eigene Ablehnungsnachricht";
```

Speichern Sie die Datei und starten Sie Rspamd neu: `docker compose restart rspamd-mailcow`.

Waehrend das oben genannte fuer abgelehnte Mails mit einem hohen Spam-Score funktioniert, ignorieren Prefilter-Aktionen diese Einstellung. Für diese Karten muss das Multimap-Modul in Rspamd angepasst werden:

1. Finden Sie das Prefilet-Reject-Symbol, für das Sie die Nachricht ändern wollen, führen Sie dazu aus: `grep -R "SYMBOL_YOU_WANT_TO_ADJUST" /opt/mailcow-dockerized/data/conf/rspamd/`

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

3. Speichern Sie die Datei und starten Sie Rspamd neu: `docker compose restart rspamd-mailcow`.

## Verwerfen statt zurückweisen

Wenn Sie eine Nachricht stillschweigend verwerfen wollen, erstellen oder bearbeiten Sie die Datei `data/conf/rspamd/override.d/worker-proxy.custom.inc` und fügen Sie den folgenden Inhalt hinzu:

```
discard_on_reject = true;
```

Starten Sie Rspamd neu:

```bash
docker compose restart rspamd-mailcow
```

## Lösche alle Ratelimit-Schlüssel

Wenn Sie das UI nicht verwenden wollen und stattdessen alle Schlüssel in der Redis-Datenbank löschen wollen, können Sie redis-cli für diese Aufgabe verwenden:

```
docker compose exec redis-mailcow sh
# Unlink (verfügbar in Redis >=4.) löscht im Hintergrund
redis-cli --scan --pattern RL* | xargs redis-cli unlink
```

Starten Sie Rspamd neu:

```bash
docker compose exec redis-mailcow sh
```

## Erneutes Senden von Quarantäne-Benachrichtigungen auslösen

Sollte nur zur Fehlersuche verwendet werden!

```
docker compose exec dovecot-mailcow bash
mysql -umailcow -p$DBPASS mailcow -e "update quarantine set notified = 0;"
redis-cli -h redis DEL Q_LAST_NOTIFIED
quarantine_notify.py
```

## Speicherung der Historie erhöhen

Standardmäßig speichert Rspamd 1000 Elemente in der Historie.

Die Historie wird komprimiert gespeichert.

Es wird empfohlen, hier keinen unverhältnismäßig hohen Wert zu verwenden, probieren Sie etwas in der Größenordnung von 5000 oder 10000 und sehen Sie, wie Ihr Server damit umgeht:

Bearbeiten Sie `data/conf/rspamd/local.d/history_redis.conf`:

```
nrows = 1000; # Ändern Sie diesen Wert
```

Starten Sie anschließend Rspamd neu: `docker compose restart rspamd-mailcow`



