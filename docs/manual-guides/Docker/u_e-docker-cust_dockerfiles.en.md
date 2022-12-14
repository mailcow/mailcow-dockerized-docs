You need to copy the override file with corresponding build tags to the mailcow: dockerized root folder (i.e. `/opt/mailcow-dockerized`):

```
cp helper-scripts/docker-compose.override.yml.d/BUILD_FLAGS/docker-compose.override.yml docker-compose.override.yml
```


Customize `data/Dockerfiles/$service` and build the image locally:
```
docker build data/Dockerfiles/$service -t mailcow/$service:$tag
```
(without a personalized :$tag docker will use :latest automatically)


Now the created image has to be activated in docker-compose.override.yml, e.g.:
```
$service-mailcow:
    build: ./data/Dockerfiles/$service
    image: mailcow/$service:$tag
```

Now auto-recreate modified containers:
=== "docker compose"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose"

    ``` bash
    docker-compose up -d
    ```
