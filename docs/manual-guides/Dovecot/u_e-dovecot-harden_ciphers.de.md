Wenn Sie die Standard-Cipher und TLS-Versionen, die in Dovecot akzeptiert werden, entsprechend der aktuellen Version auf stärkere Einstellungen ändern möchten, können Sie Folgendes zu Dovecots [extra.conf](u_e-dovecot-extra_conf.de.md) hinzufügen:

```bash
ssl_min_protocol = TLSv1.2
ssl_cipher_list = ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305
```

Falls Sie auch die Cipher für Postfix anpassen wollen finden Sie [hier](../Postfix/u_e-postfix-harden_ciphers.de.md) eine entsprechende Anleitung.