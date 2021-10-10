## MariaDB: Aria recovery after crash

If your server crashed and MariaDB logs an error similar to `[ERROR] mysqld: Aria recovery failed. Please run aria_chk -r on all Aria tables (*.MAI) and delete all aria_log.######## files` you may want to try the following to recover the database to a healthy state:

Start the stack and wait until mysql-mailcow begins to report a restarting state. Check by running `docker-compose ps`.

Now run the following commands:

```
# Stop the stack, don't run "down"
docker-compose stop
# Run a bash in the stopped container as user mysql
docker-compose run --rm --entrypoint '/bin/sh -c "gosu mysql bash"' mysql-mailcow
# cd to the SQL data directory
cd /var/lib/mysql
# Run aria_chk
aria_chk --check --force */*.MAI
# Delete aria log files
rm aria_log.*
```

Now run `docker-compose down` followed by `docker-compose up -d`.
