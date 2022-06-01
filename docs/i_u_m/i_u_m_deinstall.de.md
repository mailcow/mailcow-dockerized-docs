Um mailcow: dockerized mit all seinen Volumes, Images und Containern zu entfernen, tun Sie dies:

```
docker-compose down -v --rmi all --remove-orphans
```

!!! info
    - **-v** Entfernt benannte Volumes, die im Abschnitt `volumes` der Compose-Datei deklariert sind, und anonyme Volumes, die an Container angehängt sind.
    - **--rmi <Typ>** Images entfernen. Der Typ muss einer der folgenden sein: `all`: Entfernt alle Images, die von einem beliebigen Dienst verwendet werden. `local`: Entfernt nur Bilder, die kein benutzerdefiniertes Tag haben, das durch das Feld "image" gesetzt wurde.
    - **--remove-orphans** Entfernt Container für Dienste, die nicht in der Compose-Datei definiert sind.
    - Standardmäßig entfernt `docker-compose down` nur derzeit aktive Container und Netzwerke, die in der Datei `docker-compose.yml` definiert sind.