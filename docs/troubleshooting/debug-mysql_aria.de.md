## MariaDB: Aria-Wiederherstellung nach Absturz

Wenn Ihr Server abgestürzt ist und MariaDB eine Fehlermeldung ähnlich `[ERROR] mysqld: Aria recovery failed. Please run aria_chk -r on all Aria tables (*.MAI) and delete all aria_log.######## files`, können Sie Folgendes versuchen, um die Datenbank in einen gesunden Zustand zu bringen:

Starten Sie den Stack und warten Sie, bis mysql-mailcow beginnt, einen Neustart zu melden. Überprüfen Sie dies, indem Sie `docker compose ps` ausführen.

Führen Sie nun die folgenden Befehle aus:

```
# Stoppe den Stack, führe nicht "down" aus
docker compose stop
# Führen Sie eine Bash in dem gestoppten Container als Benutzer mysql aus
docker compose run --rm --entrypoint '/bin/sh -c "gosu mysql bash"' mysql-mailcow
# cd in das SQL-Datenverzeichnis
cd /var/lib/mysql
# aria_chk ausführen
aria_chk --check --force */*.MAI
# Löschen der aria-Logdateien
rm aria_log.*
```

Führen Sie nun `docker compose down` gefolgt von `docker compose up -d` aus.