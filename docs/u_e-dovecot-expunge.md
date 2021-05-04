If you want to delete old emails out of the `.Junk` or `.Trash` folders or perhaps delete all read emails that are older than a specific date or time, you may use dovecot's tool doveadm [man doveadm-expunge](https://wiki.dovecot.org/Tools/Doveadm/Expunge).

!! Never move Maildir files directly. Always use doveadm, as otherwise, it will appear to end-users that they have lost mail.

## The manual way

That said, let's dive in:

Delete a user's emails inside the junk folder that are **marked as read** and **older** than four hours

```
docker-compose exec dovecot-mailcow doveadm expunge -u 'mailbox@example.com' mailbox 'Junk' SEEN not SINCE 4h
```

Delete **all** user's emails in the junk folder that are **older** than seven days.

```
docker-compose exec dovecot-mailcow doveadm expunge -A mailbox 'Junk' savedbefore 7d
```

Delete **all** emails (of all users) in **all** folders that are **older** than 52 weeks (internal date of the mail, not the date it was received by the system => `before` instead of `savedbefore`). Helpful for deleting very old emails from all users and folders (thus beneficial for GDPR-compliance).

```
docker-compose exec dovecot-mailcow doveadm expunge -A mailbox % before 52w
```

Delete emails inside a custom folder **inside** a user's inbox that is **not** flagged and **older** than two weeks.

```
docker-compose exec dovecot-mailcow doveadm expunge -u 'mailbox@example.com' mailbox 'INBOX/custom-folder' not FLAGGED not SINCE 2w
```

! For possible [time spans](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_date_specification) or [search keys](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_search_keys) have a look at [man doveadm-search-query](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery)

## Job scheduler

### via the host system cron

If you want to automate such a task, you can create a cron job on your host that calls a script like the one below:

```
#!/bin/bash
# Path to mailcow-dockerized, e.g. /opt/mailcow-dockerized
cd /path/to/your/mailcow-dockerized

/usr/local/bin/docker-compose exec -T dovecot-mailcow doveadm expunge -A mailbox 'Junk' savedbefore 2w
/usr/local/bin/docker-compose exec -T dovecot-mailcow doveadm expunge -A mailbox 'Junk' SEEN not SINCE 12h
[...]
```

To create a cron job, you may execute `crontab -e` and insert something like the following to run a script:

```
# Execute everyday at 04:00 A.M.
0 4 * * * /path/to/your/expunge_mailboxes.sh
```
! If you struggle with that schedule string, you can use [crontab guru](https://crontab.guru/). 

## Job scheduler

This docker-compose.override.yml deletes all emails older than two weeks from the "Junk" folder every day at 4 am. 

```
version: '2.1'
services:
 dovecot-mailcow:
    labels:
      - "ofelia.enabled=true"
      - "ofelia.job-exec.dovecot-expunge-trash.schedule=0 4 * * *"
      - "ofelia.job-exec.dovecot-expunge-trash.command=doveadm expunge -A mailbox 'Junk' savedbefore 2w"
      - "ofelia.job-exec.dovecot-expunge-trash.tty=false"

```

##Logging/Troubleshooting
To see if things ran proper, you can not only see in your mailbox but also check ofelia-mailcow docker log if it looks something like this:

```
common.go:124 ▶ NOTICE [Job "dovecot-expunge-trash" (8759567efa66)] Started - doveadm expunge -A mailbox 'Junk' savedbefore 2w,
common.go:124 ▶ NOTICE [Job "dovecot-expunge-trash" (8759567efa66)] Finished in "285.032291ms", failed: false, skipped: false, error: none,
```

If the job failed, it will be indicated in the logging and will give you the output of the doveadm in the log to make it easier for you to debug.

If you want to add more jobs, ensure you change the "dovecot-expunge-trash" part after "ofelia.job-exec." to something else; it defines the name of the job. Syntax of the labels you find at [mcuadros/ofelia](https://github.com/mcuadros/ofelia).
