You don't need to change the Nginx site that comes with mailcow: dockerized.
mailcow: dockerized trusts the default gateway IP 172.22.1.1 as proxy.

1\. Make sure you change HTTP_BIND and HTTPS_BIND in `mailcow.conf` to a local address and set the ports accordingly, for example:
``` bash
HTTP_BIND=127.0.0.1
HTTP_PORT=8080
HTTPS_BIND=127.0.0.1
HTTPS_PORT=8443
```

This will also change the bindings inside the Nginx container! This is important, if you decide to use a proxy within Docker.

**IMPORTANT:** Do not use port 8081, 9081 or 65510!

Recreate affected containers by running `docker-compose up -d`.

!!! warning
    Make sure you run `generate_config.sh` before you enable any site configuration examples below.
    The script `generate_config.sh` copies snake-oil certificates to the correct location, so the services will not fail to start due to missing files.

!!! info
    Using the site configs below will **forward ACME requests to mailcow** and let it handle certificates itself.
    The downside of using mailcow as ACME client behind a reverse proxy is, that you will need to reload your webserver after acme-mailcow changed/renewed/created the certificate. You can either reload your webserver daily or write a script to watch the file for changes.
    On many servers logrotate will reload the webserver daily anyway.

    If you want to use a local certbot installation, you will need to change the SSL certificate parameters accordingly.
    **Make sure you run a post-hook script** when you decide to use external ACME clients. You will find an example at the bottom of this page.


2\. Configure your local webserver as reverse proxy:

### Apache 2.4
Required modules:
```
a2enmod rewrite proxy proxy_http headers ssl
```

Let's Encrypt will follow our rewrite, certificate requests in mailcow will work fine.

**Take care of highlighted lines.**

``` apache hl_lines="2 10 11 17 22 23 24 25 30 31"
<VirtualHost *:80>
  ServerName CHANGE_TO_MAILCOW_HOSTNAME
  ServerAlias autodiscover.*
  ServerAlias autoconfig.*
  RewriteEngine on

  RewriteCond %{HTTPS} !=on
  RewriteRule ^/?(.*) https://%{HTTP_HOST}/$1 [R=301,L]

  ProxyPass / http://127.0.0.1:8080/
  ProxyPassReverse / http://127.0.0.1:8080/
  ProxyPreserveHost On
  ProxyAddHeaders On
  RequestHeader set X-Forwarded-Proto "http"
</VirtualHost>
<VirtualHost *:443>
  ServerName CHANGE_TO_MAILCOW_HOSTNAME
  ServerAlias autodiscover.*
  ServerAlias autoconfig.*

  # You should proxy to a plain HTTP session to offload SSL processing
  ProxyPass /Microsoft-Server-ActiveSync http://127.0.0.1:8080/Microsoft-Server-ActiveSync connectiontimeout=4000
  ProxyPassReverse /Microsoft-Server-ActiveSync http://127.0.0.1:8080/Microsoft-Server-ActiveSync
  ProxyPass / http://127.0.0.1:8080/
  ProxyPassReverse / http://127.0.0.1:8080/
  ProxyPreserveHost On
  ProxyAddHeaders On
  RequestHeader set X-Forwarded-Proto "https"

  SSLCertificateFile MAILCOW_PATH/data/assets/ssl/cert.pem
  SSLCertificateKeyFile MAILCOW_PATH/data/assets/ssl/key.pem

  # If you plan to proxy to a HTTPS host:
  #SSLProxyEngine On

  # If you plan to proxy to an untrusted HTTPS host:
  #SSLProxyVerify none
  #SSLProxyCheckPeerCN off
  #SSLProxyCheckPeerName off
  #SSLProxyCheckPeerExpire off
</VirtualHost>
```

### Nginx

Let's Encrypt will follow our rewrite, certificate requests will work fine.

**Take care of highlighted lines.**

``` hl_lines="4 10 13 14 19 32"
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.* autoconfig.*;
  return 301 https://$host$request_uri;
}
server {
  listen 443;
  listen [::]:443;
  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.* autoconfig.*;

  ssl on;
  ssl_certificate MAILCOW_PATH/data/assets/ssl/cert.pem;
  ssl_certificate_key MAILCOW_PATH/data/assets/ssl/key.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;

  location /Microsoft-Server-ActiveSync {
    proxy_pass http://127.0.0.1:8080/Microsoft-Server-ActiveSync;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    client_max_body_size 0;
    proxy_connect_timeout 4000;
    proxy_next_upstream timeout error;
    proxy_send_timeout 4000;
    proxy_read_timeout 4000;
  }

  location / {
      proxy_pass http://127.0.0.1:8080/;
      proxy_set_header Host $http_host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      client_max_body_size 0;
  }
}
```

### HAProxy

**Important/Fixme**: This example only forwards HTTPS traffic and does not use mailcows built-in ACME client.

```
frontend https-in
  bind :::443 v4v6 ssl crt mailcow.pem
  default_backend mailcow

backend mailcow
  option forwardfor
  http-request set-header X-Forwarded-Proto https if { ssl_fc }
  http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
  server mailcow 127.0.0.1:8080 check
```

### Optional: Post-hook script for non-mailcow ACME clients

Using a local certbot (or any other ACME client) requires to restart some containers, you can do this with a post-hook script.
Make sure you change the pathes accordingly:
```
#!/bin/bash
cp /etc/letsencrypt/live/my.domain.tld/fullchain.pem /opt/mailcow-dockerized/data/assets/ssl/cert.pem
cp /etc/letsencrypt/live/my.domain.tld/privkey.pem /opt/mailcow-dockerized/data/assets/ssl/key.pem
# Either restart...
#postfix_c=$(docker ps -qaf name=postfix-mailcow)
#dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
#nginx_c=$(docker ps -qaf name=nginx-mailcow)
#docker restart ${postfix_c} ${dovecot_c} ${nginx_c}
# ...or reload:
docker exec $(docker ps -qaf name=postfix-mailcow) postfix reload
docker exec $(docker ps -qaf name=nginx-mailcow) nginx -s reload
docker exec $(docker ps -qaf name=dovecot-mailcow) dovecot reload
```
