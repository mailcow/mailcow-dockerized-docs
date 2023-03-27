## MariaDB: Aria-Wiederherstellung nach Absturz

Wenn Ihr Server abgestürzt ist und MariaDB eine Fehlermeldung ähnlich `[ERROR] mysqld: Aria recovery failed. Please run aria_chk -r on all Aria tables (*.MAI) and delete all aria_log.######## files`, können Sie Folgendes versuchen, um die Datenbank in einen gesunden Zustand zu bringen:

Starten Sie den Stack und warten Sie, bis mysql-mailcow beginnt, einen Neustart zu melden. Überprüfen Sie dies, indem Sie den folgenden Befehl ausführen:

=== "docker compose (Plugin)"

    ``` bash
    docker compose ps
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose ps
    ```

Führen Sie nun die folgenden Befehle aus:

Stoppen Sie den Stack, nicht "down" ausführen
=== "docker compose (Plugin)"

    ``` bash
    docker compose stop
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose stop
    ```
Führen Sie eine Bash in dem gestoppten Container als Benutzer mysql aus

=== "docker compose (Plugin)"

    ``` bash
    docker compose run --rm --entrypoint '/bin/sh -c "gosu mysql bash"' mysql-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose run --rm --entrypoint '/bin/sh -c "gosu mysql bash"' mysql-mailcow
    ```

cd in das SQL-Datenverzeichnis
```bash
cd /var/lib/mysql
```

aria_chk ausführen
```bash
aria_chk --check --force */*.MAI
```
Löschen der aria-Logdateien
```bash
rm aria_log.*
```

Führen Sie nun einen kompletten Stack neustart durch:

=== "docker compose (Plugin)"

    ``` bash
    docker compose down
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose down
    docker-compose up -d
    ```