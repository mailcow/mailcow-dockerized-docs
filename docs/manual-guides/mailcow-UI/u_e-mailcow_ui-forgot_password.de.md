!!! warning "Hinweis"
    **Für dieses Feature ist eine mailcow Installation ab Version 2024-08 erforderlich!**

    Der aktuell installierte Patchstand kann in mailcow Versionen seit 2022 innerhalb der UI eingesehen werden.

---

### Vorwort

!!! success "Danke!"
    Diese Funktionalität wurde von der Jugendstiftung Baden-Württemberg im Rahmen eines Sponsored Developments im August 2024 in mailcow integriert.

    Vielen Dank für das Sponsoring dieses Features!

Mit der Passwort-vergessen-Funktion ist es Mailbox-Nutzern möglich, durch die Angabe einer Backup-E-Mail-Adresse, sich einen Link zur Zurücksetzung ihres Passwortes schicken zu lassen und dieses dann zurückzusetzen.

---

### Voraussetzungen

Damit dieses Feature für einen Benutzer aktiviert und nutzbar ist, sind folgende Dinge zu beachten:

1. Der mailcow Administrator muss eine Absender E-Mail [(siehe unten)](#server-einstellungen) hinterlegt haben. Die Absender E-Mail muss nicht als Mailbox existieren, die Domain allerdings muss auf mailcow komplett eingerichtet sein, so dass mit dieser das Senden und vor allem die Zustellung von E-Mails sichergestellt ist.
2. Der Mailbox-Benutzer muss eine Backup-E-Mail in seinen Optionen hinterlegt haben. Dies kann der User selber tun (wenn die dazugehörige ACL nicht deaktiviert ist) oder der Administrator.
3. Die Backup-E-Mail **muss eine andere E-Mail** sein, als die des Mailkontos, für welches das Passwort zurückgesetzt werden soll.
4. Ebenfalls muss diese Backup-E-Mail externe E-Mails empfangen dürfen und sollte (wenn möglich) bei einem anderen Anbieter liegen und nicht direkt auf dem mailcow-Server sein. (Dieser Punkt ist allerdings optional und dient nur als Empfehlung).
5. Der Nutzer muss Zugriff auf das Postfach der Backup-E-Mail haben, da die Links nur eine begrenzte Zeit gültig sind.

---

### Einstellungsmöglichkeiten in der mailcow UI

#### Mailbox-Einstellungen

Durch dieses Feature wird ein neues Feld in den Mailbox-Optionen hinzugefügt:

![Neues mailcow UI Feld für das Hinterlegen einer Backup-E-Mail im Mailbox-Bearbeiten-Fenster](../../assets/images/manual-guides/mailcow-forgot-password_mailbox_field.png)

!!! danger "Achtung"
    Zur Erinnerung: Dieses Feld **MUSS** ausgefüllt sein, damit der Benutzer sein Passwort zurücksetzen kann! Sollte es nicht gesetzt sein, ist es ihm nicht möglich, sein Passwort zurückzusetzen!

Für Administratoren gibt es eine neue ACL, die entweder pro Mailbox im Nachhinein oder auch als Vorlage für Mailboxen gesetzt werden kann: `Verwalten der E-Mail zur Passwortwiederherstellung erlauben`:
![Neue mailcow UI ACL für das Steuern, ob ein Mailbox-Benutzer die Backup-E-Mail selber ändern darf oder nicht](../../assets/images/manual-guides/mailcow-forgot-password_mailbox_acl.png)

!!! info "Hinweis"
    Wenn ein Benutzer bereits eine Backup-E-Mail gesetzt hat, aber der Admin ihm diese ACL entzieht, so kann er trotzdem sein Passwort zurücksetzen, da die Backup-E-Mail weiterhin im System existiert. Die ACL **verbietet** dadurch also **nicht** automatisch die Möglichkeit, das **Passwort zurückzusetzen, wenn es eine E-Mail gibt**!

    Um dies zu erreichen, muss zusätzlich noch die Backup-E-Mail für den Benutzer von einem Administrator entfernt werden.


#### Server-Einstellungen

Der mailcow-Administrator kann (ähnlich wie die Quota- und Quarantäne-Mails) auch für die Passwort-vergessen-E-Mails das Template bearbeiten, wie die Mails dann verschickt werden sollen. **Standardmäßig ist das Template immer auf Englisch**.

Dieses kann unter dem Reiter: `System -> Konfiguration -> Einstellungen -> Passwort-Einstellungen` erreicht werden:

![Neuer mailcow UI Einstellungsabschnitt, wo der Administrator die E-Mail-Vorlagen für das Passwort-vergessen-Feature anpassen kann](../../assets/images/manual-guides/mailcow-forgot-password_server_settings.png)

---

### Versteckte Einstellungen (nicht in der mailcow UI)

Standardmäßig kann jeder Nutzer maximal 3 Passwort-Reset-Tokens anfordern, die dann standardmäßig 15 Minuten gültig sind.

Server-Administratoren können die Ablaufzeit sowie die maximalen Tokens pro Nutzer allerdings konfigurieren.

Dafür muss (falls noch nicht vorhanden) eine Datei namens `vars.local.inc.php` in dem Ordner `MAILCOW_ROOT/data/web/inc` angelegt werden.

Diese muss dann mindestens Folgendes enthalten:

```php
<?php

// Maximum number of password reset tokens that can be generated at once per user
$PW_RESET_TOKEN_LIMIT = 3; // Zahl hier abändern auf einen anderen Wert

// Maximum time in minutes a password reset token is valid
$PW_RESET_TOKEN_LIFETIME = 15; // Zahl hier abändern auf einen anderen Wert. Wert in Minuten
```

**Die Datei wird automatisch eingelesen, es ist kein Neustart von mailcow oder einem der Container erforderlich!**