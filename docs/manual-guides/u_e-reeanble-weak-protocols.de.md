Am 12. Februar 2020 haben wir die veralteten Protokolle TLS 1.0 und 1.1 in Dovecot (POP3, POP3S, IMAP, IMAPS) und Postfix (SMTPS, SUBMISSION) deaktiviert.

Mit dem Juni 2024 Patch (2024-06) wurde auch TLS 1.0 und TLS 1.1 für unauthentifizierte Mails über SMTP auf Port 25/tcp deaktiviert, da die meisten modernen und gut konfigurierten E-Mail-Server im Internet mittlerweile bessere Verschlüsselungen als TLS 1.0/1.1 nutzen.

**Wie kann man schwache Protokolle wieder aktivieren, falls erforderlich?**

Bearbeiten Sie `data/conf/postfix/extra.cf`:

```
# Für SMTPS/Submission
submission_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3
smtps_smtpd_tls_mandatory_protocols = !SSLv2, !SSLv3

# Für SMTP (via STARTTLS)
smtp_tls_protocols = !SSLv2, !SSLv3
smtpd_tls_protocols = !SSLv2, !SSLv3
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