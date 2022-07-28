## Anhängen eines Containers an Ihre Shell

Um einen Container an Ihre Shell anzuhängen, können Sie einfach folgendes ausführen

```
docker compose exec $Dienst_Name /bin/bash
```

### Verbindung zu Diensten herstellen

Wenn Sie sich direkt mit einem Dienst / einer Anwendung verbinden wollen, ist es immer eine gute Idee, `source mailcow.conf` zu benutzen, um alle relevanten Variablen in Ihre Umgebung zu bekommen.

#### MySQL

```
Quelle mailcow.conf
docker compose exec mysql-mailcow mysql -u${DBUSER} -p${DBPASS} ${DBNAME}
```

#### Redis

```
docker compose exec redis-mailcow redis-cli
```

## Dienstbeschreibungen

Hier ist eine kurze Übersicht, welcher Container / Dienst was macht:

| Dienstname | Dienstbeschreibungen |
| ----------------- | ------------------------------------------------------------------------- |
| unbound-mailcow | Lokaler (DNSSEC) DNS-Auflöser |
| mysql-mailcow | Speichert die SOGo's und die meisten Einstellungen von mailcow |
| postfix-mailcow | Empfängt und sendet Mails |
| dovecot-mailcow | Benutzer-Logins und Siebfilter |
| redis-mailcow | Speicher-Backend für DKIM-Schlüssel und Rspamd |
| rspamd-mailcow | Mail-Filter-System. Verwendet für Av-Behandlung, DKIM-Signierung, Spam-Behandlung |
| clamd-mailcow | Scannt Anhänge auf Viren |
| olefy-mailcow | Scannt angehängte Office-Dokumente auf Makro-Viren |
| solr-mailcow | Bietet Volltextsuche in Dovecot |
| sogo-mailcow | Webmail-Client, der Microsoft ActiveSync und Cal- / CardDav verarbeitet |
| nginx-mailcow | Nginx Remote-Proxy, der alle mailcow-bezogenen HTTP / HTTPS-Anfragen bearbeitet |
| acme-mailcow | Automatisiert den Einsatz von HTTPS (SSL/TLS) Zertifikaten |
| memcached-mailcow | Internes Caching-System für mailcow-Dienste |
| watchdog-mailcow | Ermöglicht die Überwachung von Docker-Containern / Diensten |
| php-fpm-mailcow | Betreibt die mailcow Web UI |
| netfilter-mailcow | Fail2Ban ähnliche Integration |
