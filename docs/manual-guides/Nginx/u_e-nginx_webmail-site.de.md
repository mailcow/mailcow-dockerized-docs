**WICHTIG**: Diese Anleitung gilt nur für Konfigurationen, bei denen SNI nicht aktiviert ist. Wenn SNI aktiviert ist, muss der Zertifikatspfad angepasst werden. Etwas wie `ssl_certificate,key /etc/ssl/mail/webmail.example.org/cert.pem,key.pem;` wird genügen. **Aber**: Das Zertifikat sollte **zuerst** bezogen werden und erst wenn das Zertifikat existiert, sollte eine Site Config erstellt werden. Nginx wird nicht starten, wenn es das Zertifikat und den Schlüssel nicht finden kann.

Um eine Subdomain `webmail.example.org` zu erstellen und sie auf SOGo umzuleiten, müssen Sie eine **neue** Nginx-Site erstellen. Achten Sie dabei auf "CHANGE_TO_MAILCOW_HOSTNAME"!

**nano data/conf/nginx/webmail.conf**

``` hl_lines="9 17"
server {
  ssl_certificate /etc/ssl/mail/cert.pem;
  ssl_certificate_key /etc/ssl/mail/key.pem;
  index index.php index.html;
  client_max_body_size 0;
  root /web;
  include /etc/nginx/conf.d/listen_plain.active;
  include /etc/nginx/conf.d/listen_ssl.active;
  server_name webmail.example.org;
  server_tokens off;
  location ^~ /.well-known/acme-challenge/ {
    allow all;
    default_type "text/plain";
  }

  location / {
    return 301 https://CHANGE_TO_MAILCOW_HOSTNAME/SOGo;
  }
}
```

Speichern Sie und starten Sie Nginx neu: 

=== "docker compose (Plugin)"

    ``` bash
	docker compose restart nginx-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose restart nginx-mailcow
    ```

Öffnen Sie nun `mailcow.conf` und suchen Sie `ADDITIONAL_SAN`.
Fügen Sie `webmail.example.org` zu diesem Array hinzu, verwenden Sie keine Anführungszeichen!

```
ADDITIONAL_SAN=webmail.example.org
```

Führen Sie den Befehl aus:

=== "docker compose (Plugin)"

    ``` bash
	docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose up -d
    ```

Siehe "acme-mailcow" und "nginx-mailcow" Logs, wenn etwas fehlschlägt