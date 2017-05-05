You can use `docker-compose logs $service-name` for all containers.

Run `docker-compose logs` for all logs at once.

Follow the log output by running docker-compose with `logs -f`.

Limit the output by calling logs with `--tail=300` like `docker-compose logs --tail=300 mysql-mailcow`.
