To create persistent (over updates) sites hosted by mailcow: dockerized, a new site configuration must be placed inside `data/conf/nginx/`:

```
nano data/conf/nginx/my_custom_site.conf
```

A good template to begin with:

``` hl_lines="9"
server {
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  index index.php index.html;
  client_max_body_size 0;
  root /web;
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name mysite.example.org;

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

``` hl_lines="9,21"
server {
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  index index.php index.html;
  client_max_body_size 0;
  root /web;
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name example.domain.tld;

  location ^~ /.well-known/acme-challenge/ {
    allow all;
    default_type "text/plain";
  }

  if ($scheme = http) {
    return 301 https://$host$request_uri;
  }

  location / {
    proxy_pass http://127.0.0.1:3000/;
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
