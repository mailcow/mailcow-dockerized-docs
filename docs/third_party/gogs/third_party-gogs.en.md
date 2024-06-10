With Gogs' ability to authenticate over SMTP it is trivial to integrate it with mailcow. Few changes are needed:

1\. In order to create a database for Gogs, connect to your shell and execute the following commands:
```
source mailcow.conf
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE gogs;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'gogs'@'%' IDENTIFIED BY 'your_strong_password';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON gogs.* TO 'gogs'@'%';
```

2\. Open `docker-compose.override.yml` and add Gogs:

```yaml
services:

    gogs-mailcow:
      image: gogs/gogs
      volumes:
        - ./data/gogs:/data
      networks:
        mailcow-network:
          aliases:
            - gogs
      ports:
        - "${GOGS_SSH_PORT:-127.0.0.1:4000}:22"
```

3\. Create `data/conf/nginx/site.gogs.custom`, add:
```
location /gogs/ {
    proxy_pass http://gogs:3000/;
}
```

4\. Open `mailcow.conf` and define the binding you want Gogs to use for SSH. Example:

```
GOGS_SSH_PORT=127.0.0.1:4000
```

5\. Run the commands to bring up the Gogs container and restart the nginx-mailcow container afterwards:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
	docker compose restart nginx-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
	docker-compose restart nginx-mailcow
    ```

6\. Open `http://${MAILCOW_HOSTNAME}/gogs/`, for example `http://mx.example.org/gogs/`. For database details set `mysql` as database host. Use the value gogs as database name, gogs as database user and your_strong_password you previously definied at step 1 as database password.

7\. Once the installation is complete, login as admin and set "settings" -> "authorization" -> "enable SMTP". SMTP Host should be `postfix` with port `587`, set `Skip TLS Verify` as we are using an unlisted SAN ("postfix" is most likely not part of your certificate).

8\. Create `data/gogs/gogs/conf/app.ini` and set following values. You can consult [Gogs cheat sheet](https://gogs.io/docs/advanced/configuration_cheat_sheet) for their meaning and other possible values.

```ini
[server]
SSH_LISTEN_PORT = 22
# For GOGS_SSH_PORT=127.0.0.1:4000 in mailcow.conf, set:
SSH_DOMAIN = 127.0.0.1
SSH_PORT = 4000
# For MAILCOW_HOSTNAME=mx.example.org in mailcow.conf (and default ports for HTTPS), set:
ROOT_URL = https://mx.example.org/gogs/
```

9\. Restart Gogs with the following command. Your users should be able to login with mailcow managed accounts.

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart gogs-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart gogs-mailcow
    ```
