With Gogs' ability to authenticate over SMTP it is trivial to integrate it with mailcow. Few changes are needed:

1\. Open `docker-compose.yml` and add Gogs:

```
    gogs-mailcow:
      image: gogs/gogs
      volumes:
        - ./data/gogs:/data
      networks:
        mailcow-network:
          ipv4_address: 172.22.1.123
          aliases:
            - gogs
      ports:
        - "${GOGS_SSH_PORT:-50022}:22"
        - "${GOGS_WWW_PORT:-50080}:3000"
      dns:
        - 172.22.1.254

```

2\. Open `data/conf/nginx/site.conf` and add in each `server{}` block
```
location /gogs/ {
    proxy_pass http://172.22.1.123:3000/;
}
```

3\. Open `mailcow.conf` and define ports you want Gogs to open, as well as future database password. Example:

```
GOGS_WWW_PORT=3000
GOGS_SSH_PORT=4000
DBGOGS=CorrectHorseBatteryStaple
```

4\. Create database and user for Gogs to use.

```
. ./mailcow.conf
docker-compose exec mysql-mailcow mysql -uroot -p$DBROOT
mysql> CREATE USER gogs IDENTIFIED BY 'CorrectHorseBatteryStaple';
mysql> CREATE DATABASE gogs;
mysql> GRANT ALL PRIVILEGES ON gogs.* to gogs;
```

5\. Run `docker-compose up -d` to bring up Gogs container. Verify with `curl http://172.22.1.123:3000/` that it is running.

6\. Proceed to installer from browser, for the time being using direct url `http://${MAILCOW_HOSTNAME}:${GOGS_WWW_PORT}/`, for example `http://example.org:3000/`. For database details set `172.22.1.2` as database host, user `gogs`, database name `gogs` and password as set above

7\. Once install is complete, login as admin and in settings - authorization enable SMTP. SMTP Host should be `172.22.1.8` with port `587`. You'll probably want to set `Skip TLS Verify`.

8\. Edit `data/gogs/gogs/conf/app.ini` and set following values. You can consult [Gogs cheat sheet](https://gogs.io/docs/advanced/configuration_cheat_sheet) for their meaning and other possible values.

```
[server]
SSH_LISTEN_PORT = 22
SSH_DOMAIN = [domain where ssh is available - used for ssh clone url]
SSH_PORT = [port where ssh is open on host - used for ssh clone url]
ROOT_URL = https://[url]/gogs/
```

9\. Restart Gogs with `docker-compose restart gogs-mailcow`. Your users should be able to login with mailcow managed accounts.
