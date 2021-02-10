In order to enable Portainer, the docker-compose.yml and site.conf for Nginx must be modified.

1\. Create a new file `docker-compose.override.yml` in the mailcow-dockerized root folder and insert the following configuration
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
2a\. Create `data/conf/nginx/portainer.conf`:
```
upstream portainer {
  server portainer-mailcow:9000;
}

map $http_upgrade $connection_upgrade {
  default upgrade;
  '' close;
}
```

2b\. Insert a new location to the default mailcow site by creating the file `data/conf/nginx/site.portainer.custom`:
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

3\. Apply your changes:
```
docker-compose up -d && docker-compose restart nginx-mailcow
```

Now you can simply navigate to https://${MAILCOW_HOSTNAME}/portainer/ to view your Portainer container monitoring page. You’ll then be prompted to specify a new password for the **admin** account. After specifying your password, you’ll then be able to connect to the Portainer UI.
