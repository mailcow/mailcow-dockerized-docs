## Let's Encrypt (out-of-the-box)

The "acme-mailcow" container will try to obtain a valid LE certificate for you.
    
By default, which means **0 domains** are added to mailcow, it will try to obtain a certificate for ${MAILCOW_HOSTNAME}.

For each domain you add, it will try to resolve autodiscover.ADDED_MAIL_DOMAIN to your servers IP address. If it succeeds, these names will be added as SANs to the certificate request.

You can skip the IP verification by adding SKIP_IP_CHECK=y to mailcow.conf (no quotes). Be warned that a misconfiguration will get you ratelimited by Let's Encrypt! This is primarily useful for multi-IP setups where the IP check would return the incorrect source IP. Due to using dynamic IPs for acme-mailcow, source NAT is not consistent over restarts.

The client only validates domains for which A and/or AAAA records have been setup that point to the Mailcow instance.

For every domain you add or remove, the certificate will be moved and a new certificate will be requested. It is not possible to keep domains in a certificate, when we are not able validate the challenge for those.

If you want to re-run the ACME client, use `docker-compose restart acme-mailcow`.

### Additional domain names

Edit "mailcow.conf" and add/update the parameter "ADDITIONAL_SAN" like this:

```
ADDITIONAL_SAN=cert1.example.org,cert1.example.com,cert2.example.org,cert3.example.org
```
Do not use quotes (`"`)!

Each name will be validated against its IP address.

Run `docker-compose up -d` to recreate changed containers.

### ECDSA certificates

By default (starting with acme-mailcow:1.50), Mailcow deploys an additional ECDSA certificate in addition to the RSA certificate for new installations. To stop issuing ECDSA certificates from letsencrypt, change `SKIP_ECDSA_CERT=y` in mailcow.conf and apply the changes by running `docker-compose up -d`.

However, when upgrading Mailcow this option defaults to `SKIP_ECDSA_CERT=y` to avoid possible connection failures when using TLSA DNS records. If you don't have any TLSA records in your DNS config or if you will add additional TLSAs for the new certificate, you can change that.

### Skip Let's Encrypt function
Change `SKIP_LETS_ENCRYPT=y` in mailcow.conf and run `docker-compose up -d`.

## Use own certificates

To use your own certificates, just save the combined certificate (containing the certificate and intermediate CA if any) to `data/assets/ssl/cert.pem` and the corresponding key to `data/assets/ssl/key.pem`.

You can also provide an ECDSA certificate in the same format in `data/assets/ssl/ecdsa-cert.pem` and `data/assets/ssl/ecdsa-key.pem`. If you don't want this, you can create a symbolic link for each of these files to `cert.pem` and `key.pem` to disable the feature.

Afterwards, restart the stack by running `docker-compose down && docker-compose up -d`.

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
