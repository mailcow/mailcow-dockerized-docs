On February 12th, 2020, we disabled the deprecated protocols TLS 1.0 and 1.1 in Dovecot (POP3, POP3S, IMAP, IMAPS) and Postfix (SMTPS, SUBMISSION).

With the June 2024 Patch (2024-06), TLS 1.0 and TLS 1.1 were also disabled for unauthenticated mail via SMTP on port 25/tcp, as most modern and well-configured email servers on the internet now use better encryptions than TLS 1.0/1.1.

**How to re-enable weak protocols if necessary?**

Edit `data/conf/postfix/extra.cf`:

```
# For SMTPS/Submission
submission_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3
smtps_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3

# For SMTP (via STARTTLS)
smtp_tls_protocols = !SSLv2, !SSLv3
smtpd_tls_protocols = !SSLv2, !SSLv3
```

Edit `data/conf/dovecot/extra.conf`:

```
ssl_min_protocol = TLSv1
```

Restart the affected services:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow dovecot-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow dovecot-mailcow
    ```

Hint: You can enable TLS 1.2 in Windows 7.