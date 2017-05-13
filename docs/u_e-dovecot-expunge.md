If you want to delete old mails out of the `.Junk` or `.Trash` folders or maybe delete all read mails that are older than a certain amount of time you may use dovecot's tool doveadm [man doveadm-expunge](https://wiki.dovecot.org/Tools/Doveadm/Expunge).

## The manual way

That said, let's dive in:

Delete a user's mails inside the junk folder that **are read** and **older** than 4 hours

```
docker-compose exec dovecot-mailcow doveadm expunge -u 'mailbox@example.com' mailbox 'Junk' SEEN not SINCE 4h
```

Delete **all** user's mails in the junk folder that are **older** than 7 days

```
docker-compose exec dovecot-mailcow doveadm expunge -A mailbox 'Junk' savedbefore 7d
```

Delete mails inside a custom folder **inside** a user's inbox that are **not** flagged and **older** than 2 weeks

```
docker-compose exec dovecot-mailcow doveadm expunge -u 'mailbox@example.com' mailbox 'INBOX/custom-folder' not FLAGGED not SINCE 2w
```

!!! info
    For possible [time spans](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_date_specification) or [search keys](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_search_keys) have a look at [man doveadm-search-query](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery)

## Make it automatic

If you want to automate such a task you can create a cron job on your host that calls a script like the one below:

```
#!/bin/bash
/usr/local/bin/docker-compose exec -T doveadm dovecot-mailcow doveadm expunge -A mailbox 'Junk' savedbefore 2w
/usr/local/bin/docker-compose exec -T doveadm expunge -A mailbox 'Junk' SEEN not SINCE 12h
[...]
```

To create a cron job you may execute `crontab -e` and insert something like the following to execute a script:

```
# Execute everyday at 04:00 A.M.
0 4 * * * /path/to/your/expunge_mailboxes.sh
```
