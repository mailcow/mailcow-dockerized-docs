1\. Create a new subdirectory for rainloop and download the RainLoop installer:
```
mkdir data/web/rainloop
curl -o data/web/rainloop/installer.php -s http://repository.rainloop.net/installer.php
```

2\. Run the installert from within the PHP-FPM mailcow container:
```
docker exec -it $(docker ps -qf name=php-fpm-mailcow) php /web/rainloop/installer.php
```

3\. Login to ${MAILCOW_HOSTNAME}/rainloop/?admin` to set a password

Add and configure a new domain as you need.
