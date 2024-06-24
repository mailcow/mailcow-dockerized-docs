!!! warning "Important"
    First read [the overview](r_p.md).

!!! warning
    This is an unsupported community contribution. Feel free to provide fixes.

This example redirects all HTTP traffic to HTTPS except for mailcow's built-in ACME client.
If you do not want to use the built-in ACME client, please modify the configuration yourself.

```
frontend https-in
  bind :::80 v4v6
  bind :::443 v4v6 ssl crt mailcow.pem

  acl mailcow_acme path -i -m beg /.well-known/

  redirect scheme https unless { ssl_fc || mailcow_acme }

  default_backend mailcow

backend mailcow
  option forwardfor
  http-request set-header X-Forwarded-Proto https if { ssl_fc }
  http-request set-header X-Forwarded-Proto http if !{ ssl_fc }
  server mailcow 127.0.0.1:8080 check
```
