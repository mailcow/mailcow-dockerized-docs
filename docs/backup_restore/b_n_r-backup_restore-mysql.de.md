## Sicherung

```
cd /pfad/zu/mailcow-dockerized
source mailcow.conf
DATE=$(Datum +"%Y%m%d_%H%M%S")
docker compose exec -T mysql-mailcow mysqldump --default-character-set=utf8mb4 -u${DBUSER} -p${DBPASS} ${DBNAME} > backup_${DBNAME}_${DATE}.sql
```

## Wiederherstellen

!!! warning
    Sie sollten den SQL-Dump ohne `docker compose` umleiten, um Parsing-Fehler zu vermeiden.

```
cd /pfad/zu/mailcow-dockerized
source mailcow.conf
docker exec -i $(docker compose ps -q mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} < backup_file.sql
```
