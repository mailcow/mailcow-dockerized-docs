If you want to change the default ciphers and TLS versions accepted in Dovecot as per it's current release to something stronger, you could add following to Dovecot's [extra.conf](u_e-dovecot-extra_conf.en.md):

```bash
ssl_min_protocol = TLSv1.2
ssl_cipher_list = ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305
```

If you want to adjust the ciphers for Postfix as well you can find the corresponding tutorial [here](../Postfix/u_e-postfix-harden_ciphers.en.md).