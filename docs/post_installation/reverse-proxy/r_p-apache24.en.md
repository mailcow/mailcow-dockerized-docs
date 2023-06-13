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
