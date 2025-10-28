!!! warning "Important"
    First read [the overview](r_p.md).

**Special Notes for HTTP/3:**
When using HTTP/3 with Nginx as a Reverse Proxy for Mailcow, additional configurations must be observed to avoid issues with SOGo redirects.

Let's Encrypt will follow our rewrite, certificate requests will work fine.

**Take care of highlighted lines.**

``` hl_lines="4 19 21 22 34 48"
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.* autoconfig.*;
  return 301 https://$host$request_uri;
}
server {
  listen 443 ssl;
  listen [::]:443 ssl;

  # For HTTP/3 on UDP 443
  # Ensure to use "reuseport" in only one server block, e.g., only in the "default_server" block, if there are other server blocks.
  #listen 443 quic reuseport;
  #listen [::]:443 quic reuseport;
  #add_header Alt-Svc 'h3=":443"' always;

  http2 on;

  server_name CHANGE_TO_MAILCOW_HOSTNAME autodiscover.* autoconfig.*;

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
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_connect_timeout 75;
    proxy_send_timeout 3650;
    proxy_read_timeout 3650;
    proxy_buffers 64 512k; # Needed since the 2022-04 Update for SOGo
    client_body_buffer_size 512k;
    client_max_body_size 0;
  }

  location / {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    client_max_body_size 0;
  # The following Proxy Buffers has to be set if you want to use SOGo after the 2022-04 (April 2022) Update
  # Otherwise a Login will fail like this: https://github.com/mailcow/mailcow-dockerized/issues/4537
	proxy_buffer_size 128k;
    proxy_buffers 64 512k;
    proxy_busy_buffers_size 512k;
  }
}
```
When using a proxy on a different subnet you will need to add the following environment variable to the mailcow.conf to have the nginx container accept the X-Real-IP set above.
```
TRUSTED_PROXIES=#.#.#.#
```