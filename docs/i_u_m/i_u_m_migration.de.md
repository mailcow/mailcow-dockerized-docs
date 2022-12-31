!!! warning
    Diese Anleitung geht davon aus, dass Sie beabsichtigen, einen bestehenden Mailcow-Server (Quelle) auf einen brandneuen, leeren Server (Ziel) zu migrieren. Sie kümmert sich nicht um die Erhaltung bestehender Daten auf dem Zielserver und löscht alles innerhalb von `/var/lib/docker/volumes` und somit alle Docker-Volumes, die Sie bereits eingerichtet haben.

!!! tip
    Alternativ können Sie das Skript `./helper-scripts/backup_and_restore.sh` verwenden, um ein vollständiges Backup auf der Quellmaschine zu erstellen, dann installieren Sie mailcow auf der Zielmaschine wie gewohnt, kopieren Sie Ihre `mailcow.conf` und verwenden Sie das gleiche Skript, um Ihr Backup auf der Zielmaschine wiederherzustellen.

**1\.**
Befolgen Sie die [Installationsanleitung](i_u_m_install.de.md) von Docker und Compose.

**2\.** Stoppen Sie Docker und stellen Sie sicher, dass Docker gestoppt wurde:
```
systemctl stop docker.service
systemctl status docker.service
```

**3\.** Führen Sie die folgenden Befehle auf dem Quellcomputer aus (achten Sie darauf, die abschließenden Schrägstriche im ersten Pfadparameter wie unten gezeigt hinzuzufügen!) - **WARNUNG: Dieser Befehl löscht alles, was bereits unter `/var/lib/docker/volumes` auf dem Zielrechner existiert**:
```
rsync -aHhP --numeric-ids --delete /opt/mailcow-dockerized/ root@target-machine.example.com:/opt/mailcow-dockerized
rsync -aHhP --numeric-ids --delete /var/lib/docker/volumes/ root@target-machine.example.com:/var/lib/docker/volumes
```

**4\.** Schalten Sie mailcow ab und stoppen Sie Docker auf dem Quellrechner.
```
cd /opt/mailcow-dockerized
docker compose down
systemctl stop docker.service
```

**Wiederholen Sie Schritt 3 mit denselben Befehlen. Dies wird viel schneller gehen als beim ersten Mal.

**6\.** Wechseln Sie auf den Zielrechner und starten Sie Docker.
```
systemctl start docker.service
```

**7\.** Ziehen Sie nun die mailcow Docker-Images auf den Zielrechner.
```
cd /opt/mailcow-dockerized
docker compose pull
```

**8\.** Starten Sie den gesamten mailcow-Stack und alles sollte fertig sein!
```
docker compose up -d
```

**9\.** Zum Schluss ändern Sie Ihre DNS-Einstellungen so, dass sie auf den Zielserver zeigen. Prüfen und ändern Sie gegebenenfalls die `SNAT_TO_SOURCE` Variable in der `mailcow.conf` im mailcow-dockerized Ordner, da andernfalls SOGo nicht richtig funktioniert, wenn die ausgehende IP eine andere ist.
