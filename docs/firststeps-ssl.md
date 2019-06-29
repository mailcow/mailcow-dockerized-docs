## Let's Encrypt (out-of-the-box)

The "acme-mailcow" container will try to obtain a LE certificate for `${MAILCOW_HOSTNAME}`, `autodiscover.ADDED_MAIL_DOMAIN` and `autoconfig.ADDED_MAIL_DOMAIN`.

!!! warning
    mailcow **must** be available on port 80 for the acme-client to work. Our reverse proxy example configurations do cover that. You can also use any external ACME client (certbot for example) to obtain certificates, but you will need to make sure, that they are copied to the correct location and a post-hook reloads affected containers. See more in the Reverse Proxy documentation.
    
By default, which means **0 domains** are added to mailcow, it will try to obtain a certificate for `${MAILCOW_HOSTNAME}`.

For each domain you add, it will try to resolve `autodiscover.ADDED_MAIL_DOMAIN` and `autoconfig.ADDED_MAIL_DOMAIN` to its IPv6 or - if IPv6 is not configured in your domain - IPv4 address. If it succeeds, a name will be added as SAN to the certificate request.

Only names that can be validated, will be added as SAN.

For every domain you remove, the certificate will be moved and a new certificate will be requested. It is not possible to keep domains in a certificate, when we are not able validate the challenge for those.

If you want to re-run the ACME client, use `docker-compose restart acme-mailcow` and monitor its logs with `docker-compose logs --tail=200 -f acme-mailcow`.

### Additional domain names

Edit "mailcow.conf" and add a parameter `ADDITIONAL_SAN` like this:

Do not use quotes (`"`)!

```
ADDITIONAL_SAN=smtp.*,cert1.example.com,cert2.example.org,whatever.*
```

Each name will be validated against its IPv6 or - if IPv6 is not configured in your domain - IPv4 address.

A wildcard name like `smtp.*` will try to obtain a smtp.DOMAIN_NAME SAN for each domain added to mailcow.

Run `docker-compose up -d` to recreate affected containers automatically.

### Validation errors and how to skip validation

You can skip the **IP verification** by setting `SKIP_IP_CHECK=y` in mailcow.conf (no quotes). Be warned that a misconfiguration will get you ratelimited by Let's Encrypt! This is primarily useful for multi-IP setups where the IP check would return the incorrect source IP. Due to using dynamic IPs for acme-mailcow, source NAT is not consistent over restarts.

If you encounter problems with "HTTP validation", but your IP confirmation succeeds, you are most likely using firewalld, ufw or any other firewall, that disallows connections from `br-mailcow` to your external interface. Both firewalld and ufw disallow this by default. It is often not enough to just stop these firewall services. You'd need to stop mailcow (`docker-compose down`), stop the firewall service, flush the chains and restart Docker.

You can also skip this validation method by setting `SKIP_HTTP_VERIFICATION=y` in "mailcow.conf". Be warned that this is discouraged. Some DNS validations (like TLSA lookups) in mailcow UI will fail.

If you changed a SKIP_* parameter, run `docker-compose up -d` to apply your changes.

### Disable Let's Encrypt
#### Disable Let's Encrypt completely

Set `SKIP_LETS_ENCRYPT=y` in "mailcow.conf" and recreate "acme-mailcow" by running `docker-compose up -d`.

#### Skip all names but ${MAILCOW_HOSTNAME}

Add `ONLY_MAILCOW_HOSTNAME=y` to "mailcow.conf" and recreate "acme-mailcow" by running `docker-compose up -d`.

### How to use your own ceritficate

Make sure you disable mailcows internal LE client (see above).

To use your own certificates, just save the combined certificate (containing the certificate and intermediate CA/CA if any) to `data/assets/ssl/cert.pem` and the corresponding key to `data/assets/ssl/key.pem`.

Reload affected service:

```
docker exec $(docker ps -qaf name=postfix-mailcow) postfix reload
docker exec $(docker ps -qaf name=nginx-mailcow) nginx -s reload
docker exec $(docker ps -qaf name=dovecot-mailcow) dovecot reload
```

### Check your configuration

Run `docker-compose logs acme-mailcow` to find out why a validation fails.

To check if nginx serves the correct certificate, simply use a browser of your choice and check the displayed certificate.

To check the certificate served by Postfix, Dovecot and Nginx we will use `openssl`:

```
# Connect via SMTP (587)
echo "Q" | openssl s_client -starttls smtp -crlf -connect mx.mailcow.email:587
# Connect via IMAP (143)
echo "Q" | openssl s_client -starttls imap -showcerts -connect mx.mailcow.email:143
# Connect via HTTPS (443)
echo "Q" | openssl s_client -connect mx.mailcow.email:443
```
