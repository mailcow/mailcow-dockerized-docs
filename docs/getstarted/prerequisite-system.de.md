Bevor Sie **mailcow: dockerized** ausführen, sollten Sie einige Voraussetzungen überprüfen:

!!! warning "Achtung"
    Versuchen Sie **nicht**, mailcow auf einem Synology/QNAP-Gerät (jedes NAS), OpenVZ, LXC oder anderen Container-Plattformen zu installieren. KVM, ESX, Hyper-V und andere vollständige Virtualisierungsplattformen werden unterstützt.

!!! info
    - mailcow: dockerized erfordert, dass [einige Ports](#eingehende-ports) für eingehende Verbindungen offen sind, also stellen Sie sicher, dass Ihre Firewall diese nicht blockiert.
    - Stellen Sie sicher, dass keine andere Anwendung die Konfiguration von mailcow stört, wie z.B. ein anderer Maildienst
    - Ein korrektes DNS-Setup ist entscheidend für jedes gute Mailserver-Setup, also stellen Sie bitte sicher, dass Sie zumindest die [basics](../getstarted/prerequisite-dns.de.md#die-minimale-dns-konfiguration) abgedeckt haben, bevor Sie beginnen!
    - Stellen Sie sicher, dass Ihr System ein korrektes Datum und eine korrekte [Zeiteinstellung](#datum-und-uhrzeit) hat. Dies ist entscheidend für verschiedene Komponenten wie die Zwei-Faktor-TOTP-Authentifizierung.

## Minimale Systemressourcen

Bitte stellen Sie sicher, dass Ihr System mindestens über die folgenden Ressourcen verfügt, um problemlos zu laufen:

| Ressource   | Minimale Anforderung                                   |
| ----------- | ------------------------------------------------------ |
| CPU         | 1 GHz                                                  |
| RAM         | **Minimum** 6 GiB + 1 GiB Swap (Standardkonfiguration) |
| Festplatte  | 20 GiB (ohne Emails)                                   |
| Architektur | x86_64, ARM64                                          |

!!! failure "Nicht unterstützte Plattformen"
	**OpenVZ, Virtuozzo und LXC**

### Arbeitsspeicher
ClamAV und die FTS-Engine (Flatcurve) können viel RAM nutzen, lassen sich aber über die Parameter `SKIP_CLAMD=y` und `SKIP_FTS=y` in der mailcow.conf deaktivieren.

mailcow ist eine umfassende Groupware mit zahlreichen Features wie Webserver, Webmailer, ActiveSync, Antivirus, Antispam, Indexierung, Dokumentenscanner, Datenbank und Cache, weshalb es mehr Ressourcen benötigt als ein einfacher MTA.

Ein einzelner SOGo-Worker **kann** ~350 MiB RAM belegen, bevor er geleert wird. Je mehr ActiveSync-Verbindungen Sie verwenden möchten, desto mehr RAM wird benötigt. In der Standardkonfiguration werden 20 SOGo-Worker erzeugt.

#### Beispiele für die RAM Planung

Ein Unternehmen mit 15 Smartphones (EAS aktiviert) und etwa 50 gleichzeitigen IMAP-Verbindungen sollte 16 GiB RAM einplanen.

6 GiB RAM + 1 GiB Swap sind für die meisten privaten Installationen ausreichend, während 8 GiB RAM für ~5 bis 10 Benutzer empfohlen werden.

Im Rahmen unseres Supports können wir Ihnen bei der korrekten Planung Ihres Setups helfen.

### Unterstützte Betriebssysteme
!!! danger "Wichtig"
    mailcow nutzt Docker als Grundlage. Aufgrund verschiedener technischer Unterschiede zwischen den einzelnen Systemen **werden nicht alle** Plattformen unterstützt, auf denen Docker theoretisch lauffähig ist.

Die folgende Tabelle enthält alle von uns offiziell unterstützten und getesteten Betriebssysteme (*Stand Mai 2025*):

| Betriebssystem            | Kompatibilität                                                     |
| ------------------------- | ------------------------------------------------------------------ |
| Alpine 3.19 und älter     | [⚠️](https://www.alpinelinux.org/ "Eingeschränkt Kompatibel")       |
| Debian 11, 12             | [✅](https://www.debian.org/index.de.html "Vollständig Kompatibel") |
| Ubuntu 22.04 (oder neuer) | [✅](https://ubuntu.com/ "Vollständig Kompatibel")                  |
| Alma Linux 8, 9           | [✅](https://almalinux.org/ "Vollständig Kompatibel")               |
| Rocky Linux 9             | [✅](https://rockylinux.org/ "Vollständig Kompatibel")              |


!!! info "Legende"
    ✅ = Funktioniert **out of the box** anhand der Anleitung.<br>
    ⚠️ = Erfordert einige **manuelle Anpassungen**, sonst aber nutzbar.<br>
    ❌ = Generell **NICHT Kompatibel**.<br>
    ❔ = Ausstehend.

!!! danger "Achtung"
    Andere (nicht genannte Betriebssysteme) können auch funktionieren, sind jedoch nicht offiziell getestet worden und erhalten KEINEN Support, weder Community noch Bezahlt!

    **BENUTZUNG AUF EIGENE GEFAHR!!**

## Firewall & Ports

Bitte überprüfen Sie, ob alle Standard-Ports von mailcow offen sind und nicht von anderen Anwendungen genutzt werden:

```
ss -tlpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190'
# oder:
netstat -tulpn | grep -E -w '25|80|110|143|443|465|587|993|995|4190'
```

!!! danger "Vorsicht"
    Es gibt einige Probleme mit dem Betrieb von mailcow auf einem Firewalld/ufw aktivierten System. <br>
	Sie sollten es deaktivieren (wenn möglich) und stattdessen Ihren Regelsatz in die DOCKER-USER-Kette verschieben, die nicht durch einen Neustart des Docker-Dienstes gelöscht wird. <br>
	Siehe [diese (blog.donnex.net)](https://blog.donnex.net/docker-and-iptables-filtering/) oder [diese (unrouted.io)](https://unrouted.io/2017/08/15/docker-firewall/) Anleitung für Informationen darüber, wie man iptables-persistent mit der DOCKER-USER Kette benutzt. <br>
    Da mailcow im Docker-Modus läuft, haben INPUT-Regeln keinen Effekt auf die Beschränkung des Zugriffs auf mailcow. <br>
	Verwenden Sie stattdessen die FORWARD-Kette.

Wenn dieser Befehl irgendwelche Ergebnisse liefert, entfernen oder stoppen Sie bitte die Anwendung, die auf diesem Port läuft. Sie können mailcows Ports auch über die Konfigurationsdatei `mailcow.conf` anpassen.

### Eingehende Ports

Wenn Sie eine Firewall vor mailcow haben, stellen Sie bitte sicher, dass diese Ports für eingehende Verbindungen offen sind:

| Dienst              | Protokoll | Port   | Container       | Variable                         |
| ------------------- | :-------: | :----- | :-------------- | -------------------------------- |
| Postfix SMTP        |    TCP    | 25     | postfix-mailcow | `${SMTP_PORT}`                   |
| Postfix SMTPS       |    TCP    | 465    | postfix-mailcow | `${SMTPS_PORT}`                  |
| Postfix Submission  |    TCP    | 587    | postfix-mailcow | `${SUBMISSION_PORT}`             |
| Dovecot IMAP        |    TCP    | 143    | dovecot-mailcow | `${IMAP_PORT}`                   |
| Dovecot IMAPS       |    TCP    | 993    | dovecot-mailcow | `${IMAPS_PORT}`                  |
| Dovecot POP3        |    TCP    | 110    | dovecot-mailcow | `${POP_PORT}`                    |
| Dovecot POP3S       |    TCP    | 995    | dovecot-mailcow | `${POPS_PORT}`                   |
| Dovecot ManageSieve |    TCP    | 4190   | dovecot-mailcow | `${SIEVE_PORT}`                  |
| HTTP(S)             |    TCP    | 80/443 | nginx-mailcow   | `${HTTP_PORT}` / `${HTTPS_PORT}` |

Um einen Dienst an eine IP-Adresse zu binden, können Sie die IP-Adresse wie folgt voranstellen: `SMTP_PORT=1.2.3.4:25`

**Wichtig**: Sie können keine IP:PORT-Bindungen in HTTP_PORT und HTTPS_PORT verwenden. Bitte verwenden Sie stattdessen `HTTP_PORT=1234` und `HTTP_BIND=1.2.3.4`.

### Ausgehende Ports/Hosts

Für die Nutzung von mailcow werden einige ausgehende Verbindungen benötigt. Stellen Sie sicher, dass mailcow mit folgenden Hosts oder auf folgenden Ports nach außen kommunizieren kann:

| Dienst           | Protokoll     | Port    | Ziel                                  | Grund                                                                                            |
| ---------------- | ------------- | ------- | ------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Clamd            | TCP           | 873     | rsync.sanesecurity.net                | Download ClamAV Signaturen (Prebundled in mailcow)                                               |
| Dovecot          | TCP           | 443     | spamassassin.heinlein-support.de      | Herunterladen von Spamassasin Regeln, die Rspamd verarbeitet, Download erfolgt über Dovecot      |
| mailcow Prozesse | TCP           | 80/443  | github.com                            | Download von mailcow Updates (Code Basiert)                                                      |
| mailcow Prozesse | TCP           | 443     | hub.docker.com                        | Download von Docker Images (direkt von Docker Hub)                                               |
| mailcow Prozesse | TCP           | 443     | asn-check.mailcow.email               | API Abfrage auf Prüfung BAD ASN (für Spamhaus Free Blocklists)                                   |
| mailcow Prozesse | TCP           | 80      | ip4.mailcow.email & ip6.mailcow.email | Ermittelung der eigenen öffentlichen IP Adresse zur Anzeige in UI (**optional**)                 |
| Postfix          | TCP           | 25, 465 | Beliebig / Any                        | Ausgehende Verbindung MTA                                                                        |
| Rspamd           | TCP           | 80      | fuzzy.mailcow.email                   | Download von Bad Subject Regex Maps (Trainiert von Servercow)                                    |
| Rspamd           | TCP           | 443     | bazaar.abuse.ch                       | Download von Mailware MD5 Prüfsummen zur Erkennung von Rspamd                                    |
| Rspamd           | TCP           | 443     | urlhaus.abuse.ch                      | Download von Malware Downloads Links zur Erkennung in Rspamd                                     |
| Rspamd           | UDP           | 11445   | fuzzy.mailcow.email                   | Anbindung an Globalen mailcow Fuzzy (Trainiert von Servercow + Community)                        |
| Rspamd           | UDP           | 11335   | fuzzy1.rspamd.com & fuzzy2.rspamd.com | Anbindung an Globalen Rspamd Fuzzy (Trainiert vom Rspamd Team)                                   |
| Unbound          | TCP **&** UDP | 53      | Beliebig / Any                        | DNS Auflösung für mailcow Stack (Zur Validierung von DNSSEC und Abruf von Spamlistinformationen) |
| Unbound          | ICMP (Ping)   |         | 1.1.1.1, 8.8.8.8, 9.9.9.9             | Simpler Internet Konnektivitätscheck                                                             |

### Wichtig für Hetzner Firewalls

Ich zitiere https://github.com/chermsen über https://github.com/mailcow/mailcow-dockerized/issues/497#issuecomment-469847380 (DANKE!):

Für alle, die mit der Hetzner-Firewall zu kämpfen haben:

Port 53 ist in diesem Fall für die Firewall-Konfiguration unwichtig. Laut Dokumentation verwendet unbound den Portbereich 1024-65535 für ausgehende Anfragen.
Da es sich bei der Hetzner Robot Firewall um eine statische Firewall handelt (jedes eingehende Paket wird isoliert geprüft) - müssen die folgenden Regeln angewendet werden:

**Für TCP**
```
SRC-IP: ---
DST-IP: ---
SRC-Port: ---
DST-Port: 1024-65535
Protokoll: tcp
TCP-Flags: ack
Aktion:      Akzeptieren
```

**Für UDP**
```
SRC-IP: ---
DST-IP: ---
SRC-Port: ---
DST-Port: 1024-65535
Protokoll: udp
Aktion:      Akzeptieren
```

Wenn man einen restriktiveren Portbereich anwenden will, muss man zuerst die Konfiguration von unbound ändern (nach der Installation):

{mailcow-dockerized}/data/conf/unbound/unbound.conf:
```
outgoing-port-avoid: 0-32767
```

Nun können die Firewall-Regeln wie folgt angepasst werden:

```
[...]
DST Port: 32768-65535
[...]
```

## Datum und Uhrzeit

Um sicherzustellen, dass Sie das richtige Datum und die richtige Zeit auf Ihrem System eingestellt haben, überprüfen Sie bitte die Ausgabe von `timedatectl status`:

```
$ timedatectl status
      Lokale Zeit: Sat 2017-05-06 02:12:33 CEST
  Weltzeit: Sa 2017-05-06 00:12:33 UTC
        RTC-Zeit: Sa 2017-05-06 00:12:32
       Zeitzone: Europa/Berlin (MESZ, +0200)
     NTP aktiviert: ja
NTP synchronisiert: ja
 RTC in lokaler TZ: nein
      Sommerzeit aktiv: ja
 Letzte DST-Änderung: Sommerzeit begann am
                  Sonne 2017-03-26 01:59:59 MEZ
                  So 2017-03-26 03:00:00 MESZ
 Nächste Sommerzeitänderung: Die Sommerzeit endet (die Uhr springt eine Stunde rückwärts) am
                  Sun 2017-10-29 02:59:59 MESZ
                  Sun 2017-10-29 02:00:00 MEZ
```

Die Zeilen `NTP aktiviert: ja` und `NTP synchronisiert: ja` zeigen an, ob Sie NTP aktiviert haben und ob es synchronisiert ist.

Um NTP zu aktivieren, müssen Sie den Befehl `timedatectl set-ntp true` ausführen. Sie müssen auch Ihre `/etc/systemd/timesyncd.conf` bearbeiten:

```
# vim /etc/systemd/timesyncd.conf
[Zeit]
NTP=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
```

## Hetzner Cloud (und wahrscheinlich andere)

Prüfen Sie `/etc/network/interfaces.d/50-cloud-init.cfg` und ändern Sie die IPv6-Schnittstelle von eth0:0 auf eth0:

```
# Falsch:
auto eth0:0
iface eth0:0 inet6 static
# Richtig:
auto eth0
iface eth0 inet6 static
```

Starten Sie die Schnittstelle neu, um die Einstellungen zu übernehmen.
Sie können außerdem die [cloud-init Netzwerkänderungen deaktivieren.](https://wiki.hetzner.de/index.php/Cloud_IP_static/en#disable_cloud-init_network_changes)

## MTU

Besonders relevant für OpenStack-Benutzer: Überprüfen Sie Ihre MTU und setzen Sie sie entsprechend in docker-compose.yml. Siehe [Problebehandlungen](../getstarted/install.de.md#benutzer-mit-einer-mtu-ungleich-1500-zb-openstack) in unseren Installationsanleitungen.
