Gruppen bündeln Mailboxen. Alles, was an einer Gruppe eingestellt ist, gilt für alle Mitglieder:

| Funktion | Mitglieder erhalten |
| --- | --- |
| Gruppenadresse | Mails an die Gruppenadresse gehen an alle Mitglieder |
| Senden als | Mitglieder dürfen als andere Adressen senden |
| Postfachzugriff | Mitglieder öffnen andere Mailboxen in ihrem Mailprogramm |
| Kalender und Adressbücher | Mitglieder erhalten Zugriff auf SOGo-Kalender und -Adressbücher anderer Mailboxen |
| Mailbox-Template | Die Einstellungen einer Mailbox-Vorlage |

Gruppen werden in mailcow gepflegt oder aus Keycloak bzw. LDAP/Active Directory synchronisiert, siehe [Identity Provider Synchronisation](u_e-mailcow_ui-idp-sync.md).

---

## Gruppe anlegen

Unter `E-Mail > Konfiguration > Gruppen` auf **Gruppe hinzufügen** klicken. Später geändert wird eine Gruppe über **Bearbeiten** in der Liste.

* `Domain`: Die Domain, zu der die Gruppe gehört. Lässt sich später nicht ändern.
* `Name`: Eindeutig innerhalb der Domain.
* `Beschreibung`: Optional, erscheint in der Gruppenliste unter dem Namen.
* `Gruppenadresse`: Optional, siehe [Gruppenadresse](#gruppenadresse-verteiler).
* `Mitglieder`: Die Mailboxen der Gruppe. Nur normale Mailboxen können Mitglied sein, Ressourcen nicht.
* `Senden als`: Adressen, als die die Mitglieder senden dürfen, siehe [Senden als](#senden-als).
* `Postfachzugriff`, `Kalender und Adressbücher`: Freigaben, siehe [Freigaben](#freigaben).
* `Mailbox-Template`, `Priorität`: Nur für Administratoren, siehe [Mailbox-Template](#mailbox-template).
* `Aktiv`: Eine inaktive Gruppe behält ihre Einstellungen, ihre Mitglieder verlieren aber alles, was sie über die Gruppe erhalten haben.

---

## Gruppenadresse (Verteiler)

Hat eine Gruppe eine Adresse, legt mailcow dafür einen Alias an, der an alle Mitglieder zustellt, und hält ihn aktuell. Der Alias erscheint in der Alias-Liste mit **Wird von Gruppe ... verwaltet** und lässt sich nur über die Gruppe ändern.

Die Adresse muss zur Domain der Gruppe gehören, Adressen von Alias-Domains sind nicht möglich. Sie darf noch nicht von einer Mailbox oder einem Alias belegt sein und zählt zum Alias-Limit der Domain (`Max. mögliche Aliasse`). Solange die Gruppe inaktiv ist oder keine Mitglieder hat, werden Mails an die Adresse abgelehnt, die Adresse bleibt aber für die Gruppe reserviert.

* `Mitglieder dürfen als Gruppenadresse senden`: Mitglieder können die Gruppenadresse als Absender verwenden.
* `Gruppenadresse in SOGo als Identität anzeigen`: Mitglieder können die Adresse in SOGo als Absender auswählen (setzt die Option darüber voraus).
* `Nur Mails von Absendern der Domain annehmen`: Mails externer Absender an die Gruppenadresse werden abgelehnt.

!!! warning "Große Gruppen"
    Postfix stellt Mails an eine einzelne Adresse an höchstens 1000 Empfänger zu (`virtual_alias_expansion_limit`). mailcow zeigt eine Warnung, wenn eine Gruppe mit Adresse mehr Mitglieder hat.

---

## Senden als

Eine Adresse pro Zeile: eine Mailbox, ein Alias oder `@example.org` für alle Adressen einer Domain. Solange die Gruppe aktiv ist, darf jedes Mitglied als diese Adressen senden.

SOGo bietet diese Adressen nicht automatisch an. Mitglieder legen sie selbst als Identität in SOGo oder in ihrem Mailprogramm an. Nur die Gruppenadresse wird in SOGo automatisch zur Identität, siehe [Gruppenadresse](#gruppenadresse-verteiler).

Die Bearbeiten-Seite einer Mailbox zeigt diese Adressen unter **Darf senden als (über Gruppen)**. Ändern lassen sie sich nur in der Gruppe.

!!! tip "Tipp"
    Damit ein Team als `info@example.org` senden kann: das Team als Mitglieder aufnehmen, `info@example.org` unter `Senden als` eintragen und der Gruppe Zugriff auf die Mailbox geben (siehe [Freigaben](#freigaben)).

---

## Mailbox-Template

Administratoren können einer Gruppe eine Mailbox-Vorlage zuweisen. mailcow wendet sie auf alle Mitglieder an:

* Ist eine Mailbox in mehreren Gruppen, gilt die Vorlage der aktiven Gruppe mit der höchsten `Priorität`. Bei gleicher Priorität gewinnt die Gruppe mit der niedrigsten ID.
* Die Vorlage wird angewendet, wenn sich die wirksame Vorlage einer Mailbox ändert, zum Beispiel beim Eintritt in eine Gruppe. Wird eine Vorlage bearbeitet, wird sie erneut auf alle Mitglieder angewendet, für die sie die wirksame Vorlage ist. **Template erneut auf alle Mitglieder anwenden** wendet sie gezielt erneut an.
* Verlässt ein Mitglied die Gruppe, behält es die Einstellungen der Vorlage. Gilt jetzt die Vorlage einer anderen Gruppe, wendet mailcow diese an.
* Mailboxen mit der Authentifizierungsquelle mailcow behalten manuelle Änderungen, bis die Vorlage erneut angewendet wird.
* Mailboxen aus einem Identity Provider erhalten die Vorlage der Gruppe statt der Vorlage aus dem Attribut Mapping. mailcow wendet ihre Vorlage bei jeder Anmeldung und jeder Vollsynchronisation erneut an, manuelle Änderungen werden dabei überschrieben. Verlässt eine solche Mailbox alle Gruppen, erhält sie wieder die Vorlage aus dem Attribut Mapping. Siehe [Vorlagen](u_e-mailcow_ui-idp-sync.md#vorlagen).

---

## Freigaben

Freigaben geben den Mitgliedern Zugriff auf Ordner anderer Mailboxen. mailcow setzt sie sofort. Ein Hintergrundjob prüft sie alle 15 Minuten, setzt fehlgeschlagene Freigaben erneut und stellt Freigaben wieder her, die außerhalb der Gruppe geändert oder entfernt wurden. Besitzer können Ordner weiterhin in SOGo oder ihrem Mailprogramm mit einzelnen Benutzern teilen.

### Postfachzugriff (IMAP)

Eine Mailbox und die Rechte der Mitglieder auswählen:

| Recht | Mitglieder können |
| --- | --- |
| Lesen | Mails lesen und als gelesen markieren |
| Schreiben | zusätzlich Ordner anlegen, Mails ablegen, verschieben und löschen |
| Vollzugriff | zusätzlich Ordner löschen |

Mitglieder finden die Mailbox in ihrem Mailprogramm unter `Shared/<Mailbox>/`, z. B. `Shared/info@example.org/INBOX`.

* `Abonnieren`: Abonniert die Ordner der Mailbox innerhalb einer Minute bei jedem Mitglied, damit Mailprogramme sie anzeigen. Das geschieht einmalig: Wer einen Ordner abbestellt, behält das so.
* Neue Unterordner erhalten die Freigabe sofort, neue Ordner auf oberster Ebene innerhalb von 15 Minuten.
* Mitglieder, die die Gruppe verlassen, verlieren den Zugriff mit ihrer nächsten Verbindung. Ordner, die mailcow für sie abonniert hat, werden innerhalb einer Minute abbestellt, außer eine andere Gruppe gibt ihnen Zugriff auf dieselbe Mailbox.

### Kalender und Adressbücher (SOGo)

Eine Mailbox, den Typ (`Kalender` oder `Adressbuch`) und den Zugriff auswählen:

| Zugriff | Kalender | Adressbuch |
| --- | --- | --- |
| Lesen | Termine ansehen | Kontakte ansehen |
| Schreiben | zusätzlich Termine anlegen, ändern und löschen | zusätzlich Kontakte anlegen, ändern und löschen |

Private Termine zeigen nur Datum und Uhrzeit.

* Ordner: `personal` ist der Standardkalender bzw. das Standardadressbuch der Mailbox. Für andere Ordner die Ordner-ID eintragen, also den letzten Teil des CalDAV- bzw. CardDAV-Links in den Ordnereigenschaften in SOGo.
* `Abonnieren`: Fügt den Ordner innerhalb einer Minute bei jedem Mitglied in SOGo hinzu. Das geschieht einmalig: Wer ihn entfernt, bekommt ihn nicht erneut. Ohne diese Option abonnieren die Mitglieder den Ordner selbst in SOGo. Wer den Zugriff verliert, wird innerhalb einer Minute abgemeldet, außer eine andere Gruppe gibt denselben Ordner frei.
* Status **Ausstehend**: Der Ordner existiert noch nicht. Für `personal` legt mailcow den Ordner einer aktiven Mailbox selbst an, z. B. bei einem geteilten Postfach, das SOGo nie geöffnet hat. Andere Ordner-IDs bleiben ausstehend, bis der Ordner existiert, danach wird die Freigabe innerhalb von 15 Minuten aktiv.

Mit `SKIP_SOGO=y` in der `mailcow.conf` sind dieser Abschnitt und die Option `Gruppenadresse in SOGo als Identität anzeigen` ausgeblendet.

---

## Geteilte Postfächer

Ein geteiltes Postfach ist eine Team-Mailbox wie `info@example.org` ohne eigenen Login.

1. Die Mailbox unter `E-Mail > Konfiguration > Mailboxen` anlegen und **Geteiltes Postfach** aktivieren. Mit der Authentifizierungsquelle mailcow ist kein Passwort nötig.
2. Eine Gruppe für das Team anlegen, ihr `Postfachzugriff` auf das geteilte Postfach geben und dessen Adresse unter `Senden als` eintragen.
3. Optional den Kalender oder das Adressbuch unter `Kalender und Adressbücher` freigeben.

Ein geteiltes Postfach empfängt Mails wie gewohnt, aber niemand kann sich damit anmelden: IMAP, POP3, SMTP, SOGo, ActiveSync, App-Passwörter und die mailcow UI sind gesperrt. Eine Anmeldung mit richtigem Passwort wird als `Login denied` protokolliert und zählt für Netfilter nicht als Fehlversuch, siehe [Was als Fehlversuch zählt](u_e-mailcow_ui-netfilter.md#was-als-fehlversuch-zahlt).

---

## Löschen und Umbenennen

Gruppen folgen Änderungen an Mailboxen, Aliassen und Domains:

* Wird eine Mailbox gelöscht, entfernt mailcow ihre Mitgliedschaften, die Freigaben ihrer Ordner und Senden-als-Einträge mit ihrer Adresse.
* Wird eine Mailbox umbenannt, folgen Mitgliedschaften, Freigaben und Senden-als-Einträge der neuen Adresse.
* Wird ein Alias gelöscht, verschwindet seine Adresse aus `Senden als`. Wird er umbenannt, folgen die Senden-als-Einträge.
* Wird eine Domain gelöscht, werden ihre Gruppen gelöscht und Senden-als-Einträge mit Adressen der Domain entfernt. Wird eine Alias-Domain gelöscht, werden Senden-als-Einträge mit ihren Adressen entfernt.
* Wird eine Mailbox-Vorlage gelöscht, verlieren die Gruppen diese Vorlage. Die Mitglieder behalten ihre Einstellungen.

---

## Berechtigungen

* **Administratoren** verwalten alle Gruppen.
* **Domain-Administratoren** verwalten die Gruppen ihrer Domains, wenn ihre ACL **Gruppen** aktiv ist (Standard):
    * Mitglieder können aus allen Domains kommen, die sie verwalten. Mitglieder aus anderen Domains stehen unter der Mitgliederliste und bleiben beim Speichern erhalten.
    * Senden-als-Adressen und freigegebene Ordner müssen zu ihren Domains gehören. Hat ein Administrator Senden-als-Adressen oder Freigaben außerhalb ihrer Domains eingetragen, ist die Gruppe für sie schreibgeschützt. Das gilt auch für eine Freigabe, die gerade entfernt wird.
    * Template, Priorität und die Verknüpfung mit einer IdP-Gruppe sind Administratoren vorbehalten.
    * Ändert sich durch die Änderung eines Domain-Administrators die wirksame Vorlage von Mitgliedern (z. B. durch Deaktivieren der Gruppe), wendet mailcow sie nur auf Mailboxen in dessen Domains an. Andere Mitglieder erhalten sie über **Template erneut auf alle Mitglieder anwenden** oder bei ihrer nächsten IdP-Anmeldung.
    * Auf der Bearbeiten-Seite einer Mailbox sehen sie nur die Gruppen ihrer Domains.
* **Mailbox-Benutzer** sehen ihre Gruppen auf ihrer Benutzerseite.
* Mitglieder, die aus einem Identity Provider synchronisiert werden, sind mit **IdP** markiert und nur dort änderbar.

---

## Einschränkungen

* Gruppen können keine anderen Gruppen enthalten. Verschachtelte Gruppen aus Active Directory löst der [LDAP-Gruppen-Sync](u_e-mailcow_ui-idp-sync.md#gruppen) auf.
* „Senden im Auftrag von“ wird nicht unterstützt, Mitglieder senden als die Adresse.

---

## Fehlersuche

* Freigaben mit dem Status **Fehlgeschlagen** werden alle 15 Minuten erneut versucht. Das Log steht unter `System > Information > Protokolle > Crontasks` (Task `Group Shares`).
* Die IMAP-Rechte einer Mailbox lassen sich im Dovecot-Container prüfen. Gruppenfreigaben erscheinen als `group=mcg_<Gruppen-ID>`:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec dovecot-mailcow doveadm acl get -u info@example.org INBOX
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec dovecot-mailcow doveadm acl get -u info@example.org INBOX
    ```
