Watchdog uses default values for all thresholds defined in `docker-compose.yml`.

The default values will work for most setups.
Example:
```
- NGINX_THRESHOLD=${NGINX_THRESHOLD:-5}
- UNBOUND_THRESHOLD=${UNBOUND_THRESHOLD:-5}
- REDIS_THRESHOLD=${REDIS_THRESHOLD:-5}
- MYSQL_THRESHOLD=${MYSQL_THRESHOLD:-5}
- MYSQL_REPLICATION_THRESHOLD=${MYSQL_REPLICATION_THRESHOLD:-1}
- SOGO_THRESHOLD=${SOGO_THRESHOLD:-3}
- POSTFIX_THRESHOLD=${POSTFIX_THRESHOLD:-8}
- CLAMD_THRESHOLD=${CLAMD_THRESHOLD:-15}
- DOVECOT_THRESHOLD=${DOVECOT_THRESHOLD:-12}
- DOVECOT_REPL_THRESHOLD=${DOVECOT_REPL_THRESHOLD:-20}
- PHPFPM_THRESHOLD=${PHPFPM_THRESHOLD:-5}
- RATELIMIT_THRESHOLD=${RATELIMIT_THRESHOLD:-1}
- FAIL2BAN_THRESHOLD=${FAIL2BAN_THRESHOLD:-1}
- ACME_THRESHOLD=${ACME_THRESHOLD:-1}
- RSPAMD_THRESHOLD=${RSPAMD_THRESHOLD:-5}
- OLEFY_THRESHOLD=${OLEFY_THRESHOLD:-5}
- MAILQ_THRESHOLD=${MAILQ_THRESHOLD:-20}
- MAILQ_CRIT=${MAILQ_CRIT:-30}
```

To adjust them just add necessary threshold variables (e.g. `MAILQ_THRESHOLD=10`) to `mailcow.conf` and run `docker-compose up -d`.


### Thresholds descriptions

#### NGINX_THRESHOLD
Notifies administrators if watchdog can not establish a connection to Nginx on port 8081 and it will restart the container automatically when issues were found and the threshold has been reached.

#### UNBOUND_THRESHOLD
Notifies administrators if Unbound can not resolve/valide external domains/DNSSEC and it will restart the container automatically when issues were found and the threshold has been reached.

#### REDIS_THRESHOLD
Notifies administrators if watchdog can not establish a connection to Redis on port 6379 and it will restart the container automatically when issues were found and the threshold has been reached.

#### MYSQL_THRESHOLD
Notifies administrators if watchdog can not establish a connection to MySQL or can not query a table and it will restart the container automatically when issues were found and the threshold has been reached.

#### MYSQL_REPLICATION_THRESHOLD
Notifies administrators if the MySQL replication fails.

#### SOGO_THRESHOLD
Notifies administrators if watchdog can not establish a connection to SOGo on port 20000 and it will restart the container automatically when issues were found and the threshold has been reached.

#### POSTFIX_THRESHOLD
Notifies administrators if watchdog can not sent a test mail via port 589 and it will restart the container automatically when issues were found and the threshold has been reached.

#### CLAMD_THRESHOLD
Notifies administrators if watchdog can not establish a connection to Clamd and it will restart the container automatically when issues were found and the threshold has been reached.

#### DOVECOT_THRESHOLD
Notifies administrators if watchdog fails with various tests with Dovecot container and it will restart the container automatically when issues were found and the threshold has been reached.

#### DOVECOT_REPL_THRESHOLD
Notifies administrators if the Dovecot replication fails.

#### PHPFPM_THRESHOLD
Notifies administrators if watchdog can not establish a connection to PHP-FPM on port 9001/9002 and it will restart the container automatically when issues were found and the threshold has been reached.

#### RATELIMIT_THRESHOLD
Notifies administrators if a ratelimit got hit.

#### FAIL2BAN_THRESHOLD
Notifies administrators if a fail2ban banned an IP.

#### ACME_THRESHOLD
Notifies administrators if something is wrong with the acme-mailcow container. You may check its logs.

#### RSPAMD_THRESHOLD
Notifies administrators if watchdog fails with various tests with Rspamd container and it will restart the container automatically when issues were found and the threshold has been reached.

#### OLEFY_THRESHOLD
Notifies administrators if watchdog can not establish a connection to olefy on port 10005 and it will restart the container automatically when issues were found and the threshold has been reached.

#### MAILQ_CRIT and MAILQ_THRESHOLD
Notifies administrators if number of emails in the postfix queue is greater then `MAILQ_CRIT` for period of `MAILQ_THRESHOLD * (60±30)` seconds.
