By default, mailcow expects the username for authentication to include the realm (domain name). To allow for ease of migration from a platform that does not use the realm, you can set a default realm. Dovecot will append this domain to any username that does not have a realm supplied. 

To change this default, you need to make changes in the data/conf/dovecot/extra.cf:

``` data/conf/dovecot/extra.cf
auth_default_realm = schwetz.com.au
```
Following this change, you will need to restart the dovecot container:

``` shell
docker-compose restart dovecot-mailcow
```

!!! Note
Authentication with SOGo will still require the e-mail address