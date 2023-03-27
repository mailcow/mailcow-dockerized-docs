## MariaDB: Aria recovery after crash

If your server crashed and MariaDB logs an error similar to `[ERROR] mysqld: Aria recovery failed. Please run aria_chk -r on all Aria tables (*.MAI) and delete all aria_log.######## files` you may want to try the following to recover the database to a healthy state:

Start the stack and wait until mysql-mailcow begins to report a restart. Check this with the following command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose ps
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose ps
    ```

Now exec the following commands:

Stop the stack, don't run "down"
=== "docker compose (Plugin)"

    ``` bash
    docker compose stop
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose stop
    ```
Run a bash in the stopped container as user mysql

=== "docker compose (Plugin)"

    ``` bash
    docker compose run --rm --entrypoint '/bin/sh -c "gosu mysql bash"' mysql-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose run --rm --entrypoint '/bin/sh -c "gosu mysql bash"' mysql-mailcow
    ```

cd to the SQL data directory

```bash
cd /var/lib/mysql
```

Run aria_chk

```bash
aria_chk --check --force */*.MAI
```

Delete aria log files

```bash
rm aria_log.*
```

Execute a complete stack restart using the following commands:

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