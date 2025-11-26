!!! danger "Nur durchführen, wenn notwendig"
    Diese Anleitung ist nur für fortgeschrittene Benutzer gedacht, die Probleme mit SOGo beheben müssen. Das Verwenden von Nightly-Builds kann zu Instabilität führen und wird nicht für Produktionsumgebungen empfohlen.

    mailcow setzt zwar auch auf die Nightly builds, diese werden jedoch vor der Veröffentlichung getestet. Wenn Sie also keine spezifischen Probleme mit der aktuellen SOGo-Version haben, sollten Sie diese Anleitung nicht befolgen.

## Neues Docker Image bauen

Um Images zu bauen, befindet sich im mailcow Verzeichnis unter dem Ordner `helper-scripts` ein Unterordner namens `docker-compose.override.yml.d` in welchem sie einen Ordner namens `BUILD_FLAGS` finden. In diesem Ordner existiert eine `docker-compose.override.yml` Datei, welche sie wie folgt in eine `docker-compose.override.yml` Datei in ihrem mailcow Verzeichnis kopieren:

```bash
services:
  sogo-mailcow:
    build:
      context: ./data/Dockerfiles/sogo
      dockerfile: Dockerfile
```

!!! warning "Achtung, wenn bereits ein Override existiert"
    Wenn in ihrem mailcow Verzeichnis bereits eine `docker-compose.override.yml` Datei existiert, fügen sie den obigen Inhalt in diese Datei ein, anstatt eine neue Datei zu erstellen.

Anschließend können sie das SOGo Image mit folgendem Befehl im mailcow Hauptverzeichnis neu bauen:

=== "docker compose (Plugin)"

    ```bash
    docker compose build sogo-mailcow --no-cache
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose build sogo-mailcow --no-cache
    ```

## SOGo Nightly Version verwenden

Sobald das neue Image gebaut wurde, können sie den SOGo Container mit folgendem Befehl neu kreieren:

=== "docker compose (Plugin)"

    ```bash
    docker compose up -d --force-recreate sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose up -d --force-recreate sogo-mailcow
    ```

mailcow verwendet nun die neu gebaute SOGo Nightly Version.

## Zurück zur stabilen Version

Wenn sie später wieder zur stabilen SOGo Version zurückkehren möchten, löschen sie einfach die `docker-compose.override.yml` Datei in ihrem mailcow Verzeichnis und führen sie erneut diesen Befehl aus:

=== "docker compose (Plugin)"

    ```bash
    docker compose up -d --force-recreate sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ```bash
    docker-compose up -d --force-recreate sogo-mailcow
    ```

!!! warning "Wenn sie in ihrer Override-Datei weitere Anpassungen vorgenommen haben"
    Wenn sie in ihrer `docker-compose.override.yml` Datei weitere Anpassungen vorgenommen haben, entfernen Sie nur die oben genannte SOGo Konfiguration, um ihre benutzerdefinierte Konfiguration beizubehalten.