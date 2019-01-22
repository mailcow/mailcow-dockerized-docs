You don't need to change the Nginx site that comes with mailcow: dockerized.
mailcow: dockerized trusts the default gateway IP 172.22.1.1 as proxy.

1\. Make sure you change HTTP_BIND and HTTPS_BIND in `mailcow.conf` to a local address and set the ports accordingly, for example:
``` bash
HTTP_BIND=127.0.0.1
HTTP_PORT=8080
HTTPS_BIND=127.0.0.1
HTTPS_PORT=8443
```
**IMPORTANT:** Do not use port 8081!

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
We rewrite to HTTPS, but keep requests to autoconfig.* on a plain session.

Let's Encrypt will follow our rewrite, certificate requests will work fine.

**Take care of highlighted lines.**

``` apache hl_lines="2 12 13 19 23 24 29 30"
<VirtualHost *:80>
  ServerName CHANGE_TO_MAILCOW_HOSTNAME
  ServerAlias autodiscover.*
  ServerAlias autoconfig.*
  RewriteEngine on

  RewriteCond %{HTTP_HOST} ^autoconfig\. [NC]
  RewriteRule ^ - [S=1]
  RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI}# [L,NE,R=permanent]
  RewriteRule ^ /autoconfig.php [PT]

  ProxyPass / http://127.0.0.1:8080/
  ProxyPassReverse / http://127.0.0.1:8080/
  ProxyPreserveHost On
  ProxyAddHeaders On
  RequestHeader set X-Forwarded-Proto "http"
</VirtualHost>
<VirtualHost *:443>
  ServerName CHANGE_TO_MAILCOW_HOSTNAME
  ServerAlias autodiscover.*

  # You should proxy to a plain HTTP session to offload SSL processing
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
In our Nginx reverse proxy template, we rewrite all requests to HTTPS, while keeping autoconfig.* domains on a plain session.

Let's Encrypt will follow our rewrite, certificate requests will work fine.

**Take care of highlighted lines.**

``` hl_lines="4 13 23 26 27"
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.*;
  return 301 https://$host$request_uri;
}
server {
  listen 80;
  listen [::]:80;
  server_name autoconfig.*;
  rewrite ^/(.*)$ /autoconfig.php last;
  location / {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    client_max_body_size 0;
  }
}
server {
  listen 443;
  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.* autoconfig.*;

  ssl on;
  ssl_certificate MAILCOW_PATH/data/assets/ssl/cert.pem;
  ssl_certificate_key MAILCOW_PATH/data/assets/ssl/key.pem;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5;

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

### Caddy
In our Caddy reverse proxy template, we rewrite all requests to HTTPS, while keeping autoconfig.* domains on a plain session.

Let's Encrypt will follow our rewrite, certificate requests will work fine.

**Take care of highlighted lines.**

``` hl_lines="1 2 14"
CHANGE_TO_MAILCOW_HOSTNAME:80 CHANGE_TO_MAILCOW_HOSTNAME:443 autodiscover.YOURDOMAIN:80 autodiscover.YOURDOMAIN:443 {
    tls MAILCOW_PATH/data/assets/ssl/cert.pem MAILCOW_PATH/data/assets/ssl/key.pem
    proxy / 127.0.0.1:8080 {
        header_upstream Host {host}
        header_upstream X-Real-IP {remote}
        header_upstream X-Forwarded-For {remote}
        header_upstream X-Forwarded-Proto {scheme}
    }
    redir 301 {
                if {scheme} not https
                / https://{host}{uri}
    }
}
http://autoconfig.YOURDOMAIN {
    rewrite / /autoconfig.php
    proxy / 127.0.0.1:8080 {
         header_upstream Host {host}
         header_upstream X-Real-IP {remote}
         header_upstream X-Forwarded-For {remote}
         header_upstream X-Forwarded-Proto {scheme}
    }
}
```

!!! warning
    If Caddy is running under a non-root user you need to change the permissions of the `key.pem` with these commands:
    ``` hl_lines="1 2"
    chmod 440 MAILCOW_PATH/data/assets/ssl/key.pem
    chown root:caddy MAILCOW_PATH/data/assets/ssl/key.pem
    ```

!!! info
    The Caddy reverse proxy template is unusual, normaly we would use the Automatic HTTPS feature of Caddy but we don't want to get banned by Let's Encrypt by issuing duplicate certificates from the same IP.
    The port specification is unusual too, it's due to the fact that Caddy bind to the default port 2015 when a custom certificate is used, please refer to [this issue](https://github.com/mholt/caddy/issues/1673) for more informations.

### Optional: Post-hook script for non-mailcow ACME clients

Using a local certbot (or any other ACME client) requires to restart some containers, you can do this with a post-hook script.
Make sure you change the pathes accordingly:
```
#!/bin/bash
cp /etc/letsencrypt/live/my.domain.tld/fullchain.pem /opt/mailcow-dockerized/data/assets/ssl/cert.pem
cp /etc/letsencrypt/live/my.domain.tld/privkey.pem /opt/mailcow-dockerized/data/assets/ssl/key.pem
postfix_c=$(docker ps -qaf name=postfix-mailcow)
dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
nginx_c=$(docker ps -qaf name=nginx-mailcow)
docker restart ${postfix_c} ${dovecot_c} ${nginx_c}
```
