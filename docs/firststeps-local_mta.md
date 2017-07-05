The easiest option would be to disable the listener on port 25/tcp.

**Postfix** users disable the listener by commenting the following line (starting with `smtp` or `25`) in `/etc/postfix/master.cf`:
```
#smtp      inet  n       -       -       -       -       smtpd
```

Furthermore, to relay your local mail over the dockerized mailcow, you may want to add `172.22.1.1` as relayhost:

```
postconf -e 'relayhost = 172.22.1.1'
```

"172.22.1.1" is the mailcow created network gateway in Docker.
Relaying over this interface is necessary (instead of - for example - relaying directly over ${MAILCOW_HOSTNAME}) to relay over a known internal network.

Restart Postfix after applying your changes.
