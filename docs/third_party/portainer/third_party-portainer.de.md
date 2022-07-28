Um Portainer zu aktivieren, müssen die docker-compose.yml und site.conf für Nginx geändert werden.

1\. Erstellen Sie eine neue Datei `docker-compose.override.yml` im mailcow-dockerized Stammverzeichnis und fügen Sie die folgende Konfiguration ein
```
version: '2.1'
services:
    portainer-mailcow:
      image: portainer/portainer-ce
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - ./data/conf/portainer:/data
      restart: always
      dns:
        - 172.22.1.254
      dns_search: mailcow-network
      networks:
        mailcow-network:
          aliases:
            - portainer
```
2a\. Erstelle `data/conf/nginx/portainer.conf`:
```
upstream portainer {
  server portainer-mailcow:9000;
}

map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}
```

2b\. Fügen Sie einen neuen Standort für die Standard-Mailcow-Site ein, indem Sie die Datei `data/conf/nginx/site.portainer.custom` erstellen:
```
  location /portainer/ {
    proxy_http_version 1.1;
    proxy_set_header Host              $http_host;   # required for docker client's sake
    proxy_set_header X-Real-IP         $remote_addr; # pass on real client's IP
    proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_read_timeout                 900;

    proxy_set_header Connection "";
    proxy_buffers 32 4k;
    proxy_pass http://portainer/;
  }

  location /portainer/api/websocket/ {
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_pass http://portainer/api/websocket/;
  }
```

3\. Übernehmen Sie Ihre Änderungen:
```
docker compose up -d && docker compose restart nginx-mailcow
```

Nun können Sie einfach zu https://${MAILCOW_HOSTNAME}/portainer/ navigieren, um Ihre Portainer-Container-Überwachungsseite anzuzeigen. Sie werden dann aufgefordert, ein neues Passwort für den **admin** Account anzugeben. Nachdem Sie Ihr Passwort eingegeben haben, können Sie sich mit der Portainer UI verbinden.
