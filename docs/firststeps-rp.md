You don't need to change the Nginx site that comes with mailcow: dockerized.
mailcow: dockerized trusts the default gateway IP 172.22.1.1 as proxy. This is very important to control access to Rspamd's web UI.

1\. Make sure you change HTTP_BIND and HTTPS_BIND in `mailcow.conf` to a local address and set the ports accordingly, for example:
``` bash
HTTP_BIND=127.0.0.1
HTTP_PORT=8080
HTTPS_BIND=127.0.0.1
HTTPS_PORT=8443
```
** IMPORTANT: Do not use port 8081 **

Recreate affected containers by running `docker-compose up -d`.

2\. Configure your local webserver as reverse proxy:

### Apache 2.4
``` apache
<VirtualHost *:443>
    ServerName mail.example.org
    ServerAlias autodiscover.example.org
    ServerAlias autoconfig.example.org

    [...]
    # You should proxy to a plain HTTP session to offload SSL processing
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/

    ProxyPreserveHost On
    ProxyAddHeaders On

    # This header does not need to be set when using http
    RequestHeader set X-Forwarded-Proto "https"

    your-ssl-configuration-here
    [...]

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
```
server {
    listen 443;
    server_name mail.example.org autodiscover.example.org autoconfig.example.org;

    [...]
    your-ssl-configuration-here

    location / {
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 100m;
    }
    [...]
}
```

### HAProxy
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
