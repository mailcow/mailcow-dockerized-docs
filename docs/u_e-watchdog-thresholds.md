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

## Thresholds description

### MAILQ_CRIT and MAILQ_THRESHOLD

Notificaty administrators if number of emails in the postfix queue is greater then `MAILQ_CRIT` for periond of `MAILQ_THRESHOLD * (60±30)` seconds.
