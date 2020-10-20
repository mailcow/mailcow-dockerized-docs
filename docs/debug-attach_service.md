## Attaching a Container to your Shell

To attach a container to your shell you can simply run

```
docker-compose exec $Service_Name /bin/bash
```

### Connecting to Services

If you want to connect to a service / application directly it is always a good idea to `source mailcow.conf` to get all relevant variables into your environment.

#### MySQL

```
source mailcow.conf
docker-compose exec mysql-mailcow mysql -u${DBUSER} -p${DBPASS} ${DBNAME}
```

#### Redis

```
docker-compose exec redis-mailcow redis-cli
```

## Service Descriptions

Here is a brief overview of what container / service does what:

| Service Name      | Service Descriptions                                                      |
| ----------------- | ------------------------------------------------------------------------- |
| unbound-mailcow   | Local (DNSSEC) DNS Resolver                                               |
| mysql-mailcow     | Stores SOGo's and most of mailcow's settings                              |
| postfix-mailcow   | Receives and sends mails                                                  |
| dovecot-mailcow   | User logins and sieve filter                                              |
| redis-mailcow     | Storage back-end for DKIM keys and Rspamd                                 |
| rspamd-mailcow    | Mail filtering system. Used for av handling, dkim signing, spam handling  |
| clamd-mailcow     | Scans attachments for viruses                                             |
| olefy-mailcow     | Scans attached office documents for macro-viruses                         |
| solr-mailcow      | Provides full-text search in Dovecot                                      |
| sogo-mailcow      | Webmail client that handles Microsoft ActiveSync and Cal- / CardDav       |
| nginx-mailcow     | Nginx remote proxy that handles all mailcow related HTTP / HTTPS requests |
| acme-mailcow      | Automates HTTPS (SSL/TLS) certificate deployment                          |
| memcached-mailcow | Internal caching system for mailcow services                              |
| watchdog-mailcow  | Allows the monitoring of docker containers / services                     |
| php-fpm-mailcow   | Powers the mailcow web UI                                                 |
| netfilter-mailcow | Fail2Ban like integration                                                 |
