Rspamd is used for AV handling, DKIM signing and SPAM handling. It's a powerful and fast filter system. For a more in-depth documentation on Rspamd please visit its [own documentation](https://rspamd.com/doc/index.html).

## Learn Spam & Ham

Rspamd learns mail as spam or ham when you move a message in or out of the junk folder to any mailbox besides trash.
This is achieved by using the Dovecot plugin "antispam" and a simple parser script.

Rspamd also auto-learns mail when a high or low score is detected (see https://rspamd.com/doc/configuration/statistic.html#autolearning)

The bayes statistics are written to Redis as keys `BAYES_HAM` and `BAYES_SPAM`.

You can also use Rspamd's web UI to learn ham and / or spam or to adjust certain settings of Rspamd.

### Learn Spam or Ham from existing directory

You can use a one-liner to learn mail in plain-text (uncompressed) format:

```bash
# Ham
for file in /my/folder/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_ham < $file; done
# Spam
for file in /my/folder/.Junk/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_spam < $file; done
```

Consider attaching a local folder as new volume to `rspamd-mailcow` in `docker-compose.yml` and learn given files inside the container. This can be used as workaround to parse compressed data with zcat. Example:

```bash
for file in /data/old_mail/.Junk/cur/*; do rspamc learn_spam < zcat $file; done
```

### Reset learned data (Bayes, Neural)

You need to delete keys in Redis to reset learned data, so create a copy of your Redis database now:

**Backup database**

```bash
# It is better to stop Redis before you copy the file.
cp /var/lib/docker/volumes/mailcowdockerized_redis-vol-1/_data/dump.rdb /root/
```

**Reset Bayes data**

```bash
docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern BAYES_* | xargs redis-cli del'
docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern RS* | xargs redis-cli del'
```

**Reset Neural data**

```bash
docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern rn_* | xargs redis-cli del'
```

**Reset Fuzzy data**

```bash
# We need to enter the redis-cli first:
docker-compose exec redis-mailcow redis-cli
# In redis-cli:
127.0.0.1:6379> EVAL "for i, name in ipairs(redis.call('KEYS', ARGV[1])) do redis.call('DEL', name); end" 0 fuzzy*
```

**Info**

If redis-cli complains about...

```text
(error) ERR wrong number of arguments for 'del' command
```

...the key pattern was not found and thus no data is available to delete - it is fine.


## CLI tools

```bash
docker-compose exec rspamd-mailcow rspamc --help
docker-compose exec rspamd-mailcow rspamadm --help
```

## Disable Greylisting

You can disable rspamd's greylisting server-wide by editing:

`{mailcow-dir}/data/conf/rspamd/local.d/greylist.conf`

Simply add the line:

```cpp
enabled = false;
```

Save the file and then restart the rspamd container.

See [Rspamd documentation](https://rspamd.com/doc/index.html)

## Custom reject messages

The default spam reject message can be changed by adding a new file `data/conf/rspamd/override.d/worker-proxy.custom.inc` with the following content:

```
reject_message = "My custom reject message";
```

Save the file and restart Rspamd: `docker-compose restart rspamd-mailcow`.

While the above works for rejected mails with a high spam score, global maps (as found in "Global filter maps" in /admin) will ignore this setting. For these maps, the multimap module in Rspamd needs to be adjusted:

1. Open `{mailcow-dir}/data/conf/rspamd/local.d/multimap.conf` and find the desired map symbol (e.g. `GLOBAL_SMTP_FROM_BL`).

2. Add your custom message as new line:

```
GLOBAL_SMTP_FROM_BL {
  type = "from";
  message = "Your domain is blacklisted, contact postmaster@your.domain to resolve this case.";`
  map = "$LOCAL_CONFDIR/custom/global_smtp_from_blacklist.map";
  regexp = true;
  prefilter = true;
  action = "reject";
}
```

3. Save the file and restart Rspamd: `docker-compose restart rspamd-mailcow`.

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

Then restart the clamd-mailcow service container in the mailcow UI, or using docker-compose:

```bash
docker-compose restart clamd-mailcow
```

