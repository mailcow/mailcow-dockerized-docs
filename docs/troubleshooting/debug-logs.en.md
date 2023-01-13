!!! warning
    This section only applies for Dockers default logging driver (JSON).

To view the logs of all mailcow: dockerized related containers, you can use the following command inside your mailcow-dockerized folder that contains your `mailcow.conf`. 

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose logs
    ```

This is usually a bit much, but you could trim the output with `--tail=100` to the last 100 lines per container, or add a `-f` to follow the live output of all your services.

To view the logs of a specific service you can use the following:

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs [options] $service_name
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose logs [options] $service_name
    ```

!!! info
    The available options for the previous commands are:

    - **--no-color**: Produce monochrome output.
    - **-f**: Follow the log output.
    - **-t**: Show timestamps.
    - **--tail="all"**: Number of lines to show from the end of the logs for each container.