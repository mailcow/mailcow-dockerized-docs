# 🐮 + 🐋 = 💕

## Unterstützen Sie das mailcow Projekt

Bitte erwägen Sie einen Supportvertrag gegen eine geringe monatliche Gebühr unter [Servercow](https://www.servercow.de/mailcow?#support), um die weitere Entwicklung zu unterstützen. _Wir_ unterstützen _Sie_, während _Sie_ _uns_ unterstützen. :)

Wenn Sie super toll sind und uns ohne Vertrag unterstützen möchten, können Sie eine SAL-Lizenz erhalten, die Ihre Unterstützung bestätigt (kaufbar als flexible Einmalzahlung) bei [Servercow](https://www.servercow.de/mailcow#sal).

## Support erhalten

Es gibt zwei Möglichkeiten, Support für Ihre mailcow-Installation zu erhalten.

### Kommerzieller Support

Für professionellen und priorisierten kommerziellen Support können Sie ein Basis-Support-Abonnement unter [Servercow](https://www.servercow.de/mailcow#support) abschließen. Für kundenspezifische Anfragen oder Fragen kontaktieren Sie uns stattdessen bitte unter [info@servercow.de](mailto:info@servercow.de).

Darüber hinaus bieten wir auch eine voll ausgestattete und verwaltete [managed mailcow](https://www.servercow.de/mailcow#managed) an. Auf diese Weise kümmern wir uns um alles technische und Sie können Ihr ganzes Mail-Erlebnis auf eine problemlose Weise genießen.

### Community-Unterstützung und Chat

Die andere Alternative ist unser kostenloser Community-Support auf unseren verschiedenen Kanälen unten. Bitte beachten Sie, dass dieser Support von unserer großartigen Community rund um mailcow betrieben wird. Diese Art von Support ist best-effort, freiwillig und es gibt keine Garantie für irgendetwas.

- Unsere mailcow Community @ [community.mailcow.email](https://community.mailcow.email)

- Telegram (Support) @ [t.me/mailcow](https://t.me/mailcow).

- Telegram (Off-Topic) @ [t.me/mailcowOfftopic](https://t.me/mailcowOfftopic).

- Twitter [@mailcow_email](https://twitter.com/mailcow_email)

Telegram Desktop-Clients sind für [mehrere Plattformen](https://desktop.telegram.org) verfügbar. Sie können den Gruppenverlauf nach Stichworten durchsuchen.

Nur für **Bug Tracking, Feature Requests und Codebeiträge**:

- GitHub @ [mailcow/mailcow-dockerized](https://github.com/mailcow/mailcow-dockerized)

## Demo

Sie können eine Demo unter [demo.mailcow.email](https://demo.mailcow.email) finden, benutzen Sie die folgenden Anmeldedaten zum Login:

- **Administrator**: admin / moohoo
- **Domänen-Administrator**: department / moohoo
- **Mailbox**: demo@440044.xyz / moohoo

!!! info
	Die Demo Instanz enthält die neusten Updates direkt nach Release von GitHub. Vollautomatisch!

## Überblick

Die integrierte **mailcow UI** ermöglicht administrative Arbeiten auf Ihrer Mailserver-Instanz sowie einen getrennten Domain-Administrator- und Mailbox-Benutzer-Zugriff:

- [DKIM](http://dkim.org) und [ARC](http://arc-spec.org/) Unterstützung
- Black- und Whitelists pro Domain und pro Benutzer
- Spam-Score-Verwaltung pro Benutzer (Spam ablehnen, Spam markieren, Greylist)
- Erlauben Sie Mailbox-Benutzern, temporäre Spam-Aliase zu erstellen
- Voranstellen von E-Mail-Tags an den Betreff oder Verschieben von E-Mails in Unterordner (pro Benutzer)
- Mailbox-Benutzer können die TLS-Durchsetzung für eingehende und ausgehende Nachrichten umschalten
- Benutzer können die Caches von SOGo ActiveSync-Geräten zurücksetzen
- imapsync, um entfernte Postfächer regelmäßig zu migrieren oder abzurufen
- TFA: Yubikey OTP und U2F USB (nur Google Chrome und Derivate), TOTP
- Hinzufügen von Domänen, Postfächern, Aliasen, Domänenaliasen und SOGo-Ressourcen
- Hinzufügen von Whitelist-Hosts zur Weiterleitung von Mails an mailcow
- Fail2ban-ähnliche Integration
- Quarantäne-System
- Antivirus-Scanning inkl. Makro-Scanning in Office-Dokumenten
- Integrierte Basisüberwachung
- Eine Menge mehr...

mailcow: dockerized kommt mit mehreren Containern, die in einem überbrückten Netzwerk verbunden sind.
Jeder Container repräsentiert eine einzelne Anwendung.

- [ACME](https://letsencrypt.org/)
- [ClamAV](https://www.clamav.net/) (optional)
- [Dovecot](https://www.dovecot.org/)
- [MariaDB](https://mariadb.org/)
- [Memcached](https://www.memcached.org/)
- [Netfilter](https://www.netfilter.org/) (Fail2ban-ähnliche Integration von [@mkuron](https://github.com/mkuron))
- [Nginx](https://nginx.org/)
- [Oletools](https://github.com/decalage2/oletools) über [Olefy](https://github.com/HeinleinSupport/olefy)
- [PHP](https://php.net/)
- [Postfix](http://www.postfix.org/)
- [Redis](https://redis.io/)
- [Rspamd](https://www.rspamd.com/)
- [SOGo](https://sogo.nu/)
- [Solr](https://solr.apache.org/) (optional)
- [Unbound](https://unbound.net/)
- Ein Watchdog für die grundlegende Überwachung

**Docker-Volumes** zur Aufbewahrung dynamischer Daten - kümmern Sie sich um sie!

- clamd-db-vol-1
- crypt-vol-1
- mysql-socket-vol-1
- mysql-vol-1
- postfix-vol-1
- redis-vol-1
- rspamd-vol-1
- sogo-userdata-backup-vol-1
- sogo-web-vol-1
- solr-vol-1
- vmail-index-vol-1
- vmail-vol-1
