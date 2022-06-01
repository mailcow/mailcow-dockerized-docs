You need to copy the override file with corresponding build tags to the mailcow: dockerized root folder (i.e. `/opt/mailcow-dockerized`):

```
cp helper-scripts/docker-compose.override.yml.d/BUILD_FLAGS/docker-compose.override.yml docker-compose.override.yml
```

Make your changes in `data/Dockerfiles/$service` and build the image locally:

```
docker build data/Dockerfiles/service -t mailcow/$service
```

Now auto-recreate modified containers:

```
docker-compose up -d
```