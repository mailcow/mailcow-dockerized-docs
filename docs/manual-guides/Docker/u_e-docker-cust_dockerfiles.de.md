Sie müssen die Override-Datei mit den entsprechenden Build-Tags in den mailcow: dockerized Root-Ordner (d.h. `/opt/mailcow-dockerized`) kopieren:

```
cp helper-scripts/docker-compose.override.yml.d/BUILD_FLAGS/docker-compose.override.yml docker-compose.override.yml
```

Nehmen Sie Ihre Änderungen in `data/Dockerfiles/$service` vor und erstellen Sie das Image lokal:

```
docker build data/Dockerfiles/service -t mailcow/$service
```

Nun werden die geänderten Container automatisch neu erstellt:

```
docker compose up -d
```
