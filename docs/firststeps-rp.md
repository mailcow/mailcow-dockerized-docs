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

!!! warning
    If you enable TLS SNI (`ENABLE_TLS_SNI` in mailcow.conf), the certificate paths in your reverse proxy **must** match the correct paths in data/assets/ssl/{hostname}. The certificates will be split into `data/assets/ssl/{hostname1,hostname2,etc}` and therefore will not work when you copy the examples from below pointing to `data/assets/ssl/cert.pem` etc.

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

``` apache hl_lines="2 5 6 12 13 19 22 23 26 27 28 29 34 35"
<VirtualHost *:80>
  ServerName CHANGE_TO_MAILCOW_HOSTNAME
  ServerAlias autodiscover.*
  ServerAlias autoconfig.*
  ServerAlias xmpp_prefix_if_any.domain
  ServerAlias *.xmpp_prefix_if_any.domain
  RewriteEngine on

  RewriteCond %{HTTPS} off
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
  ServerAlias xmpp_prefix_if_any.domain
  ServerAlias *.xmpp_prefix_if_any.domain

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

``` hl_lines="4 10 12 13 25 39"
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.* autoconfig.* xmpp_prefix_if_any.domain *.xmpp_prefix_if_any.domain;
  return 301 https://$host$request_uri;
}
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.* autoconfig.* xmpp_prefix_if_any.domain *.xmpp_prefix_if_any.domain;

  ssl_certificate MAILCOW_PATH/data/assets/ssl/cert.pem;
  ssl_certificate_key MAILCOW_PATH/data/assets/ssl/key.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;

  # See https://ssl-config.mozilla.org/#server=nginx for the latest ssl settings recommendations
  # An example config is given below
  ssl_protocols TLSv1.2;
  ssl_ciphers HIGH:!aNULL:!MD5:!SHA1:!kRSA;
  ssl_prefer_server_ciphers off;

  location /Microsoft-Server-ActiveSync {
    proxy_pass http://127.0.0.1:8080/Microsoft-Server-ActiveSync;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_connect_timeout 75;
    proxy_send_timeout 3650;
    proxy_read_timeout 3650;
    proxy_buffers 64 256k;
    client_body_buffer_size 512k;
    client_max_body_size 0;
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

### HAProxy (community supported)

!!! warning
    This is an unsupported community contribution. Feel free to provide fixes.

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

### Traefik v2 (community supported)

!!! warning
    This is an unsupported community contribution. Feel free to provide fixes.

**Important**: This config only covers the "reverseproxing" of the webpannel (nginx-mailcow) using Traefik v2, if you also want to reverseproxy the mail services such as dovecot, postfix... you'll just need to adapt the following config to each container and create an [EntryPoint](https://docs.traefik.io/routing/entrypoints/) on your `traefik.toml` or `traefik.yml` (depending which config you use) for each port. 

For this section we'll assume you have your Traefik 2 `[certificatesresolvers]` properly configured on your traefik configuration file, and also using acme, also, the following example uses Lets Encrypt, but feel free to change it to your own cert resolver. You can find a basic Traefik 2 toml config file with all the above implemented which can be used for this example here [traefik.toml](https://github.com/Frenzoid/TraefikBasicConfig/blob/master/traefik.toml) if you need one, or a hint on how to adapt your config.


So, first of all, we are going to disable the acme-mailcow container since we'll use the certs that traefik will provide us.
For this we'll have to set `SKIP_LETS_ENCRYPT=y` on our `mailcow.conf`, and run `docker-compose up -d` to apply the changes.

Then we'll create a `docker-compose.override.yml` file in order to override the main `docker-compose.yml` found in your mailcow root folder. 

```
version: '2.1'

services:
    nginx-mailcow:
      networks:
        # add Traefik's network
        web:
      labels:
        - traefik.enable=true
        # Creates a router called "moo" for the container, and sets up a rule to link the container to certain rule,
        #   in this case, a Host rule with our MAILCOW_HOSTNAME var.
        - traefik.http.routers.moo.rule=Host(`${MAILCOW_HOSTNAME}`)
        # Enables tls over the router we created before.
        - traefik.http.routers.moo.tls=true
        # Specifies which kind of cert resolver we'll use, in this case le (Lets Encrypt).
        - traefik.http.routers.moo.tls.certresolver=le
        # Creates a service called "moo" for the container, and specifies which internal port of the container
        #   should traefik route the incoming data to.
        - traefik.http.services.moo.loadbalancer.server.port=80
        # Specifies which entrypoint (external port) should traefik listen to, for this container.
        #   websecure being port 443, check the traefik.toml file liked above.
        - traefik.http.routers.moo.entrypoints=secure
        # Make sure traefik uses the web network, not the mailcowdockerized_mailcow-network
        - traefik.docker.network=web

    certdumper:
        image: humenius/traefik-certs-dumper
        container_name: traefik_certdumper
        network_mode: none
        volumes:
          # mount the folder which contains Traefik's `acme.json' file
          #   in this case Traefik is started from its own docker-compose in ../traefik
          - ../traefik/data:/traefik:ro
          # mount mailcow's SSL folder
          - ./data/assets/ssl/:/output:rw
        environment:
          # only change this, if you're using another domain for mailcow's web frontend compared to the standard config
          - DOMAIN=${MAILCOW_HOSTNAME}

networks:
  web:
    external: true
```

Start the new containers with `docker-compose up -d`.


Now, there's only one thing left to do, which is setup the certs so that the mail services can use them as well, since Traefik 2 uses an acme v2 format to save ALL the license from all the domains we have, we'll need to find a way to dump the certs, lucky we have [this tiny container](https://hub.docker.com/r/humenius/traefik-certs-dumper) which grabs the `acme.json` file trough a volume, and a variable `DOMAIN=example.org`, and with these, the container will output the `cert.pem` and `key.pem` files, for this we'll simply run the `traefik-certs-dumper` container binding the `/traefik` volume to the folder where our `acme.json` is saved, bind the `/output` volume to our mailcow `data/assets/ssl/` folder, and set up the `DOMAIN=example.org` variable to the domain we want the certs dumped from. 

This container will watch over the `acme.json` file for any changes, and regenerate the `cert.pem` and `key.pem` files directly into `data/assets/ssl/` being the path binded to the container's `/output` path.

You can use the command line to run it, or use the docker-compose shown [here](https://hub.docker.com/r/humenius/traefik-certs-dumper).

After we have the certs dumped, we'll have to reload the configs from our postfix and dovecot containers, and check the certs, you can see how [here](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-ssl/#how-to-use-your-own-certificate).

Aaand that should be it 😊, you can check if the Traefik router works fine trough Traefik's dashboard / traefik logs / accessing the setted domain trough https, or / and check HTTPS, SMTP and IMAP trough the commands shown on the page linked before.


### Optional: Post-hook script for non-mailcow ACME clients

Using a local certbot (or any other ACME client) requires to restart some containers, you can do this with a post-hook script.
Make sure you change the paths accordingly:
```
#!/bin/bash
cp /etc/letsencrypt/live/my.domain.tld/fullchain.pem /opt/mailcow-dockerized/data/assets/ssl/cert.pem
cp /etc/letsencrypt/live/my.domain.tld/privkey.pem /opt/mailcow-dockerized/data/assets/ssl/key.pem
postfix_c=$(docker ps -qaf name=postfix-mailcow)
dovecot_c=$(docker ps -qaf name=dovecot-mailcow)
nginx_c=$(docker ps -qaf name=nginx-mailcow)
docker restart ${postfix_c} ${dovecot_c} ${nginx_c}
```

### Adding additional server names for mailcow UI

If you plan to use a server name that is not `MAILCOW_HOSTNAME` in your reverse proxy, make sure to populate that name in mailcow.conf via `ADDITIONAL_SERVER_NAMES` first. Names must be separated by commas and **must not** contain spaces. If you skip this step, mailcow may respond to your reverse proxy with an incorrect site.

```
ADDITIONAL_SERVER_NAMES=webmail.domain.tld,other.example.tld
```

Run `docker-compose up -d` to apply.
