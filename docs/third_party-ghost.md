In order to enable [Ghost](https://ghost.org), the `docker-compose.override.yml` must be modified.

1\. Add the Additional domain names in `mailcow.conf`.[^1] e.g. DOMAIN.TLD and www.DOMAIN.TLD

2\. Create a new file `docker-compose.override.yml` (or expand existing one) in the mailcow-dockerized root folder and insert the following configuration

!!! info
   Change DOMAIN.TLD is importand and schema is __not__ http**s**
   
```
version: '2.1'
services:
    ghost:
      image: ghost:alpine
      restart: always
      volumes:
        - ./data/conf/ghost/content:/var/lib/ghost/content
      environment:
        - url=http://DOMAIN.TLD
      dns:
        - ${IPV4_NETWORK:-172.22.1}.254
      networks:
        mailcow-network:
          aliases:
            - ghost
```

3\. Create `data/conf/nginx/ghost.conf`:
```
server {
  include /etc/nginx/conf.d/listen_ssl.active;
  include /etc/nginx/mime.types;
  charset utf-8;
  override_charset on;

  ssl on;
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  ssl_protocols TLSv1.2;
  ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:50m;
  ssl_session_timeout 1d;
  ssl_session_tickets off;

  add_header Strict-Transport-Security "max-age=15768000;";
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";
  add_header X-Robots-Tag none;
  add_header X-Download-Options noopen;
  add_header X-Frame-Options "SAMEORIGIN" always;
  add_header X-Permitted-Cross-Domain-Policies none;
  add_header Referrer-Policy strict-origin;

  client_max_body_size 1024M;

  set_real_ip_from fc00::/7;
  set_real_ip_from 10.0.0.0/8;
  set_real_ip_from 172.16.0.0/12;
  set_real_ip_from 192.168.0.0/16;
  real_ip_header X-Forwarded-For;
  real_ip_recursive on;

  location ^~ /.well-known/acme-challenge/ {
                auth_basic off;
                allow all;
                root /web;
                try_files $uri =404;
                break;
        }

  location / {
                proxy_set_header Host $http_host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
                proxy_pass http://ghost;
        }
  }

```

4\. Apply your changes:
```
docker-compose up -d && docker-compose restart nginx-mailcow
```

Now you can simply navigate to https://DOMAIN.TLD/admin to view your Ghost container Admin page. You’ll then be prompted to specify a new Admin account. After specifying your Account, you’ll then be able to connect to the Ghost UI.

[^1](https://mailcow.github.io/mailcow-dockerized-docs/firststeps-ssl/)
