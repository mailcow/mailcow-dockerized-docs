Insert these lines to `data/conf/postfix/main.cf`. "relayhost" does already exist (empty), just change its value.
```
relayhost = [your-relayhost]:587
smtp_sasl_password_maps = hash:/opt/postfix/conf/smarthost_passwd
smtp_sasl_auth_enable = yes
```

Create the credentials file:
```
echo "your-relayhost username:password" > data/conf/postfix/smarthost_passwd
```

Run:
```
docker-compose exec postfix-mailcow postmap /opt/postfix/conf/smarthost_passwd
docker-compose exec postfix-mailcow chown root:postfix /opt/postfix/conf/smarthost_passwd /opt/postfix/conf/smarthost_passwd.db
docker-compose exec postfix-mailcow chmod 660 /opt/postfix/conf/smarthost_passwd /opt/postfix/conf/smarthost_passwd.db
docker-compose exec postfix-mailcow postfix reload
```

### Helper script

There is a helper script `mailcow-setup-relayhost.sh` you can run to setup a relayhost.

``` bash
Usage:

Setup a relayhost:
./mailcow-setup-relayhost.sh relayhost port (username) (password)
Username and password are optional parameters.

Reset to defaults:
./mailcow-setup-relayhost.sh reset
```
