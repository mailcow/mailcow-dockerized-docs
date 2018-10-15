## Let's Encrypt (out-of-the-box)

The newly introduced "acme-mailcow" container (21st of June) will try to obtain a valid LE certificate for you.

!!! warning
    mailcow **must** be available on port 80 for the acme-client to work.
    
By default, which means **0 domains** are added to mailcow, it will try to obtain a certificate for ${MAILCOW_HOSTNAME}.

For each domain you add, it will try to resolve autodiscover.ADDED_MAIL_DOMAIN and autoconfig.ADDED_MAIL_DOMAIN to your servers IPv4 address. If it succeeds, these names will be added as SANs to the certificate request.

You can skip the IP verification by adding SKIP_IP_CHECK=y to mailcow.conf (no quotes). Be warned that a misconfiguration will get you ratelimited by Let's Encrypt! This is primarily useful for multi-IP setups where the IP check would return the incorrect source IP. Due to using dynamic IPs for acme-mailcow, source NAT is not consistent over restarts.

You could add an A record for "autodiscover" but omit "autoconfig", the client will only validate "autodiscover" and skip "autoconfig" then.

For every domain you remove, the certificate will be moved and a new certificate will be requested. It is not possible to keep domains in a certificate, when we are not able validate the challenge for those.

If you want to re-run the ACME client, use `docker-compose restart acme-mailcow`.

### Additional domain names

Edit "mailcow.conf" and add a parameter "ADDITIONAL_SAN" like this:

!!! info
    Make sure you are using acme-mailcow:1.5 or above in docker-compose.yml - if not, update mailcow first!

Do not use quotes (`"`)!

```
ADDITIONAL_SAN=cert1.example.org,cert1.example.com,cert2.example.org,cert3.example.org
```

Each name will be validated against its IPv6 address (prefered if present) or IPv4.

Before recreating the acme container make sure that your Domain provider actually already returns the new address(es). Some needs a bit of time to do that and when it fails the next retry is after 24 hours.

```
dig cert1.example.org NS +short | head -1
dig cert1.example.org +short @(return from above)
```
The last output needs to return the correct IPv4 address. If you use IPv6 you need to add AAAA in the last command before the @. If it is not installed ```apt install dnsutils```.

Run `docker-compose up -d` to recreate changed containers.

**Skip Let's Encrypt function**

Change `SKIP_LETS_ENCRYPT=y` in mailcow.conf and restart the stack by running `docker-compose down && docker-compose up -d`.

## Use own certificates

To use your own certificates, just save the combined certificate (containing the certificate and intermediate CA/CA if any) to `data/assets/ssl/cert.pem` and the corresponding key to `data/assets/ssl/key.pem`.

Restart changed containers by running `docker-compose up -d`.

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
