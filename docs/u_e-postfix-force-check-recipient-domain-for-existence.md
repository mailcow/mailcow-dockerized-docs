Open `data/conf/postfix/main.cf` and add `reject_unverified_recipient` to ```smtpd_recipient_restrictions```. For example:

```
smtpd_recipient_restrictions = permit_sasl_authenticated, permit_mynetworks, check_recipient_access proxy:mysql:/opt/postfix/conf/sql/mysql_tls_enforce_in_policy.cf, reject_invalid_helo_hostname, reject_unknown_reverse_client_hostname, reject_unauth_destination, reject_unverified_recipient
```

Restart Postfix:

```
docker-compose restart postfix-mailcow
```
