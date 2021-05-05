To create persistent (over updates) sites hosted by mailcow: dockerized, a new site configuration must be placed inside `data/conf/nginx/`:

```
nano data/conf/nginx/my_custom_site.conf
```

A good template to begin with:

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
  root /web;
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name mysite.example.org;
  server_tokens off;

  location ^~ /.well-known/acme-challenge/ {
    allow all;
    default_type "text/plain";
  }

  if ($scheme = http) {
    return 301 https://$server_name$request_uri;
  }
}
```

Another example with a reverse proxy configuration:

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


The filename is not important, as long as the filename carries a .conf extension.

It is also possible to extend the configuration of the default file `site.conf` file:

```
nano data/conf/nginx/site.my_content.custom
```

This filename does not need to have a ".conf" extension, but follows the pattern `site.*.custom`, where `*` is a custom name.

If PHP is to be included in a custom site, please use the PHP-FPM listener on phpfpm:9002 or create a new listener in `data/conf/phpfpm/php-fpm.d/pools.conf`.

Restart Nginx (and PHP-FPM, if a new listener was created):

```
docker-compose restart nginx-mailcow
docker-compose restart php-fpm-mailcow
```
