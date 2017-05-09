!!! warning
    mailcow dockerized comes with a snake-oil CA "mailcow" and a server certificate in `data/assets/ssl`. Please use your own trusted certificates.

mailcow uses **at least** 3 domain names that should be covered by your new certificate:

- ${MAILCOW_HOSTNAME}
- autodiscover.**example.org**
- autoconfig.**example.org**

## Let's Encrypt

This is just an example of how to obtain certificates with certbot. There are several methods!

### 1\. Get the certbot client:
``` bash
wget https://dl.eff.org/certbot-auto -O /usr/local/sbin/certbot && chmod +x /usr/local/sbin/certbot
```

### 2\. Make sure you set `HTTP_BIND=0.0.0.0` and `HTTP_PORT=80` in `mailcow.conf` or setup a reverse proxy to enable connections to port 80. If you changed HTTP_BIND, then rebuild Nginx:
``` bash
docker-compose up -d
```

### 3\. Request the certificate with the webroot method:
``` bash
cd /path/to/git/clone/mailcow-dockerized
source mailcow.conf
certbot certonly \
    --webroot \
    -w ${PWD}/data/web \
    -d ${MAILCOW_HOSTNAME} \
    -d autodiscover.example.org \
    -d autoconfig.example.org \
    --email you@example.org \
    --agree-tos
```

!!! warning
    Remember to replace the example.org domain with your own domain, this command will not work if you don't.

### 4\. Create hard links to the full path of the new certificates. Assuming you are still in the mailcow root folder:
``` bash
mv data/assets/ssl/cert.{pem,pem.backup}
mv data/assets/ssl/key.{pem,pem.backup}
ln $(readlink -f /etc/letsencrypt/live/${MAILCOW_HOSTNAME}/fullchain.pem) data/assets/ssl/cert.pem
ln $(readlink -f /etc/letsencrypt/live/${MAILCOW_HOSTNAME}/privkey.pem) data/assets/ssl/key.pem
```

### 5\. Restart affected containers:
```
docker-compose restart postfix-mailcow dovecot-mailcow nginx-mailcow
```

When renewing certificates, run the last two steps (link + restart) as post-hook in a script.

## Check your configuration

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
