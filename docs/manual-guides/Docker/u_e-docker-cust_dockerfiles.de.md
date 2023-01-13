Sie müssen die Override-Datei mit den entsprechenden Build-Tags in den mailcow: dockerized Root-Ordner (d.h. `/opt/mailcow-dockerized`) kopieren:
```
cp helper-scripts/docker-compose.override.yml.d/BUILD_FLAGS/docker-compose.override.yml docker-compose.override.yml
```


Nehmen Sie Ihre Änderungen in `data/Dockerfiles/$service` vor und erstellen Sie das Image lokal:
```
docker build data/Dockerfiles/$service -t mailcow/$service:$tag
```
(Ohne persönlichen :$tag wird automatisch :latest verwendet.)


Nun muss dieser gerade erstellte Container in docker-compose.override.yml aktiviert werden, z.B.:
```
$service-mailcow:
    build: ./data/Dockerfiles/$service
    image: mailcow/$service:$tag
```


Abschliessend müssen die geänderten Container automatisch neu erstellt werden:
=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```
