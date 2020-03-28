Here is just an unsorted list of useful `doveadm` commands that could be useful.

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

## doveadm quota

The `quota get` and `quota recalc`[^1] commands are used to display or recalculate the current user's quota usage. The reported values are in *kilobytes*.

To list the current quota status for a user / mailbox, do:

```
doveadm quota get -u 'mailbox@example.org'
```

To list the quota storage value for **all** users, do:

```
doveadm quota get -A |grep "STORAGE"
```

Recalculate a single user's quota usage:

```
doveadm quota recalc -u 'mailbox@example.org'
```

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

## doveadm search

The `doveadm search`[^2] command is used to find messages matching your query. It can return the username, mailbox-GUID / -UID and message-GUIDs / -UIDs.

To view the number of messages, by user, in their **.Trash** folder:

```
doveadm search -A mailbox 'Trash' | awk '{print $1}' | sort | uniq -c
```

Show all messages in a user's **inbox** older then 90 days:

```
doveadm search -u 'mailbox@example.org' mailbox 'INBOX' savedbefore 90d
```

Show **all messages** in **any folder** that are **older** then 30 days for `mailbox@example.org`:

```
doveadm search -u 'mailbox@example.org' mailbox "*" savedbefore 30d
```

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

## Extract and decrypt an encrypted email+attachment

Mails are compressed, so in order to **extract a specific email** and or an attachment you will need to **decompress them or use doveadm**:

1- ```docker-compose exec dovecot-mailcow doveadm search -u 'me@domain.tld' HEADER Message-ID 'MSG-ID'```

In order to get the **MSG-ID**, goto Rspamd UI > History > Copy the desired '**ID**' of your email

Output example:
asdasdasdasd000033a69f92 1123

Then Fetch the message by:

2- ```docker-compose exec dovecot-mailcow doveadm fetch -u 'me@domain.tld' text mailbox-guid asdasdasdasd000033a69f92 uid 1123```

or save it to a file by appending ``` > file ``` to the end of it.

Exmaple:

```docker-compose exec dovecot-mailcow doveadm fetch -u 'me@domain.tld' text mailbox-guid asdasdasdasd000033a69f92 uid 1123 > /desired_path/to/desired_file```

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

[^1]:https://wiki.dovecot.org/Tools/Doveadm/Quota
[^2]:https://wiki.dovecot.org/Tools/Doveadm/Search
