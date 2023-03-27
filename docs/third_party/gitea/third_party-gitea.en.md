With Gitea' ability to authenticate over SMTP it is trivial to integrate it with mailcow. Few changes are needed:

1\. In order to create a database for gitea, connect to your shell and execute the following commands:
```
source mailcow.conf
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE DATABASE gitea;"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "CREATE USER 'gitea'@'%' IDENTIFIED BY 'your_strong_password';"
docker exec -it $(docker ps -f name=mysql-mailcow -q) mysql -uroot -p${DBROOT} -e "GRANT ALL PRIVILEGES ON gitea.* TO 'gitea'@'%';
```

2\. Open `docker-compose.override.yml` and add gitea:

```yaml
version: '2.1'
services:

		gitea-mailcow:
			image: gitea/gitea:1
			volumes:
				- ./data/gitea:/data
			networks:
				mailcow-network:
					aliases:
						- gitea
			ports:
				- "${GITEA_SSH_PORT:-127.0.0.1:4000}:22"
```

3\. Create `data/conf/nginx/site.gitea.custom`, add:
```
location /gitea/ {
		proxy_pass http://gitea:3000/;
}
```

4\. Open `mailcow.conf` and define the binding you want gitea to use for SSH. Example:

```
GITEA_SSH_PORT=127.0.0.1:4000
```

5\. Run the commands to bring up the gitea container and restart the nginx-mailcow container afterwards:

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

6\. If you forced mailcow to https, execute step 9 and restart gitea with the following command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart gitea-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart gitea-mailcow
    ```

Go head with step 7 (Remember to use https instead of http, `https://mx.example.org/gitea/`) 

7\. Open `http://${MAILCOW_HOSTNAME}/gitea/`, for example `http://mx.example.org/gitea/`. For database details set `mysql` as database host. Use gitea as database name, gitea as database user and your_strong_password you previously definied at step 1 as database password.

8\. Once the installation is complete, login as admin and set "settings" -> "authorization" -> "enable SMTP". SMTP Host should be `postfix` with port `587`, set `Skip TLS Verify` as we are using an unlisted SAN ("postfix" is most likely not part of your certificate).

9\. Create `data/gitea/gitea/conf/app.ini` and set following values. You can consult [gitea cheat sheet](https://docs.gitea.io/en-us/config-cheat-sheet/) for their meaning and other possible values.

```ini
[server]
SSH_LISTEN_PORT = 22
# For GITEA_SSH_PORT=127.0.0.1:4000 in mailcow.conf, set:
SSH_DOMAIN = 127.0.0.1
SSH_PORT = 4000
# For MAILCOW_HOSTNAME=mx.example.org in mailcow.conf (and default ports for HTTPS), set:
ROOT_URL = https://mx.example.org/gitea/
```

10\. Restart gitea with the following command. Your users should be able to login with mailcow managed accounts.

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart gitea-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart gitea-mailcow
    ```
