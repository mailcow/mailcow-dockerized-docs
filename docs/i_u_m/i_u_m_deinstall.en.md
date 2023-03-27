To remove mailcow: dockerized with all it's volumes, images and containers do:
=== "docker compose (Plugin)"

    ``` bash
    docker compose down -v --rmi all --remove-orphans
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose down -v --rmi all --remove-orphans
    ```

!!! info
    - **-v** Remove named volumes declared in the `volumes` section of the Compose file and anonymous volumes attached to containers.
    - **--rmi <type>** Remove images. Type must be one of: `all`: Remove all images used by any service. `local`: Remove only images that don't have a custom tag set by the `image` field.
    - **--remove-orphans** Remove containers for services not defined in the compose file.
    - By default `docker compose down` only removes currently active containers and networks defined in the `docker-compose.yml`.
