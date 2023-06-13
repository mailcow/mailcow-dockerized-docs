!!! warning "Wichtig"
    Lesen Sie zuerst [die Übersicht](r_p.md).

Erforderliche Module:
```
a2enmod rewrite proxy proxy_http headers ssl
```

Let's Encrypt wird unserem Rewrite folgen, Zertifikatsanfragen in mailcow werden problemlos funktionieren.

**Die hervorgehobenen Zeilen müssen beachtet werden**.

``` apache hl_lines="2 10 11 17 22 23 24 25 30 31"
<VirtualHost *:80>
  ServerName ZU MAILCOW HOSTNAMEN ÄNDERN
  ServerAlias autodiscover.*
  ServerAlias autoconfig.*
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
  ServerName ZU MAILCOW HOSTNAMEN ÄNDERN
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

  SSLCertificateFile MAILCOW_ORDNER/data/assets/ssl/cert.pem
  SSLCertificateKeyFile MAILCOW_ORDNER/data/assets/ssl/key.pem

  # Wenn Sie einen HTTPS-Host als Proxy verwenden möchten:
  #SSLProxyEngine On

  # Wenn Sie einen Proxy für einen nicht vertrauenswürdigen HTTPS-Host einrichten wollen:
  #SSLProxyVerify none
  #SSLProxyCheckPeerCN off
  #SSLProxyCheckPeerName off
  #SSLProxyCheckPeerExpire off
</VirtualHost>
```
