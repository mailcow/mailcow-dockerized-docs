## Führen Sie ein manuelles mysql_upgrade durch.

Dieser Schritt ist normalerweise nicht notwendig. 

```
docker compose stop mysql-mailcow watchdog-mailcow
docker compose run --rm --entrypoint '/bin/sh -c "gosu mysql mysqld --skip-grant-tables & sleep 10 && bash && exit 0"' mysql-mailcow
```

Sobald die SQL-Shell gestartet wurde, führen Sie `mysql_upgrade` aus und verlassen den Container:

```
mysql_upgrade
exit
```
