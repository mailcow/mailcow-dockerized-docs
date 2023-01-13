!!! warning "Warnung"
    Dieser Abschnitt gilt nur für Docker's Standard-Logging-Treiber (JSON).

Um die Logs aller mailcow: dockerized bezogenen Container zu sehen, können Sie den folgenden Befehl innerhalb Ihres mailcow-dockerized Ordners verwenden, der Ihre `mailcow.conf` enthält:

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose logs
    ```

Dies ist normalerweise ein bisschen viel, aber Sie können die Ausgabe mit `--tail=100` auf die letzten 100 Zeilen pro Container kürzen, oder ein `-f` hinzufügen, um die Live-Ausgabe aller Ihrer Dienste zu verfolgen.

Um die Logs eines bestimmten Dienstes zu sehen, kann man folgendes verwenden: 

=== "docker compose (Plugin)"

    ``` bash
    docker compose logs [options] $service_name
    ```

=== "docker-compose (Standalone)"

    ``` bash
	docker-compose logs [options] $service_name
    ```

!!! info
    Die verfügbaren Optionen für den Befehl obrigen Befehlsind:

    - **-no-color**: Erzeugt eine einfarbige Ausgabe.
    - **-f**: Der Log-Ausgabe folgen.
    - **-t**: Zeitstempel anzeigen.
    - **--tail="all "**: Anzahl der Zeilen, die ab dem Ende der Protokolle für jeden Container angezeigt werden sollen.