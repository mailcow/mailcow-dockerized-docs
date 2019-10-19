The following setting can be useful when having a relay domain and not every user of that user domain has a extra user created on mailcow site.
The problem without this setting is more specified in https://github.com/mailcow/mailcow-dockerized/issues/2981

Open `data/conf/postfix/main.cf` and add `reject_unverified_recipient` to ```smtpd_recipient_restrictions```. For example:

```
smtpd_recipient_restrictions = permit_sasl_authenticated, [...], reject_unauth_destination, reject_unverified_recipient
```

Restart Postfix:

```
docker-compose restart postfix-mailcow
```
