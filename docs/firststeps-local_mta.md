The easiest option would be to disable the listener on port 25/tcp.

**Postfix** users disable the listener by commenting the following line (starting with `smtp` or `25`) in `/etc/postfix/master.cf`:
```
#smtp      inet  n       -       -       -       -       smtpd
```
Restart Postfix after applying your changes.
