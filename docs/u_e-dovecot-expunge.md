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

Delete **all** mails (of all users) in **all** folders that are **older** than 52 weeks (internal date of the mail, not the date it was saved on the system => `before` instead of `savedbefore`). Useful for deleting very old mails on all users and folders (thus especially useful for GDPR-compliance).

```
docker-compose exec dovecot-mailcow doveadm expunge -A mailbox % before 52w
```

Delete mails inside a custom folder **inside** a user's inbox that are **not** flagged and **older** than 2 weeks

```
docker-compose exec dovecot-mailcow doveadm expunge -u 'mailbox@example.com' mailbox 'INBOX/custom-folder' not FLAGGED not SINCE 2w
```

!!! info
    For possible [time spans](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_date_specification) or [search keys](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery#section_search_keys) have a look at [man doveadm-search-query](https://wiki.dovecot.org/Tools/Doveadm/SearchQuery)

## Job scheduler

### via the host system cron

If you want to automate such a task you can create a cron job on your host that calls a script like the one below:

```
#!/bin/bash
# Path to mailcow-dockerized, e.g. /opt/mailcow-dockerized
cd /path/to/your/mailcow-dockerized

/usr/local/bin/docker-compose exec -T dovecot-mailcow doveadm expunge -A mailbox 'Junk' savedbefore 2w
/usr/local/bin/docker-compose exec -T dovecot-mailcow doveadm expunge -A mailbox 'Junk' SEEN not SINCE 12h
[...]
```

To create a cron job you may execute `crontab -e` and insert something like the following to execute a script:

```
# Execute everyday at 04:00 A.M.
0 4 * * * /path/to/your/expunge_mailboxes.sh
```

### via Docker job scheduler

To archive this with a docker job scheduler use this docker-compose.override.yml with your mailcow: 

```
version: '2.1'

services:
  
  ofelia:
    image: mcuadros/ofelia:latest
    restart: always
    command: daemon --docker
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro   
    network_mode: none

  dovecot-mailcow:
    labels:
      - "ofelia.enabled=true"
      - "ofelia.job-exec.dovecot-expunge-trash.schedule=0 4 * * *"
      - "ofelia.job-exec.dovecot-expunge-trash.command=doveadm expunge -A mailbox 'Junk' savedbefore 2w"
      - "ofelia.job-exec.dovecot-expunge-trash.tty=false"

```

The job controller just need access to the docker control socket to be able to emulate the behavior of "exec". Then we add a few label to our dovecot-container to activate the job scheduler and tell him in a cron compatible scheduling format when to run. If you struggle with that schedule string you can use [crontab guru](https://crontab.guru/). 
This docker-compose.override.yml deletes all mails older then 2 weeks from the "Junk" folder every day at 4 am. To see if things ran proper, you can not only see in your mailbox but also check Ofelia's docker log if it looks something like this:

```
common.go:124 ▶ NOTICE [Job "dovecot-expunge-trash" (8759567efa66)] Started - doveadm expunge -A mailbox 'Junk' savedbefore 2w,
common.go:124 ▶ NOTICE [Job "dovecot-expunge-trash" (8759567efa66)] Finished in "285.032291ms", failed: false, skipped: false, error: none,
```

If it failed it will say so and give you the output of the doveadm in the log to make it easy on you to debug.

In case you want to add more jobs, ensure you change the "dovecot-expunge-trash" part after "ofelia.job-exec." to something else, it defines the name of the job. Syntax of the labels you find at [mcuadros/ofelia](https://github.com/mcuadros/ofelia).
