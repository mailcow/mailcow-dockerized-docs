## Whitelist specific ClamAV signatures

You may find that legitimate (clean) mail is being blocked by ClamAV (Rspamd will flag the mail with `VIRUS_FOUND`). For instance, interactive PDF form attachments are blocked by default because the embedded Javascript code may be used for nefarious purposes. Confirm by looking at the clamd logs, e.g.:

```bash
docker-compose logs clamd-mailcow | grep "FOUND"
```

This line confirms that such was identified:

```text
clamd-mailcow_1      | Sat Sep 28 07:43:24 2019 -> instream(local): PUA.Pdf.Trojan.EmbeddedJavaScript-1(e887d2ac324ce90750768b86b63d0749:363325) FOUND
```

To whitelist this particular signature (and enable sending this type of file attached), add it to the ClamAV signature whitelist file:

```bash
echo 'PUA.Pdf.Trojan.EmbeddedJavaScript-1' >> data/conf/clamav/whitelist.ign2
```

Then restart the clamd-mailcow service container in the mailcow UI or using docker-compose:

```bash
docker-compose restart clamd-mailcow
```

Cleanup cached ClamAV results in Redis:

```
# docker-compose exec redis-mailcow  /bin/sh
/data # redis-cli KEYS rs_cl* | xargs redis-cli DEL
/data # exit
```
