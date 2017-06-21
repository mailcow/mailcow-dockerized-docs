## Let's Encrypt (out-of-the-box)

The newly introduced "acme-mailcow" container (21st of June) will try to obtain a valid LE certificate for you.

!!! warning
    mailcow ***must** be available on port 80 for the acme-client to work.
    
By default, which means **0 domains** are added to mailcow, it will try to obtain a certificate for ${MAILCOW_HOSTNAME}.

For each domain you add, it will try to resolve autodiscover.ADDED_MAIL_DOMAIN and autoconfig.ADDED_MAIL_DOMAIN to your servers IPv4 address. If it succeeds, these names will be added as SANs to the certificate request.

You could add an A record for "autodiscover" but omit "autoconfig", the client will only validate "autodiscover" and skip "autoconfig" then.

For every domain you remove, the certificate will be moved and a new certificate will be requested. It is not possible to keep domains in a certificate, when we are not able validate the challenge for those.

### Additional domain names

Edit "mailcow.conf" and add a parameter "ADDITIONAL_SAN" like this:

```
ADDITIONAL_SAN="cert1.example.org cert1.example.com cert2.example.org cert3.example.org"
```

Each name will be validated against its IPv4 address.

## Check your configuration

Run `docker-compose logs acme-mailcow` to find out why a validation fails.

To check if nginx serves the correct certificate, simply use a browser of your choice and check the displayed certificate.

To check the certificate served by dovecot or postfix we will use `openssl`:

```
# Connect via SMTP (25)
openssl s_client -starttls smtp -crlf -connect mx.mailcow.email:25
# Connect via SMTPS (465)
openssl s_client -showcerts -connect mx.mailcow.email:465
# Connect via SUBMISSION (587)
openssl s_client -starttls smtp -crlf -connect mx.mailcow.email:587
```
