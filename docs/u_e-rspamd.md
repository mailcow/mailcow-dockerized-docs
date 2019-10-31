Rspamd is used for AV handling, DKIM signing and SPAM handling. It's a powerful and fast filter system. For a more in-depth documentation on Rspamd please visit its [own documentation](https://rspamd.com/doc/index.html).

## Learn Spam & Ham

Rspamd learns mail as spam or ham when you move a message in or out of the junk folder to any mailbox besides trash.
This is achieved by using the Dovecot plugin "antispam" and a simple parser script.

Rspamd also auto-learns mail when a high or low score is detected (see https://rspamd.com/doc/configuration/statistic.html#autolearning)

The bayes statistics are written to Redis as keys `BAYES_HAM` and `BAYES_SPAM`.

You can also use Rspamd's web UI to learn ham and / or spam or to adjust certain settings of Rspamd.

### Learn Spam or Ham from existing directory

You can use a one-liner to learn mail in plain-text (uncompressed) format:
```
# Ham
for file in /my/folder/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_ham < $file; done
# Spam
for file in /my/folder/.Junk/cur/*; do docker exec -i $(docker-compose ps -q rspamd-mailcow) rspamc learn_spam < $file; done
```

Consider attaching a local folder as new volume to `rspamd-mailcow` in `docker-compose.yml` and learn given files inside the container. This can be used as workaround to parse compressed data with zcat. Example:

```
for file in /data/old_mail/.Junk/cur/*; do rspamc learn_spam < zcat $file; done
```

### Reset learned data

You need to delete keys in Redis to reset learned mail, so create a copy of your Redis database now:

**Backup database**
```
# It is better to stop Redis before you copy the file.
cp /var/lib/docker/volumes/mailcowdockerized_redis-vol-1/_data/dump.rdb /root/
```

**Reset Bayes data**
```
docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern BAYES_* | xargs redis-cli del'
docker-compose exec redis-mailcow sh -c 'redis-cli --scan --pattern RS* | xargs redis-cli del'
```

If it complains about...
```
(error) ERR wrong number of arguments for 'del' command
```
...the key pattern was not found and thus no data is available to delete.


## CLI tools

```
docker-compose exec rspamd-mailcow rspamc --help
docker-compose exec rspamd-mailcow rspamadm --help
```

## Disable Greylisting

You can disable rspamd's greylisting server-wide by editing:

`{mailcow-dir}/data/conf/rspamd/local.d/greylist.conf`

Simply add the line:

`enabled = false;`

Save the file and then restart the rspamd container.

See [Rspamd documentation](https://rspamd.com/doc/index.html)

## Global SMTP From Blacklist

Mailcow has integration with Rspamd at Configuration & Details > Global filter maps.

You can blacklist emails based from whod domain they was received.`global_smtp_from_blacklist.map` use regex syntax and applied as pre-filter for reject spam immediately without putting it to quarantine.

Such a blacklist can be very handy, but can lead to the fact that useful mail does not reach the recipients. To follow best practices by [RFC822 6.3 Reserved Address](https://tools.ietf.org/html/rfc822#section-6.3)

1. create alias from postmaster@your.domain to your tehnical support email.

2.1. allow postmaster to receive emails without spam filtering.

2.2. Go to Configuration &#38; Details > Configuration > Rspamd settings map > Add rule.

2.3. Choose: `Insert example preset "Postmasters want spam"`, and click Add button.

3.1. By default blacklisted domains will receive error: `ERROR_CODE :554, ERROR_CODE :5.7.1 Matched map: GLOBAL_SMTP_FROM_BL`. This error not much information so better change it.

3.2. Open `{mailcow-dir}/data/conf/rspamd/local.d/multimap.conf` and find `GLOBAL_SMTP_FROM_BL` section.

3.3. Add to this section `message = "Your domain is blacklisted, contact postmaster@your.domain to resolve this case.";` or something similar.

4. Save the file and then restart the rspamd container.

## Whitelist specific ClamAV signatures

You may find that legitimate (clean) mail is being blocked by ClamAV (Rspamd will flag the mail with `VIRUS_FOUND`). For instance, interactive PDF form attachments are blocked by default because the embedded Javascript code may be used for nefarious purposes. Confirm by looking at the clamd logs, e.g.:

`docker-compose logs clamd-mailcow | grep FOUND`

This line confirms that such was identified:

`clamd-mailcow_1      | Sat Sep 28 07:43:24 2019 -> instream(local): PUA.Pdf.Trojan.EmbeddedJavaScript-1(e887d2ac324ce90750768b86b63d0749:363325) FOUND`

To whitelist this particular signature (and enable sending this type of file attached), add it to the ClamAV signature whitelist file:

`echo 'PUA.Pdf.Trojan.EmbeddedJavaScript-1' >> data/conf/clamav/whitelist.ign2`

Then restart the clamd-mailcow service container in the mailcow UI, or using docker-compose:

`docker-compose restart clamd-mailcow`

