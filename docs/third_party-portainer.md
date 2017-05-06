In order to enable Portainer, the docker-compose.yml and site.conf for nginx must be modified.

1\. docker-compose.yml: Insert this block for portainer
```
    portainer-mailcow:
      image: portainer/portainer
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
      restart: always
      dns:
        - 172.22.1.254
      dns_search: mailcow-network
      networks:
        mailcow-network:
          aliases:
            - portainer
```
2a\. data/conf/nginx/site.conf: Just beneath the opening line, at the same level as a server { block, add this:
```
upstream portainer {
  server portainer-mailcow:9000;
}

map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}
```

2b\. data/conf/nginx/site.conf: Then, inside **both** (ssl and plain) server blocks, add this:
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

Now you can simply navigate to https://${MAILCOW_HOSTNAME}/portainer/ to view your Portainer container monitoring page. You’ll then be prompted to specify a new password for the **admin** account. After specifying your password, you’ll then be able to connect to the Portainer UI.
