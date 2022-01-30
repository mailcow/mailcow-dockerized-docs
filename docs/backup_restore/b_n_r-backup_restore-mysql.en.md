## Backup

```
cd /path/to/mailcow-dockerized
source mailcow.conf
DATE=$(date +"%Y%m%d_%H%M%S")
docker-compose exec -T mysql-mailcow mysqldump --default-character-set=utf8mb4 -u${DBUSER} -p${DBPASS} ${DBNAME} > backup_${DBNAME}_${DATE}.sql
```

## Restore

!!! warning
    You should redirect the SQL dump without `docker-compose` to prevent parsing errors.

```
cd /path/to/mailcow-dockerized
source mailcow.conf
docker exec -i $(docker-compose ps -q mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} < backup_file.sql
```