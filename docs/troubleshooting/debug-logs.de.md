!!! warning
    Dieser Abschnitt gilt nur für Docker's Standard-Logging-Treiber (JSON).

Um die Logs aller mailcow: dockerized bezogenen Container zu sehen, können Sie `docker compose logs` innerhalb Ihres mailcow-dockerized Ordners verwenden, der Ihre `mailcow.conf` enthält. Dies ist normalerweise ein bisschen viel, aber Sie können die Ausgabe mit `--tail=100` auf die letzten 100 Zeilen pro Container kürzen, oder ein `-f` hinzufügen, um die Live-Ausgabe aller Ihrer Dienste zu verfolgen.

Um die Logs eines bestimmten Dienstes zu sehen, kann man `docker compose logs [options] $service_name` verwenden

!!! info
    Die verfügbaren Optionen für den Befehl **docker compose logs** sind:

    - **-no-color**: Erzeugt eine einfarbige Ausgabe.
    - **-f**: Der Log-Ausgabe folgen.
    - **-t**: Zeitstempel anzeigen.
    - **--tail="all "**: Anzahl der Zeilen, die ab dem Ende der Protokolle für jeden Container angezeigt werden sollen.
