To use pflogsumm with the default logging driver, we need to query postfix-mailcow via docker logs and pipe the output to pflogsumm:

```
docker logs --since 24h $(docker ps -qf name=postfix-mailcow) | pflogsumm
```

The above log output is limited to the past 24 hours.

It's also possible to create a daily pflogsumm report via cron. Create the file /etc/cron.d/pflogsumm with the following content:

```
SHELL=/bin/bash
59 23 * * * root docker logs --since 24h $(docker ps -qf name=postfix-mailcow) | /usr/sbin/pflogsumm -d today | mail -s "Postfix Report of $(date)" postmaster@example.net
```

Based on the last 24h postfix logs, this example sends every day at 23:59:00 a pflogsumm report to postmaster@example.net.
