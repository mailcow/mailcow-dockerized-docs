Mailman is a system to manage email lists with a web UI.
The following guide uses the docker-compose implementation from [maxking](https://github.com/maxking/docker-mailman) depends on postgres database with [mailman-core](https://github.com/maxking/docker-mailman/tree/master/core) and [mailman-web](https://github.com/maxking/docker-mailman/tree/master/web).

!!! info
	This is not officially maintained nor supported by the mailcow project nor its contributors. No warranty or support is being provided, however you're free to open issues on GitHub for filing a bug or provide further ideas. [GitHub repo can be found here](https://github.com/pgollor/mailman-mailcow-integration).
	The following description works for my own server and other servers are managed by me, but it is possible it won't work for you. Therefore you have to check it agian after every update.

## Install

Copy all files from the [repository](https://github.com/pgollor/mailman-mailcow-integration) into your mailcow root directory.
!!! warning
	Do not copy `docker-compose.override.yml` and `data/cond/postfix/extra.cf` if you already have these files. You need to merge the content.
Run `mailman-install.sh` and answer the questions. After that some configs will be add to your `mailcow.conf`.

### Change settings

By default archiving is disabled and the default language in `data/mailman/core/mailman-extra.cfg` and `data/mailman/web/settings_local.py` have to be changed.
For further information

### Webserver vhost

Add a virtual host to your webserver. Here is a apache2 example:
```
<VirtualHost *:443>
  ServerName list.example.com
  ServerAdmin admin@example.com

  SSLEngine On
  SSLCertificateFile /etc/letsencrypt/live/example.com/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
  Include /etc/letsencrypt/options-ssl-apache.conf

  SSLProxyEngine On
  ProxyRequests Off
  ProxyPreserveHost On

  <Location />
    ProxyPass uwsgi://127.0.0.1:8080/
  </Location>
  ProxyPassReverse / uwsgi://127.0.0.1:8080/

  #<Location /hyperkitty/>
  #  order deny,allow
  #  deny from all
  #</Location>

  #<Location /accounts/signup/>
  #  order deny,allow
  #  deny from all
  #</Location>

  Alias /static /opt/mailcow-dockerized/data/mailman/web/static
  Alias /favicon.ico /opt/mailcow-dockerized/data/mailman/web/static/hyperkitty/img/favicon.ico
  <Directory "/opt/mailcow-dockerized/data/mailman/web/static/">
    order deny,allow
    allow from all
    Require all granted
  </Directory>
  ProxyPassMatch ^/static/ !

  CustomLog ${APACHE_LOG_DIR}/mailman-access.log combined
  ErrorLog ${APACHE_LOG_DIR}/mailman-error.log
</VirtualHost>
```

#### Please aware off

- you need to enable the `uwsgi` module.
- `ServerName` must match `MAILMAN_SERVE_FROM_DOMAIN` in the `docker-compose.override.yml` file.
- you need a valid certificate for your given server name
- change static file location to your mailcow installation


## Backup

!!! warning
	The mailcow backup and restore scripts will do not backup mailman data!

Try to use `mailman-backup.sh` as backup for mailman data and database.

## Help

- [Mailman docker help](https://asynchronous.in/docker-mailman/)
- [Mailman 3 help](https://docs.mailman3.org)

## ToDo

- integrate into mailcow nginx
