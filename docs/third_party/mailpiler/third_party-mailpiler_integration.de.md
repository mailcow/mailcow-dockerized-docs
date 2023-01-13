Dies ist eine einfache Integration von mailcow-Aliasen und dem Mailbox-Namen in mailpiler bei Verwendung von IMAP-Authentifizierung.

**Disclaimer**: Dies wird weder offiziell vom mailcow-Projekt noch von seinen Mitwirkenden gepflegt oder unterstützt. Es wird keine Garantie oder Unterstützung angeboten, jedoch steht es Ihnen frei, Themen auf GitHub zu öffnen, um einen Fehler zu melden oder weitere Ideen zu liefern. [GitHub Repo kann hier gefunden werden](https://github.com/patschi/mailpiler-mailcow-integration).

!!! info
    Die Unterstützung für Domain Wildcards wurde in Piler 1.3.10 implementiert, das am 03.01.2021 veröffentlicht wurde. Frühere Versionen funktionieren grundsätzlich, aber nach dem Einloggen sehen Sie keine E-Mails, die von oder an den Domain-Alias gesendet werden. (z.B. wenn @example.com ein Alias für admin@example.com ist)

## Das zu lösende Problem

mailpiler bietet die Authentifizierung auf Basis von IMAP an, zum Beispiel:

```php
$config['ENABLE_IMAP_AUTH'] = 1;
$config['IMAP_HOST'] = 'mail.example.com';
$config['IMAP_PORT'] = 993;
$config['IMAP_SSL'] = true;
```

- Wenn Sie sich also mit `patrik@example.com` anmelden, sehen Sie nur zugestellte E-Mails, die von oder an diese spezielle E-Mail-Adresse gesendet wurden.
- Wenn zusätzliche Aliase in mailcow definiert werden, wie z.B. `team@example.com`, werden Sie keine Emails sehen, die an oder von dieser Email-Adresse gesendet wurden, auch wenn Sie ein Empfänger von Emails sind, die an diese Alias-Adresse gesendet wurden.

Indem wir uns in den Authentifizierungsprozess von mailpiler einklinken, sind wir in der Lage, die erforderlichen Daten über die mailcow API während des Logins zu erhalten. Dies löst API-Anfragen an die mailcow-API aus (die einen Nur-Lese-API-Zugang erfordern), um die Aliase auszulesen, an denen Ihre E-Mail-Adresse teilnimmt, und auch den "Namen" des Postfachs, der angegeben wurde, um ihn nach dem Login oben rechts in mailpiler anzuzeigen.

Zugelassene E-Mail-Adressen können in den Mailpiler-Einstellungen oben rechts nach dem Einloggen eingesehen werden.

!!! info
    Dies wird nur einmal während des Authentifizierungsprozesses abgefragt. Die autorisierten Aliase und der Realname sind für die gesamte Dauer der Benutzersitzung gültig, da mailpiler sie in den Sitzungsdaten setzt. Wird ein Benutzer aus einem bestimmten Alias entfernt, so wird dies erst nach dem nächsten Login wirksam.

## Die Lösung

Hinweis: Die Dateipfade können je nach Einrichtung variieren.

### Voraussetzungen

- Eine funktionierende mailcow-Instanz
- Eine funktionierende mailpiler Instanz ([Sie finden eine Installationsanleitung hier](https://patrik.kernstock.net/2020/08/mailpiler-installation-guide/), [überprüfen Sie unterstützte Versionen hier](https://github.com/patschi/mailpiler-mailcow-integration#piler))
- Ein mailcow API-Schlüssel (Nur-Lesen funktioniert): `Konfiguration & Details - Zugang - Nur-Lesen-Zugang`. Vergessen Sie nicht, den API-Zugang von Ihrer mailpiler IP zu erlauben.

!!! warning "Warnung"
    Da mailpiler sich gegenüber mailcow, unserem IMAP-Server, authentifiziert, können fehlgeschlagene Logins von Nutzern oder Bots eine Sperre für Ihre mailpiler-Instanz auslösen. Daher sollten Sie in Erwägung ziehen, die IP-Adresse der mailpiler-Instanz innerhalb von mailcow auf eine Whitelist zu setzen: `Konfiguration & Details - Konfiguration - Fail2ban-Parameter - Whitelisted networks/hosts`.

### Einrichtung

1. Setzen Sie die benutzerdefinierte Abfragefunktion von mailpiler und fügen Sie diese an `/usr/local/etc/piler/config-site.php` an:

    ```php
    $config['MAILCOW_API_KEY'] = 'YOUR_READONLY_API_KEY';
    $config['MAILCOW_SET_REALNAME'] = true; // wenn nicht angegeben, dann ist der Standardwert false
    $config['CUSTOM_EMAIL_QUERY_FUNCTION'] = 'query_mailcow_for_email_access';
    include('auth-mailcow.php');
    ```

    Sie können auch den mailcow-Hostnamen ändern, falls erforderlich:
    ```php
    $config['MAILCOW_HOST'] = 'mail.domain.tld'; // standardmäßig $config['IMAP_HOST']
    ```

2. Laden Sie die PHP-Datei mit den Funktionen aus dem [GitHub Repo](https://github.com/patschi/mailpiler-mailcow-integration) herunter:

    ```sh
    curl -o /usr/local/etc/piler/auth-mailcow.php https://raw.githubusercontent.com/patschi/mailpiler-mailcow-integration/master/auth-mailcow.php
    ```

3. Erledigt!

   Stellen Sie sicher, dass Sie sich erneut mit Ihren IMAP-Zugangsdaten anmelden, damit die Änderungen wirksam werden.

   Wenn es nicht funktioniert, ist höchstwahrscheinlich etwas mit der API-Abfrage selbst nicht in Ordnung. Versuchen Sie eine Fehlersuche, indem Sie manuelle API-Anfragen an die API senden. (Tipp: Öffnen Sie `https://mail.domain.tld/api` auf Ihrer Instanz)

