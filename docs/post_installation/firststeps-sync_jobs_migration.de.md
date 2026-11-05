Sync-Jobs dienen dazu, bestehende E-Mails entweder von einem externen IMAP-Server oder zwischen bestehenden Mailboxen innerhalb von mailcow zu kopieren oder zu verschieben (siehe [Sync zwischen Mailboxen in mailcow](#sync-zwischen-mailboxen-in-mailcow)). mailcow nutzt dafür [imapsync](https://imapsync.lamiral.info/). Neben Benutzername und Passwort kann die Anmeldung am Quellserver über OAuth2 erfolgen, z. B. bei Microsoft 365 und Google.

!!! warning "Hinweis"
    Je nach Zugriffsrechten (ACL) der Mailbox ist das Anlegen von Sync-Jobs nicht erlaubt. In dem Fall hilft der Domain-Administrator weiter.

Ein Sync-Job nutzt immer eine **Sync-Quelle**: den Quell-IMAP-Server und die Art, wie mailcow sich dort anmeldet. Jeder Server wird einmal als Quelle angelegt und dann in den Sync-Jobs ausgewählt.

## Sync-Quelle anlegen

1. „E-Mail :material-arrow-right: Konfiguration :material-arrow-right: Sync-Jobs“ (als Admin oder Domain-Admin) bzw. „Benutzereinstellungen :material-arrow-right: Sync-Jobs“ (als normaler Mailbox-Nutzer) öffnen und im Abschnitt „Sync-Quellen“ auf „Quelle hinzufügen“ klicken.

2. Optional eine der „Vorlagen“ wählen. Die Vorlagen tragen die Servereinstellungen gängiger Anbieter ein (Gmail, GMX, WEB.DE, T-Online, iCloud, Yahoo, IONOS, STRATO). Admins und Domain-Admins erhalten zusätzlich Vorlagen für Microsoft 365 und Google. Viele Anbieter (z. B. Gmail, iCloud, Yahoo) verlangen ein App-Passwort oder einen in den Postfach-Einstellungen freigeschalteten IMAP-Zugang.

3. Einen „Name“ vergeben und die „Sichtbarkeit“ wählen: wer die Quelle in seinen Sync-Jobs nutzen darf. Administratoren können eine Quelle für alle Benutzer freigeben, Domain-Administratoren für ihre Domains oder einzelne Mailboxen. Quellen von Mailbox-Nutzern sind nur für sie selbst sichtbar. Administratoren sehen alle Quellen.

4. „Host“, „Port“ und „Verschlüsselung“ des Quellservers eintragen. SSL nutzt in der Regel Port 993, STARTTLS Port 143. Als Host den Namen aus dem Zertifikat des Servers eintragen, keine IP-Adresse. Unverschlüsselte Verbindungen (PLAIN) sind möglich, aber nicht zu empfehlen.

5. „Zertifikat des Servers prüfen“ eingeschaltet lassen, außer der Server hat ein selbstsigniertes oder abgelaufenes Zertifikat (siehe [Zertifikatsprüfung](#zertifikatsprufung)).

6. Die „Authentifizierung“ wählen: `PLAIN`, `LOGIN` oder `CRAM-MD5` für Benutzername und Passwort, `XOAUTH2` für OAuth2 (nur Admins und Domain-Admins, siehe [OAuth2](#oauth2)).

7. Auf „Hinzufügen“ klicken.

## Zertifikatsprüfung

„Zertifikat des Servers prüfen“ ist bei neuen Quellen eingeschaltet. Die Prüfung gilt für SSL und STARTTLS.

* mailcow prüft das Zertifikat gegen den Hostnamen der Quelle. Der Host muss der Name aus dem Zertifikat sein, z. B. `imap.example.net`, keine IP-Adresse.
* Bei Servern mit selbstsigniertem oder abgelaufenem Zertifikat oder einem Zertifikat, das nicht zum Host passt, den Haken entfernen. Sonst schlägt der Sync-Job fehl, z. B. mit „Problem mit verschlüsselter Verbindung“ oder „Keine Verbindung zum Quellserver möglich“. „Logs überprüfen“ zeigt die Details.
* Die Liste der Quellen zeigt ein Schild-Symbol neben dem Server, wenn das Zertifikat nicht geprüft wird.
* Die Prüfung für eine Quelle abzuschalten, die Sync-Jobs anderer Mailboxen nutzen, setzt Zugriff auf alle diese Mailboxen voraus. Administratoren dürfen das immer.

## Sync-Job einrichten

1. An derselben Stelle auf „Neuen Sync-Job erstellen“ klicken.

2. Als Administrator oder Domain-Administrator die „Lokale Mailbox (Ziel)“ wählen, in die die E-Mails kopiert werden.

3. Unter „Quelle wählen“ die Quelle auswählen. Inaktive Quellen lassen sich nicht auswählen.

4. Die Anmeldung der Quell-Mailbox angeben:
    * Quellen mit Benutzername und Passwort: „Benutzername an der Quelle“ und „Passwort an der Quelle“.
    * OAuth2-Quellen mit Benutzer-Login: Auf „Beim Provider anmelden“ klicken und mit dem Quellkonto anmelden. Der Benutzername an der Quelle wird aus diesem Konto übernommen.
    * OAuth2-Quellen mit Client Credentials: die Quell-Mailbox als „Benutzername an der Quelle“, kein Passwort.

5. Alle weiteren Felder können bei den Standardwerten bleiben oder nach Bedarf angepasst werden. „Eigene Parameter“ nimmt zusätzliche imapsync-Optionen auf, eine pro Zeile (siehe [Eigene Parameter](#eigene-parameter)).

6. „Aktiv“ anhaken und auf „Hinzufügen“ klicken.

!!! notice "Nicht vergessen"
    Nach dem Einrichten in der Ziel-Mailbox prüfen, ob alle E-Mails korrekt importiert wurden. Hat alles geklappt, liegen alle Nachrichten im neuen Postfach. Danach den Sync-Job deaktivieren oder löschen, sobald er nicht mehr gebraucht wird.

## Status und Ergebnisse

Die Liste der Sync-Jobs zeigt den Status jedes Jobs („Wartend“, „Wird ausgeführt“, „Inaktiv“), das „Letztes Ausführungsergebnis“ und das Log des letzten Laufs („Logs überprüfen“). Häufige Ergebnisse:

| Letztes Ausführungsergebnis | Bedeutung |
| --- | --- |
| Erfolg | Der Lauf wurde ohne Fehler beendet. |
| Falscher Benutzername oder Passwort | Die Anmeldung an der Quelle ist fehlgeschlagen. |
| Keine Verbindung zum Quellserver möglich | Der Quellserver ist nicht erreichbar, die Zertifikatsprüfung ist fehlgeschlagen (SSL) oder die Quelle zeigt auf mailcow selbst. |
| Problem mit verschlüsselter Verbindung | STARTTLS ist fehlgeschlagen, z. B. wegen der Zertifikatsprüfung. |
| Ziel Mailbox ist über dem Limit | Die mailcow-Mailbox ist voll. |
| OAuth-Token nicht bereit | Es gibt kein gültiges OAuth2-Token (siehe [Fehlersuche](#fehlersuche)). |
| Logs überprüfen | Jedes andere Ergebnis, das Log zeigt die Details. |

## Quellen verwalten

Die Liste der Quellen zeigt „Bearbeiten“ bei Quellen, die sich ändern lassen, und „Anzeigen“ bei Quellen, die nur freigegeben sind.

* Administratoren können alle Quellen bearbeiten, alle anderen die selbst angelegten. Domain-Administratoren können zusätzlich Quellen bearbeiten, die Mailboxen ihrer Domains angelegt haben.
* Die Verbindung einer Quelle (Host, Port, Verschlüsselung, Authentifizierung sowie OAuth2-Flow, Token-Endpunkt und Client-ID) lässt sich nur mit Zugriff auf alle Mailboxen ändern, deren Sync-Jobs die Quelle nutzen. Sonst lehnt mailcow die Änderung mit „Der Server der Sync-Quelle … kann nicht geändert werden, Sync-Jobs anderer Postfächer verwenden sie“ ab. Administratoren dürfen sie immer ändern.
* Eine Änderung der Verbindung löscht die OAuth2-Tokens der Quelle. Bei Quellen mit Benutzer-Login müssen sich die Benutzer erneut anmelden.
* Eine inaktive Quelle pausiert alle ihre Sync-Jobs.
* Eine Quelle lässt sich nur löschen, solange kein Sync-Job sie nutzt.
* Wird das Konto gelöscht, das eine Quelle angelegt hat, wird die Quelle ebenfalls gelöscht, wenn kein Sync-Job sie nutzt. Sonst geht sie an die Administratoren über.

## OAuth2

Quellen mit der Authentifizierung `XOAUTH2` melden sich mit einem OAuth2-Token statt mit einem Passwort an. Nur Administratoren und Domain-Administratoren können sie anlegen und bearbeiten. Es gibt zwei Flows:

* **App (Client Credentials)**: mailcow meldet sich mit einer App an, die Zugriff auf alle Quell-Mailboxen hat. Benutzer müssen sich nicht anmelden. Solche Quellen sehen nur, wer sie angelegt hat, und die Administratoren. Mailbox-Nutzer können sie nicht auswählen, die Sync-Jobs legt deshalb der Ersteller der Quelle oder ein Administrator an.
* **Benutzer-Login (Authorization Code)**: Beim Anlegen eines Sync-Jobs meldet sich jeder Benutzer einmal mit dem Quellkonto beim Provider an. Mailbox-Nutzer können solche Quellen nutzen, wenn sie für sie freigegeben sind.

Der Token-Endpunkt und die anderen OAuth2-Endpunkte müssen `https://`-URLs sein. Quellen, die nicht von einem Administrator angelegt wurden, brauchen Endpunkte mit öffentlicher Adresse.

Bei Quellen mit Benutzer-Login zeigt die Quelle die „Redirect-URI“, die in der App beim Provider eingetragen wird: `https://<MAILCOW_HOSTNAME>/syncjob-oauth`. Die Anmeldung beim Provider funktioniert nur, wenn mailcow über diesen Hostnamen aufgerufen wird.

mailcow erneuert die Tokens automatisch, auch während langer Sync-Läufe.

* App-Quellen: Die Liste der Quellen zeigt ein Token-Badge, sein Tooltip zeigt, bis wann das Token gültig ist. „Token jetzt erneuern“ auf der Bearbeiten-Seite der Quelle fordert sofort ein neues Token an.
* Quellen mit Benutzer-Login: Das Token gehört zum Sync-Job, deshalb zeigt die Liste der Sync-Jobs das Token-Badge bei jedem Job.

### Microsoft 365

!!! info "Voraussetzung"
    IMAP muss für die Quell-Mailboxen in Exchange Online aktiviert sein (Microsoft 365 Admin Center: Benutzer :material-arrow-right: E-Mail :material-arrow-right: E-Mail-Apps verwalten).

**App (Client Credentials)**

1. Im Microsoft Entra Admin Center unter „App-Registrierungen“ eine neue App registrieren.
2. Unter „API-Berechtigungen“ die Anwendungsberechtigung `IMAP.AccessAsApp` von „Office 365 Exchange Online“ hinzufügen („Von meiner Organisation verwendete APIs“) und die Administratorzustimmung erteilen.
3. Unter „Zertifikate & Geheimnisse“ einen geheimen Clientschlüssel erstellen.
4. Die App in Exchange Online registrieren und ihr Zugriff auf die Quell-Mailboxen geben, mit der Exchange Online PowerShell. `<OBJECT_ID>` ist die Objekt-ID der App unter „Unternehmensanwendungen“, nicht die unter „App-Registrierungen“:
    ```powershell
    New-ServicePrincipal -AppId <APPLICATION_ID> -ObjectId <OBJECT_ID>
    Add-MailboxPermission -Identity "user@contoso.com" -User <OBJECT_ID> -AccessRights FullAccess
    ```
    Microsoft beschreibt diese Schritte ausführlich unter [Authentifizieren einer IMAP-, POP- oder SMTP-Verbindung mit OAuth](https://learn.microsoft.com/de-de/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth).
5. In mailcow eine Quelle mit der Vorlage „Microsoft 365 (Client Credentials)“ anlegen und den „Microsoft-365-Tenant“ (Tenant-ID oder eine Domain des Tenants), die Client-ID und das Client-Secret eintragen.

**Benutzer-Login (Authorization Code)**

1. Im Microsoft Entra Admin Center unter „App-Registrierungen“ eine neue App registrieren. Die Plattform „Web“ mit der Redirect-URI der Quelle hinzufügen (`https://<MAILCOW_HOSTNAME>/syncjob-oauth`).
2. Unter „API-Berechtigungen“ die delegierten Berechtigungen `IMAP.AccessAsUser.All`, `offline_access`, `openid`, `email` und `profile` von „Microsoft Graph“ hinzufügen. Am besten die Administratorzustimmung erteilen, sonst muss jeder Benutzer bei der Anmeldung zustimmen.
3. Unter „Zertifikate & Geheimnisse“ einen geheimen Clientschlüssel erstellen.
4. In mailcow eine Quelle mit der Vorlage „Microsoft 365 (Benutzer-Login)“ anlegen und den Tenant, die Client-ID und das Client-Secret eintragen.

### Google

1. In der Google Cloud Console den OAuth-Zustimmungsbildschirm eines Projekts einrichten. Bei Google Workspace den Nutzertyp „Intern“ wählen.
2. Unter „Anmeldedaten“ eine „OAuth-Client-ID“ vom Typ „Webanwendung“ erstellen und die Redirect-URI der Quelle (`https://<MAILCOW_HOSTNAME>/syncjob-oauth`) als autorisierte Weiterleitungs-URI eintragen.
3. In mailcow eine Quelle mit der Vorlage „Google (Benutzer-Login)“ anlegen und die Client-ID und das Client-Secret eintragen.

Bei einem privaten Gmail-Konto geht es auch mit einem App-Passwort und der Vorlage „Gmail“.

### Fehlersuche

* **„OAuth-Token nicht bereit“ oder „Token fehlgeschlagen“ bei einem Sync-Job (Benutzer-Login)**: Den Sync-Job öffnen, auf „Beim Provider anmelden“ klicken, erneut anmelden und speichern. Der Browser muss Pop-ups für mailcow erlauben. Beim Anlegen eines Sync-Jobs wählen Administratoren und Domain-Administratoren vor der Anmeldung die lokale Mailbox.
* **„Token fehlgeschlagen“ bei einer App-Quelle**: Der Tooltip des Badges und „Letzter Refresh-Fehler“ auf der Bearbeiten-Seite der Quelle zeigen den Fehler. Tenant, Client-ID, Client-Secret und die Berechtigungen der App prüfen, dann auf „Token jetzt erneuern“ klicken.
* **Die Anmeldung schlägt fehl**: Das Formular des Sync-Jobs zeigt den Grund neben „Beim Provider anmelden“, z. B. „Der Provider hat kein Token ausgestellt (Client-ID, Secret und Redirect-URI prüfen)“.
* Die Anmeldung setzt einen normalen Login mit Zugriff auf Sync-Jobs voraus. Sie funktioniert nicht, solange eine Einrichtung der Zwei-Faktor-Authentifizierung oder eine Passwortänderung aussteht, und nicht in einer Sitzung eines schreibgeschützten API-Keys.

## Sync zwischen Mailboxen in mailcow

Eine Quelle darf nicht auf mailcow selbst zeigen. Quellen mit `localhost`, `dovecot` oder einer anderen Adresse des internen Docker-Netzwerks werden beim Ausführen des Sync-Jobs abgewiesen. Der Job endet mit „Keine Verbindung zum Quellserver möglich“, das Log zeigt „… is an address of mailcow itself“.

Um E-Mails zwischen zwei Mailboxen derselben mailcow zu kopieren, eine Quelle mit dem öffentlichen Hostnamen von mailcow (`MAILCOW_HOSTNAME`) als Host anlegen.

## Einstellungen für Administratoren

* **Parallele Läufe**: Unter „System :material-arrow-right: Konfiguration :material-arrow-right: Einstellungen :material-arrow-right: Sync-Jobs“ legt „Max. parallele Sync-Prozesse“ (1–32, Standard 1) fest, wie viele Sync-Jobs gleichzeitig laufen. „Bandbreiten-Limit pro Prozess (KB/s)“ begrenzt jeden Sync-Prozess (0 = unbegrenzt). Es begrenzt auch das Bandbreiten-Limit eines einzelnen Jobs. Die gesamte Bandbreite liegt bei etwa diesem Wert × der Anzahl paralleler Prozesse.
* **Reihenfolge**: Fällige Sync-Jobs laufen nach ihrer „Priorität“ (Bearbeiten-Seite eines Sync-Jobs, nur für Administratoren, höher läuft zuerst), dann Jobs, die noch nie liefen, dann die am längsten nicht gelaufenen.
* **Als nächstes ausführen**: In der Liste der Sync-Jobs setzt „Aktionen :material-arrow-right: Als nächstes ausführen“ (nur für Administratoren) die ausgewählten Jobs an den Anfang der Warteschlange und macht sie sofort fällig. Dafür wird ihre Priorität über alle anderen Jobs gesetzt und bleibt so, bis sie auf der Bearbeiten-Seite geändert wird.

## Eigene Parameter

„Eigene Parameter“ nimmt zusätzliche imapsync-Optionen auf, eine Option pro Zeile mit ihrem Wert. Ein Wert darf Leerzeichen enthalten und wird als ein Argument an imapsync übergeben. Es werden nur erlaubte Optionen angenommen. Die Liste steht in `$IMAPSYNC_OPTIONS` in `data/web/inc/vars.inc.php` und lässt sich in `data/web/inc/vars.local.inc.php` ändern:

```php
<?php
// Option erlauben, die einen Wert braucht
$IMAPSYNC_OPTIONS['someoption'] = true;
// Option ohne Wert erlauben
$IMAPSYNC_OPTIONS['otheroption'] = false;
// Option erlauben, deren Wert zu einem regulären Ausdruck passen muss
$IMAPSYNC_OPTIONS['maxsize'] = '[0-9]+';
// Option aus der Liste entfernen
unset($IMAPSYNC_OPTIONS['debug']);
```

* Optionsnamen werden kleingeschrieben und ohne führende Bindestriche angegeben.
* `true`: Die Option braucht einen Wert. `false`: Die Option hat keinen Wert. Ein String: ein regulärer Ausdruck (ohne Begrenzer), zu dem der ganze Wert passen muss.
* Manche Optionen lassen sich nie erlauben, z. B. Optionen, die Befehle ausführen oder lokale Dateien nutzen (`pipemess`, `regextrans2`, `logfile`, …), und `showpasswords`. mailcow entfernt sie aus der Liste.
* Enthält die Liste keinen gültigen Eintrag, gilt die Standardliste.
* Änderungen gelten erst nach einem Neustart von PHP-FPM:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart php-fpm-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart php-fpm-mailcow
    ```
