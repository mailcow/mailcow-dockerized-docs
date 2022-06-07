## Run a manual mysql_upgrade

This step is usually not necessary. 

```
docker compose stop mysql-mailcow watchdog-mailcow
docker compose run --rm --entrypoint '/bin/sh -c "gosu mysql mysqld --skip-grant-tables & sleep 10 && bash && exit 0"' mysql-mailcow
```

As soon as the SQL shell spawned, run `mysql_upgrade` and exit the container:

```
mysql_upgrade
exit
```