Watchdog verwendet Standardwerte für alle in `docker-compose.yml` definierten Thresholde.

Die Standardwerte sind für die meisten Konfigurationen geeignet.
Beispiel:
```
- NGINX_THRESHOLD=${NGINX_THRESHOLD:-5}
- UNBOUND_THRESHOLD=${UNBOUND_THRESHOLD:-5}
- REDIS_THRESHOLD=${REDIS_THRESHOLD:-5}
- MYSQL_THRESHOLD=${MYSQL_THRESHOLD:-5}
- MYSQL_REPLICATION_THRESHOLD=${MYSQL_REPLICATION_THRESHOLD:-1}
- SOGO_THRESHOLD=${SOGO_THRESHOLD:-3}
- POSTFIX_THRESHOLD=${POSTFIX_THRESHOLD:-8}
- CLAMD_THRESHOLD=${CLAMD_THRESHOLD:-15}
- DOVECOT_THRESHOLD=${DOVECOT_THRESHOLD:-12}
- DOVECOT_REPL_THRESHOLD=${DOVECOT_REPL_THRESHOLD:-20}
- PHPFPM_THRESHOLD=${PHPFPM_THRESHOLD:-5}
- RATELIMIT_THRESHOLD=${RATELIMIT_THRESHOLD:-1}
- FAIL2BAN_THRESHOLD=${FAIL2BAN_THRESHOLD:-1}
- ACME_THRESHOLD=${ACME_THRESHOLD:-1}
- RSPAMD_THRESHOLD=${RSPAMD_THRESHOLD:-5}
- OLEFY_THRESHOLD=${OLEFY_THRESHOLD:-5}
- MAILQ_THRESHOLD=${MAILQ_THRESHOLD:-20}
- MAILQ_CRIT=${MAILQ_CRIT:-30}
```

Um sie anzupassen, fügen Sie einfach die notwendigen Threshold Variablen (z.B. `MAILQ_THRESHOLD=10`) zu `mailcow.conf` hinzu und führen Sie den folgenden Befehl aus:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```


### Threshold Beschreibungen

#### NGINX_THRESHOLD
Benachrichtigt Administratoren, wenn Watchdog keine Verbindung zu Nginx auf Port 8081 herstellen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht wurde.

#### UNBOUND_THRESHOLD
Benachrichtigt Administratoren, wenn Unbound externe Domänen/DNSSEC nicht auflösen/überprüfen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht ist.

#### REDIS_THRESHOLD
Benachrichtigt Administratoren, wenn der Watchdog keine Verbindung zu Redis auf Port 6379 herstellen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht ist.

#### MYSQL_THRESHOLD
Benachrichtigt Administratoren, wenn watchdog keine Verbindung zu MySQL herstellen kann oder eine Tabelle nicht abfragen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht wurde.

#### MYSQL_REPLICATION_THRESHOLD
Benachrichtigt Administratoren, wenn die MySQL-Replikation fehlschlägt.

#### SOGO_THRESHOLD
Benachrichtigt Administratoren, wenn der Watchdog keine Verbindung zu SOGo auf Port 20000 herstellen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht ist.

#### POSTFIX_THRESHOLD
Benachrichtigt Administratoren, wenn watchdog keine Testmail über Port 589 senden kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht ist.

#### CLAMD_THRESHOLD
Benachrichtigt Administratoren, wenn Watchdog keine Verbindung zu Clamd herstellen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht wurde.

#### DOVECOT_THRESHOLD
Benachrichtigt Administratoren, wenn watchdog bei verschiedenen Tests mit dem Dovecot-Container fehlschlägt. Der Container wird automatisch neu gestartet, wenn Probleme gefunden wurden und der Threshold erreicht ist.

#### DOVECOT_REPL_THRESHOLD
Benachrichtigt Administratoren, wenn die Dovecot-Replikation fehlschlägt.

#### PHPFPM_THRESHOLD
Benachrichtigt Administratoren, wenn Watchdog keine Verbindung zu PHP-FPM auf Port 9001/9002 herstellen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht ist.

#### RATELIMIT_THRESHOLD
Benachrichtigt Administratoren, wenn ein Ratelimit erreicht wurde.

#### FAIL2BAN_THRESHOLD
Benachrichtigt Administratoren, wenn ein fail2ban eine IP gesperrt hat.

#### ACME_THRESHOLD
Benachrichtigt Administratoren, wenn etwas mit dem acme-mailcow-Container nicht in Ordnung ist. Sie können dessen Logs überprüfen.

#### RSPAMD_THRESHOLD
Benachrichtigt Administratoren, wenn Watchdog bei verschiedenen Tests mit dem Rspamd-Container fehlschlägt und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht wurde.

#### OLEFY_THRESHOLD
Benachrichtigt Administratoren, wenn watchdog keine Verbindung zu olefy auf Port 10005 herstellen kann und startet den Container automatisch neu, wenn Probleme gefunden wurden und der Threshold erreicht ist.

#### MAILQ_CRIT und MAILQ_THRESHOLD
Benachrichtigt Administratoren, wenn die Anzahl der E-Mails in der Postfix-Warteschlange größer ist als `MAILQ_CRIT` für einen Zeitraum von `MAILQ_THRESHOLD * (60±30)` Sekunden.

