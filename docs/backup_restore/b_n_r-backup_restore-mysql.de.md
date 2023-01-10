## Sicherung

=== "docker compose (Plugin)"

    ``` bash
    cd /pfad/zu/mailcow-dockerized
    source mailcow.conf
    DATE=$(date +"%Y%m%d_%H%M%S")
    docker compose exec -T mysql-mailcow mysqldump --default-character-set=utf8mb4 -u${DBUSER} -p${DBPASS} ${DBNAME} > backup_${DBNAME}_${DATE}.sql
    ```

=== "docker-compose (Standalone)"

    ``` bash
    cd /pfad/zu/mailcow-dockerized
    source mailcow.conf
    DATE=$(date +"%Y%m%d_%H%M%S")
    docker-compose exec -T mysql-mailcow mysqldump --default-character-set=utf8mb4 -u${DBUSER} -p${DBPASS} ${DBNAME} > backup_${DBNAME}_${DATE}.sql
    ```

## Wiederherstellen

!!! warning "Warnung"
    === "docker compose (Plugin)"
        Sie sollten den SQL-Dump ohne `docker compose` umleiten, um Parsing-Fehler zu vermeiden.

    === "docker-compose (Standalone)"

        Sie sollten den SQL-Dump ohne `docker-compose` umleiten, um Parsing-Fehler zu vermeiden.

``` bash
cd /pfad/zu/mailcow-dockerized
source mailcow.conf
docker exec -i $(docker compose ps -q mysql-mailcow) mysql -u${DBUSER} -p${DBPASS} ${DBNAME} < backup_file.sql
```
