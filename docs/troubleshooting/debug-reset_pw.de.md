## mailcow Admin-Konto

Setzt den mailcow Admin Account auf ein zufälliges Passwort zurück. Ältere mailcow: dockerisierte Installationen können das `mailcow-reset-admin.sh` Skript in ihrem mailcow Stammverzeichnis (mailcow_path) finden.

```
cd mailcow_pfad
./helper-scripts/mailcow-reset-admin.sh
```

## MySQL-Passwörter zurücksetzen

Stoppen Sie den Stack, indem Sie `docker compose stop` ausführen.

Wenn die Container heruntergefahren sind, führen Sie diesen Befehl aus:

```
docker compose run --rm --entrypoint '/bin/sh -c "gosu mysql mysqld --skip-grant-tables & sleep 10 && mysql -hlocalhost -uroot && exit 0"' mysql-mailcow
```

### 1\. Datenbank-Name finden

```
# source mailcow.conf
# docker compose exec mysql-mailcow mysql -u${DBUSER} -p${DBPASS} ${DBNAME}
MariaDB [(none)]> show databases;
+--------------------+
| Database |
+--------------------+
| information_schema |
| mailcow_database | <=====
| mysql |
| performance_schema |
+--------------------+
4 rows in set (0.00 sec)
```

### 2\. Einen oder mehrere Benutzer zurücksetzen

#### 2\.1 Maria DB < 10.4 (ältere mailcow-Installationen)

Sowohl "password" als auch "authentication_string" existieren. Derzeit wird "password" verwendet, aber besser ist es, beide zu setzen.

```
MariaDB [(none)]> SELECT user FROM mysql.user;
+--------------+
| user |
+--------------+
| mailcow | <=====
| root |
+--------------+
2 rows in set (0.00 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> UPDATE mysql.user SET authentication_string = PASSWORD('gotr00t'), password = PASSWORD('gotr00t') WHERE User = 'root';
MariaDB [(none)]> UPDATE mysql.user SET authentication_string = PASSWORD('mookuh'), password = PASSWORD('mookuh') WHERE User = 'mailcow' AND Host = '%';
MariaDB [(none)]> FLUSH PRIVILEGES;
```

#### 2\.2 Maria DB >= 10.4 (aktuelle mailcows)

```
MariaDB [(none)]> SELECT user FROM mysql.user;
+--------------+
| user |
+--------------+
| mailcow | <=====
| root |
+--------------+
2 rows in set (0.00 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
MariaDB [(none)]> ALTER USER 'mailcow'@'%' IDENTIFIED BY 'mookuh';
MariaDB [(none)]> ALTER USER 'root'@'%' IDENTIFIED BY 'gotr00t'; MariaDB [(none)]> ALTER USER 'root'@'%' IDENTIFIED BY 'gotr00t';
MariaDB [(none)]> ALTER USER 'root'@'localhost' IDENTIFIED BY 'gotr00t'; MariaDB [(none)]> ALTER USER 'root'@'localhost' IDENTIFIED BY 'gotr00t';
MariaDB [(none)]> FLUSH PRIVILEGES;
```

## Zwei-Faktor-Authentifizierung entfernen

### Für mailcow WebUI:

Dies funktioniert ähnlich wie das Zurücksetzen eines MySQL-Passworts, jetzt machen wir es vom Host aus, ohne uns mit dem MySQL CLI zu verbinden:

```
Quelle mailcow.conf
docker compose exec mysql-mailcow mysql -u${DBUSER} -p${DBPASS} ${DBNAME} -e "DELETE FROM tfa WHERE username='YOUR_USERNAME';"
```

### Für SOGo:

```
docker compose exec -u sogo sogo-mailcow sogo-tool user-preferences set defaults user@example.com SOGoGoogleAuthenticatorEnabled '{"SOGoGoogleAuthenticatorEnabled":0}'
```