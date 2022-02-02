On February the 12th 2020 we disabled the deprecated protocols TLS 1.0 and 1.1 in Dovecot (POP3, POP3S, IMAP, IMAPS) and Postfix (SMTPS, SUBMISSION).

Unauthenticated mail via SMTP on port 25/tcp does still accept >= TLS 1.0 . It is better to accept a weak encryption than none at all.

**How to re-enable weak protocols?**

Edit `data/conf/postfix/extra.cf`:

```
submission_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3
smtps_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3
```

Edit `data/conf/dovecot/extra.conf`:

```
ssl_min_protocol = TLSv1
```

Restart the affected services:

```
docker-compose restart postfix-mailcow dovecot-mailcow
```

Hint: You can enable TLS 1.2 in Windows 7.