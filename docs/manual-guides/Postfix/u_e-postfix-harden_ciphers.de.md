Wenn Sie die Standard-Cipher und TLS-Versionen, die in Postfix akzeptiert werden, entsprechend der aktuellen Version auf stärkere Einstellungen ändern möchten, können Sie Folgendes zu Postfix [extra.cf](u_e-postfix-extra_cf.de.md) hinzufügen:

```bash
tls_high_cipherlist = ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
tls_preempt_cipherlist = yes

smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_ciphers = high
smtp_tls_mandatory_ciphers = high

smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_tls_ciphers = high
smtpd_tls_mandatory_ciphers = high
```

Eine solche Konfiguration wird die aktuellen (2024-10-21) Konfigurationsprüfungen bei Diensten wie Internet.nl bestehen.

Falls Sie auch die Cipher für Dovecot anpassen wollen finden Sie [hier](../Dovecot/u_e-dovecot-harden_ciphers.de.md) eine entsprechende Anleitung.

!!! warning "Wichtiges Update Q2 2026"
    Seit v1.11.0 vom 2026-04-21 von Internet.nl können Sie mit diesem Verfahren keine 100 % mehr erreichen, da diese Version die Fassung 2025-05 der NCSC-TLS-Richtlinien enthält. Bitte beachten Sie die unten beschriebene zusätzliche Konfiguration. Ohne dieses Update werden Sie für _unzureichend_ sichere Hash-Funktionen beim Schlüsselaustausch (SHA1) abgestraft.

Erstellen Sie eine Datei `data/conf/postfix/openssl.cnf` mit folgendem Inhalt:

```
postfix = postfix_settings

[postfix_settings]
ssl_conf = postfix_ssl_settings

[postfix_ssl_settings]
system_default = baseline_postfix_settings

[baseline_postfix_settings]
SignatureAlgorithms = ECDSA+SHA256:ECDSA+SHA384:ECDSA+SHA512:RSA-PSS+SHA256:RSA-PSS+SHA384:RSA-PSS+SHA512:RSA+SHA512:RSA+SHA256:RSA+SHA384
```

Fügen Sie Ihrer aktuellen `data/conf/postfix/extra.cf` Folgendes hinzu:

```
tls_config_file = /opt/postfix/conf/openssl.cnf
tls_config_name = postfix
```

Die vollständige `extra.cf` kann nun also wie folgt aussehen:

```
tls_config_file = /opt/postfix/conf/openssl.cnf
tls_config_name = postfix

tls_high_cipherlist = ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256
tls_preempt_cipherlist = yes

smtp_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtp_tls_ciphers = high
smtp_tls_mandatory_ciphers = high

smtpd_tls_protocols = !SSLv2, !SSLv3, !TLSv1, !TLSv1.1
smtpd_tls_ciphers = high
smtpd_tls_mandatory_ciphers = high
```

für eine ordnungsgemäß gehärtete Konfiguration. Achten Sie darauf, keine bereits vorhandenen Einstellungen zu überschreiben, die möglicherweise noch benötigt werden.

Starten Sie `postfix-mailcow` neu, um Ihre Änderungen zu übernehmen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

