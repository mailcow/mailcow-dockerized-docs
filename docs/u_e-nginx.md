To create persistent (over updates) sites hosted by mailcow: dockerized, a new site configuration must be placed inside `data/conf/nginx/`:

```
nano data/conf/nginx/my_custom_site.conf
```

The filename is not important, as long as the filename carries a .conf extension.

It is also possible to extend the configuration of the default file `site.conf` file:

```
nano data/conf/nginx/site.my_content.custom
```

This filename does not need to have a ".conf" extension, but follows the pattern `site.*.custom`, where `*` is a custom name.

If PHP is to be included in a custom site, please use the PHP-FPM listener on phpfpm:9002 or create a new listener in `data/conf/phpfpm/php-fpm.d/pools.conf`.

Restart Nginx (and PHP-FPM, if a new listener was created):

```
docker-compose restart nginx-mailcow
docker-compose restart php-fpm-mailcow
```
