## Der "neue" Weg

!!! warning
    Neuere Docker-Versionen scheinen sich über bestehende Volumes zu beschweren. Man kann dies vorübergehend beheben, indem man das bestehende Volume entfernt und mailcow mit der Override-Datei startet. Aber es scheint nach einem Neustart problematisch zu sein (muss bestätigt werden).

Ein einfacher, schmutziger, aber stabiler Workaround ist es, mailcow zu stoppen (`docker compose down`), `/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data` zu entfernen und einen neuen Link zu Ihrem entfernten Dateisystem zu erstellen, zum Beispiel:

```
mv /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data_backup
ln -s /mnt/volume-xy/vmail_data /var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data
```

Starten Sie anschließend mailcow.

---

## Der "alte" Weg

Wenn man einen anderen Ordner für das vmail-Volume verwenden möchte, kann man eine `docker-compose.override.yml` Datei erstellen und den folgenden Inhalt hinzufügen:

```
version: '2.1'
volumes:
  vmail-vol-1:
    driver_opts:
      type: none
      device: /data/mailcow/vmail	
      o: bind
```

### Verschieben eines bestehenden vmail-Ordners:

- Finden Sie den aktuellen vmail-Ordner anhand seines "Mountpoint"-Attributs: `docker volume inspect mailcowdockerized_vmail-vol-1`

``` hl_lines="10"
[
    {
        "CreatedAt": "2019-06-16T22:08:34+02:00",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "mailcowdockerized",
            "com.docker.compose.version": "1.23.2",
            "com.docker.compose.volume": "vmail-vol-1"
        },
        "Mountpoint": "/var/lib/docker/volumes/mailcowdockerized_vmail-vol-1/_data",
        "Name": "mailcowdockerized_vmail-vol-1",
        "Options": null,
        "Scope": "local"
    }
]
```

- Kopieren Sie den Inhalt des `Mountpoint`-Ordners an den neuen Speicherort (z.B. `/data/mailcow/vmail`) mit `cp -a`, `rsync -a` oder einem ähnlichen, nicht strikten Kopierbefehl
- Stoppen Sie mailcow durch Ausführen von `docker compose down` aus Ihrem mailcow-Stammverzeichnis (z.B. `/opt/mailcow-dockerized`)
- Erstellen Sie die Datei `docker-compose.override.yml`, bearbeiten Sie den Gerätepfad entsprechend
- Löschen Sie den aktuellen vmail-Ordner: `docker volume rm mailcowdockerized_vmail-vol-1`
- Starten Sie mailcow durch Ausführen von `docker compose up -d` aus Ihrem mailcow-Stammverzeichnis (z.B. `/opt/mailcow-dockerized`)

