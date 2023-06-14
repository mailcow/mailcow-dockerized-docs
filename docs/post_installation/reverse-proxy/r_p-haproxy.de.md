!!! warning "Wichtig"
    Lesen Sie zuerst [die Übersicht](r_p.md).

!!! warning "Warnung"
    Dies ist ein nicht unterstützter Community Beitrag. Korrekturen sind immer erwünscht!

**Wichtig/Fix erwünscht**: Dieses Beispiel leitet nur HTTPS-Verkehr weiter und benutzt nicht den in mailcow eingebauten ACME-Client.

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
