### Nginx

Let's Encrypt folgt unserem Rewrite, Zertifikatsanfragen funktionieren problemlos.

**Achten Sie auf die hervorgehobenen Zeilen**.

``` hl_lines="4 10 12 13 25 39"
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name ZU MAILCOW HOSTNAMEN ÄNDERN autodiscover.* autoconfig.*;
  return 301 https://$host$request_uri;
}
server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name ZU MAILCOW HOSTNAMEN ÄNDERN autodiscover.* autoconfig.*;

  ssl_certificate MAILCOW_PATH/data/assets/ssl/cert.pem;
  ssl_certificate_key MAILCOW_PATH/data/assets/ssl/key.pem;
  ssl_session_timeout 1d;
  ssl_session_cache shared:SSL:50m;
  ssl_session_tickets off;

  # Siehe https://ssl-config.mozilla.org/#server=nginx für die neuesten Empfehlungen zu ssl-Einstellungen
  # Ein Beispiel für eine Konfiguration ist unten angegeben
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
    proxy_buffers 64 512k; # Seit dem 2022-04 Update nötig für SOGo
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
  # Die folgenden Proxy-Buffer müssen gesetzt werden, wenn Sie SOGo nach dem Update 2022-04 (April 2022) verwenden wollen
  # Andernfalls wird ein Login wie folgt fehlschlagen: https://github.com/mailcow/mailcow-dockerized/issues/4537
	proxy_buffer_size 128k;
    proxy_buffers 64 512k;
    proxy_busy_buffers_size 512k;
  }
}
```
