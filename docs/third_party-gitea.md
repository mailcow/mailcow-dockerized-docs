With Gitea' ability to authenticate over SMTP it is trivial to integrate it with mailcow. Few changes are needed:

1\. Open `docker-compose.override.yml` and add gitea:

```
version: '2.1'
services:

		gitea-mailcow:
			image: gitea/gitea:latest
			volumes:
				- ./data/gitea:/data
			networks:
				mailcow-network:
					aliases:
						- gitea
			ports:
				- "${GITEA_SSH_PORT:-127.0.0.1:4000}:22"
```

2\. Create `data/conf/nginx/site.gitea.custom`, add:
```
location /gitea/ {
		proxy_pass http://gitea:3000/;
}
```

3\. Open `mailcow.conf` and define the binding you want gitea to use for SSH. Example:

```
GITEA_SSH_PORT=127.0.0.1:4000
```

4\. Create `data/gitea/gitea/conf/app.ini` and set following values. You can consult [gitea cheat sheet](https://docs.gitea.io/en-us/config-cheat-sheet/) for their meaning and other possible values.

```
[server]
SSH_LISTEN_PORT = 22
# For GITEA_SSH_PORT=127.0.0.1:4000 in mailcow.conf, set:
SSH_DOMAIN = 127.0.0.1
SSH_PORT = 4000
# For MAILCOW_HOSTNAME=mx.example.org in mailcow.conf (and default ports for HTTPS), set:
ROOT_URL = https://mx.example.org/gitea/
```

5\. Run `docker-compose up -d` to bring up the gitea container and run `docker-compose restart nginx-mailcow` afterwards.

6\. Open `http://${MAILCOW_HOSTNAME}/gitea/`, for example `http://mx.example.org/gitea/`. For database details set `mysql` as database host. Use the value of DBNAME found in mailcow.conf as database name, DBUSER as database user and DBPASS as database password.

7\. Once the installation is complete, login as admin and set "settings" -> "authorization" -> "enable SMTP". SMTP Host should be `postfix` with port `587`, set `Skip TLS Verify` as we are using an unlisted SAN ("postfix" is most likely not part of your certificate).

8\. Restart gitea with `docker-compose restart gitea-mailcow`. Your users should be able to login with mailcow managed accounts.