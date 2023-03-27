To use pflogsumm with the default logging driver, we need to query postfix-mailcow via docker logs and direct the output to pflogsumm:

```
docker logs --since 24h $(docker ps -qf name=postfix-mailcow) | pflogsumm
```

The above log output is limited to the last 24 hours.

It is also possible to create a daily pflogsumm report via cron. Create the /etc/cron.d/pflogsumm file with the following content:

```
SHELL=/bin/bash
59 23 * * * root docker logs --since 24h $(docker ps -qf name=postfix-mailcow) | /usr/sbin/pflogsumm -d today | mail -s "Postfix Report of $(date)" postmaster@example.net
```

To work, a local postfix must be installed on the server, which relays to the mailcow postfix.

!!! question
    More detailed information can be found in section [Post installation tasks -> Local MTA on Dockerhost](../../post_installation/firststeps-local_mta.en.md).

Based on the postfix logs of the last 24 hours, this example then sends a pflogsumm report to postmaster@example.net every day at 23:59:00.
