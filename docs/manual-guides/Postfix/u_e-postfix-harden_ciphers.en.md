If you want to change the default ciphers and TLS versions accepted in postfix as per it's current release to something stronger, you could add following inside Postfix [extra.cf](u_e-postfix-extra_cf.en.md):

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

Such a configuration will pass current (2024-10-21) configuration checks against services like Internet.nl.

Postfix will complain about duplicate values once after starting `postfix-mailcow`, this is intended.

Syslog-ng was configured to hide those warnings while Postfix is running, to not spam the log files with unnecessary information every time a service is used.