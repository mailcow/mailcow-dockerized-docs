Create folder for RainLoop in `mailcow-dockerized/data/web` 
Download installer.php and run it from php docker container. 
Remove installer.php
Login servername/rainloop/?admin
Change password from 12345
```
cd data/web
mkdir rainloop
cd rainloop
curl -s http://repository.rainloop.net/installer.php >> installer.php
# run php file from php docker image, which should be already running along others. 
# your container name might be different from mailcowdockerized_php-fpm-mailcow_1 -
# use `docker ps` to find out

docker exec -it mailcowdockerized_php-fpm-mailcow_1 php /web/rainloop/installer.php

       [RainLoop Webmail Installer]


 * Connecting to repository ...
 * Downloading package ...
 * Complete downloading!
 * Installing package ...
 * Complete installing!

 * [Success] Installation is finished!

rm installer.php
```

**login servername/rainloop/?admin to changepassword** and setup connection to mailcow

In domain section add desired domain
IMAP dovecot
SMTP postfix
Secure STARTTSL on both
