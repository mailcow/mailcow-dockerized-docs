Rspamd is used for AV handling, DKIM signing and SPAM handling. It's a powerful and fast filter system. For a more in-depth documentation on Rspamd please visit its [own documentation](https://rspamd.com/doc/index.html).

## Learn Spam & Ham

Rspamd learns mail as spam or ham when you move a message in or out of the junk folder to any mailbox besides trash.
This is achieved by using the Sieve plugin "sieve_imapsieve" and parser scripts.

Rspamd also auto-learns mail when a high or low score is detected (see https://rspamd.com/doc/configuration/statistic.html#autolearning). We configured the plugin to keep a sane ratio between spam and ham learns.

The bayes statistics are written to Redis as keys `BAYES_HAM` and `BAYES_SPAM`.

Besides bayes, a local fuzzy storage is used to learn recurring patterns in text or images that indicate ham or spam.

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

Only messages with a higher score will be considered to be greylisted (soft rejected). It is bad practice to disable greylisting.

You can disable greylisting server-wide by editing:

`{mailcow-dir}/data/conf/rspamd/local.d/greylist.conf`

Add the line:

```cpp
enabled = false;
```

Save the file and restart "rspamd-mailcow": `docker-compose restart rspamd-mailcow`

## Spam filter thresholds (global)

Each user is able to change [their spam rating individually](https://mailcow.github.io/mailcow-dockerized-docs/u_e-mailcow_ui-spamfilter/). To define a new **server-wide** limit, edit `data/conf/rspamd/local.d/actions.conf`:

```cpp
reject = 15;
add_header = 8;
greylist = 7;
```

Save the file and restart "rspamd-mailcow": `docker-compose restart rspamd-mailcow`

Existing settings of users will not be overwritten!

To reset custom defined thresholds, run:

```
source mailcow.conf
docker-compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel';"
# or:
# docker-compose exec mysql-mailcow mysql -umailcow -p$DBPASS mailcow -e "delete from filterconf where option = 'highspamlevel' or option = 'lowspamlevel' and object = 'only-this-mailbox@example.org';"
```

## Custom reject messages

The default spam reject message can be changed by adding a new file `data/conf/rspamd/override.d/worker-proxy.custom.inc` with the following content:

```
reject_message = "My custom reject message";
```

Save the file and restart Rspamd: `docker-compose restart rspamd-mailcow`.

While the above works for rejected mails with a high spam score, prefilter reject actions will ignore this setting. For these maps, the multimap module in Rspamd needs to be adjusted:

1. Find prefilet reject symbol for which you want change message, to do it run: `grep -R "SYMBOL_YOU_WANT_TO_ADJUST" /opt/mailcow-dockerized/data/conf/rspamd/`

2. Add your custom message as new line:

```
GLOBAL_RCPT_BL {
  type = "rcpt";
  map = "${LOCAL_CONFDIR}/custom/global_rcpt_blacklist.map";
  regexp = true;
  prefilter = true;
  action = "reject";
  message = "Sending mail to this recipient is prohibited by postmaster@your.domain";
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

## Discard instead of reject

If you want to silently drop a message, create or edit the file `data/conf/rspamd/override.d/worker-proxy.custom.inc` and add the following content:

```
discard_on_reject = true;
```

Restart Rspamd:

```bash
docker-compose restart rspamd-mailcow
```

## Wipe all ratelimit keys

If you don't want to use the UI and instead wipe all keys in the Redis database, you can use redis-cli for that task:

```
docker-compose exec redis-mailcow sh
# Unlink (available in Redis >=4.) will delete in the backgronud
redis-cli --scan --pattern RL* | xargs redis-cli unlink
```

Restart Rspamd:

```bash
docker-compose exec redis-mailcow sh
```

## Trigger a resend of quarantine notifications

Should be used for debugging only!

```
docker-compose exec dovecot-mailcow bash
mysql -umailcow -p$DBPASS mailcow -e "update quarantine set notified = 0;"
redis-cli -h redis DEL Q_LAST_NOTIFIED
quarantine_notify.py
```

