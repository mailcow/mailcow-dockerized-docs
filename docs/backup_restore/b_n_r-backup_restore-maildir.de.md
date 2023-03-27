### Sicherung

Diese Zeile sichert das vmail-Verzeichnis in eine Datei backup_vmail.tar.gz im mailcow-Root-Verzeichnis:

=== "docker compose (Plugin)"

    ``` bash
    cd /pfad/zu/mailcow-dockerized
    docker run --rm -i -v $(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/vmail" }}{{ .Name }}{{ end }}{{ end }}' $(docker compose ps -q dovecot-mailcow)):/vmail -v ${PWD}:/backup debian:bullseye-slim tar cvfz /backup/backup_vmail.tar.gz /vmail
    ```

=== "docker-compose (Standalone)"

    ``` bash
    cd /pfad/zu/mailcow-dockerized
    docker run --rm -i -v $(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/vmail" }}{{ .Name }}{{ end }}{{ end }}' $(docker-compose ps -q dovecot-mailcow)):/vmail -v ${PWD}:/backup debian:bullseye-slim tar cvfz /backup/backup_vmail.tar.gz /vmail
    ```

Sie können den Pfad ändern, indem Sie ${PWD} (das dem aktuellen Verzeichnis entspricht) zu einem beliebigen Pfad ändern, auf den Sie Schreibzugriff haben.
Setzen Sie den Dateinamen `backup_vmail.tar.gz` auf einen beliebigen Namen, aber lassen Sie den Pfad so wie er ist. Beispiel: `[...] tar cvfz /backup/mein_eigener_dateiname_.tar.gz`

### Wiederherstellen

=== "docker compose (Plugin)"

    ``` bash
    cd /pfad/zu/mailcow-dockerized
    docker run --rm -it -v $(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/vmail" }}{{ .Name }}{{ end }}{{ end }}' $(docker compose ps -q dovecot-mailcow)):/vmail -v ${PWD}:/backup debian:bullseye-slim tar xvfz /backup/backup_vmail.tar.gz
    ```

=== "docker-compose (Standalone)"

    ``` bash
    cd /pfad/zu/mailcow-dockerized
    docker run --rm -it -v $(docker inspect --format '{{ range .Mounts }}{{ if eq .Destination "/var/vmail" }}{{ .Name }}{{ end }}{{ end }}' $(docker-compose ps -q dovecot-mailcow)):/vmail -v ${PWD}:/backup debian:bullseye-slim tar xvfz /backup/backup_vmail.tar.gz
    ```