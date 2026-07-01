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

If you want to adjust the ciphers for Dovecot as well you can find the corresponding tutorial [here](../Dovecot/u_e-dovecot-harden_ciphers.en.md).

!!! warning "Important update Q2 2026"
    Since v1.11.0 from 2026-04-21 of Internet.nl, you will not be able to score 100% anymore with this procedure since this version includes the 2025-05 version of the NCSC TLS guidelines. Please see below the extra configuration needed. Without this updated, you will be sanctioned for _insufficiently_ secure hash functions for key exchange (SHA1)

Create a file `data/conf/postfix/openssl.cnf` with the following content:

```
postfix = postfix_settings

[postfix_settings]
ssl_conf = postfix_ssl_settings

[postfix_ssl_settings]
system_default = baseline_postfix_settings

[baseline_postfix_settings]
SignatureAlgorithms = ECDSA+SHA256:ECDSA+SHA384:ECDSA+SHA512:RSA-PSS+SHA256:RSA-PSS+SHA384:RSA-PSS+SHA512:RSA+SHA512:RSA+SHA256:RSA+SHA384
```

Add to your current `data/conf/postfix/extra.cf` the following:

```
tls_config_file = /opt/postfix/conf/openssl.cnf
tls_config_name = postfix
```

So the complete `extra.cf` no may read:

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

for a properly hardened configuration. Beware not to override any existing settings you might had there if they are still needed.

Restart `postfix-mailcow` to apply your changes:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart postfix-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart postfix-mailcow
    ```

