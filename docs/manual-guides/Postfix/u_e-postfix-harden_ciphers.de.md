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