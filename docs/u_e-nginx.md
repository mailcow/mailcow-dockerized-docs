## SSL

Please see [Advanced SSL](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-ssl/) and explicitly check `ADDITIONAL_SERVER_NAMES` for SSL configuration.

Please do not add ADDITIONAL_SERVER_NAMES when you plan to use a different web root.

## New site

To create persistent (over updates) sites hosted by mailcow: dockerized, a new site configuration must be placed inside `data/conf/nginx/`:

A good template to begin with:

```
nano data/conf/nginx/my_custom_site.conf
```

``` hl_lines="16"
server {
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
  ssl_ecdh_curve X25519:X448:secp384r1:secp256k1;
  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 1d;
  ssl_session_tickets off;
  index index.php index.html;
  client_max_body_size 0;
  # Location: data/web
  root /web;
  # Location: data/web/mysite.com
  #root /web/mysite.com
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name mysite.example.org;
  server_tokens off;

  # This allows acme to be validated even with a different web root
  location ^~ /.well-known/acme-challenge/ {
    default_type "text/plain";
    rewrite /.well-known/acme-challenge/(.*) /$1 break;
    root /web/.well-known/acme-challenge/;
  }

  if ($scheme = http) {
    return 301 https://$server_name$request_uri;
  }
}
```

## New site with proxy to a remote location

Another example with a reverse proxy configuration:

```
nano data/conf/nginx/my_custom_site.conf
```

``` hl_lines="16 28"
server {
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  ssl_ciphers ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305;
  ssl_ecdh_curve X25519:X448:secp384r1:secp256k1;
  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 1d;
  ssl_session_tickets off;
  index index.php index.html;
  client_max_body_size 0;
  root /web;
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name example.domain.tld;
  server_tokens off;

  location ^~ /.well-known/acme-challenge/ {
    allow all;
    default_type "text/plain";
  }

  if ($scheme = http) {
    return 301 https://$host$request_uri;
  }

  location / {
    proxy_pass http://service:3000/;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    client_max_body_size 0;
  }
}
```

## Config expansion in mailcows Nginx

The filename used for a new site is not important, as long as the filename carries a .conf extension.

It is also possible to extend the configuration of the default file `site.conf` file:

```
nano data/conf/nginx/site.my_content.custom
```

This filename does not need to have a ".conf" extension but follows the pattern `site.*.custom`, where `*` is a custom name.

If PHP is to be included in a custom site, please use the PHP-FPM listener on phpfpm:9002 or create a new listener in `data/conf/phpfpm/php-fpm.d/pools.conf`.

Restart Nginx (and PHP-FPM, if a new listener was created):

```
docker-compose restart nginx-mailcow
docker-compose restart php-fpm-mailcow
```

