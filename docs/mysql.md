MySQL is used to store the settings and / or usertables of the whole mail-stack (mailcow UI, SOGo, dovecot, postfix).

## Backup

```
cd /path/to/mailcow-dockerized
source mailcow.conf
DATE=$(date +"%Y%m%d_%H%M%S")
docker-compose exec mysql-mailcow mysqldump --default-character-set=utf8mb4 -u${DBUSER} -p${DBPASS} ${DBNAME} > backup_${DBNAME}_${DATE}.sql
```

## Restore

You should redirect the sql dump without Docker-Compose to prevent parsing errors.

```
cd /path/to/mailcow-dockerized
source mailcow.conf
docker exec -i $(docker-compose ps -q mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} < backup_file.sql
```
