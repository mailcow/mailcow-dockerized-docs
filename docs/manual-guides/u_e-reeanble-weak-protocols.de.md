Am 12. Februar 2020 haben wir die veralteten Protokolle TLS 1.0 und 1.1 in Dovecot (POP3, POP3S, IMAP, IMAPS) und Postfix (SMTPS, SUBMISSION) deaktiviert.

Unauthentifizierte Mails über SMTP an Port 25/tcp akzeptieren weiterhin >= TLS 1.0 . Es ist besser, eine schwache Verschlüsselung zu akzeptieren als gar keine.

**Wie kann man schwache Protokolle wieder aktivieren?**

Bearbeiten Sie `data/conf/postfix/extra.cf`:

```
submission_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3
smtps_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3
```

Bearbeiten Sie `data/conf/dovecot/extra.conf`:

```
ssl_min_protocol = TLSv1
```

Starten Sie die betroffenen Dienste neu:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow dovecot-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow dovecot-mailcow
    ```

Tipp: Sie können TLS 1.2 in Windows 7 aktivieren.