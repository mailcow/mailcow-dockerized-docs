
!!! info "Hinweis zu Autodiscover"
    Die Autodiscover-Funktion funktioniert nur mit Outlook-Versionen bis einschließlich 2019. Neuere Versionen (2021, Microsoft (Office) 365 und das neue Outlook) unterstützen kein Autodiscover für mailcow mehr und erfordern eine manuelle Einrichtung.

    **Dies ist kein Fehler von mailcow**, sondern eine Folge von Änderungen durch Microsoft.

## Outlook bis 2019 unter Windows (ActiveSync – nicht empfohlen)

<div class="client_variables_unavailable" markdown="1">
  Dies gilt nur, wenn der Serveradministrator EAS für Outlook nicht deaktiviert hat. Ist EAS deaktiviert, folgen Sie bitte der Anleitung für Outlook 2007.
</div>

!!! danger "Warnung"
    Die ActiveSync-Unterstützung von mailcow funktioniert mit Outlook unter Windows nicht zuverlässig. Wir raten dringend von dieser Einrichtung ab.

    Ab Outlook 2019 (einschließlich Microsoft (Office) 365 und dem neuen Outlook) funktioniert ActiveSync nicht mehr mit mailcow. Microsoft hat die Standardauthentifizierung für ActiveSync in diesen Versionen deaktiviert und erfordert nun OAuth2 – eine Methode, die mit mailcow nicht kompatibel ist.

Um EAS manuell einzurichten, starten Sie den alten Assistenten über `C:\Program Files (x86)\Microsoft Office\root\Office16\OLCFG.EXE`. Wenn die Anwendung startet, fahren Sie mit Schritt 4 der Anleitung für Outlook 2013 fort. Sollte sich die Anwendung nicht öffnen lassen, deaktivieren Sie den [vereinfachten Kontoerstellungs-Assistenten](https://support.microsoft.com/en-us/help/3189194/how-to-disable-simplified-account-creation-in-outlook) und verwenden Sie die Anleitung für Outlook 2013.

1. Starten Sie Outlook.
2. Wird Outlook zum ersten Mal gestartet, erscheint ein Einrichtungsassistent. Fahren Sie mit Schritt 4 fort.
3. Öffnen Sie das Menü *Datei* und klicken Sie auf *Konto hinzufügen*.
4. Geben Sie Ihren Namen, Ihre E-Mail-Adresse und Ihr Passwort ein. Klicken Sie auf *Weiter*.
5. Geben Sie bei Aufforderung Ihr Passwort erneut ein, aktivieren Sie *Meine Anmeldedaten speichern* und klicken Sie auf *OK*.
6. Klicken Sie auf *Zulassen*.
7. Klicken Sie auf *Fertigstellen*.

Um EAS zu verwenden, starten Sie den alten Assistenten unter `C:\Program Files (x86)\Microsoft Office\root\Office16\OLCFG.EXE`. Sobald die Anwendung geöffnet ist, fahren Sie mit Schritt 4 der Anleitung für Outlook 2013 fort.

Lässt sich die Anwendung nicht öffnen, können Sie den [vereinfachten Konto-Assistenten deaktivieren](https://support.microsoft.com/en-us/help/3189194/how-to-disable-simplified-account-creation-in-outlook) und anschließend der Anleitung für Outlook 2013 folgen.

## Das neue Outlook (vorinstalliert auf Windows)

!!! danger "Hinweis zur Nutzung des neuen Outlook"
    Zugangsdaten, die im neuen Outlook eingegeben werden, werden an Microsoft bzw. deren Rechenzentren übermittelt. Weitere Informationen dazu finden Sie unter: https://www.heise.de/news/Microsoft-krallt-sich-Zugangsdaten-Achtung-vorm-neuen-Outlook-9357691.html

    **Aus Sicherheitsgründen raten wir ausdrücklich von der Nutzung des neuen Outlooks ab.**

!!! warning "Achtung"
    Das neue Outlook unterstützt **keine** CalDAV- oder CardDAV-Kalender – weder nativ noch über [Outlook CalDav Synchronizer](https://caldavsynchronizer.org).

Wenn Sie das neue Outlook dennoch verwenden möchten, gehen Sie folgendermaßen vor:

1. Starten Sie das neue Outlook.
2. Falls noch kein Konto eingerichtet ist, öffnet sich automatisch der Einrichtungsassistent. Fahren Sie in diesem Fall direkt mit Schritt 5 fort.
3. Klicken Sie oben rechts auf das Zahnradsymbol, um die Einstellungen zu öffnen.
4. Navigieren Sie zu `Konten` > `Ihre Konten` und klicken Sie links auf `Konto hinzufügen`.
5. Geben Sie die E-Mail-Adresse ein und klicken Sie auf `Weiter`.
6. Wählen Sie `IMAP` als Anbieter aus.
7. Geben Sie im Feld `Kennwort` das Passwort für das E-Mail-Konto ein.
8. Tragen Sie als `IMAP-Eingangsserver` den FQDN Ihres mailcow-Servers ein (z. B. mail.example.com).
9. Verwenden Sie als Port üblicherweise 993 (IMAPS).
10. Der `Sichere Verbindungstyp` sollte SSL/TLS (bei IMAPS) oder STARTTLS (bei IMAP) sein.
11. Geben Sie als `SMTP-Benutzername` erneut Ihre E-Mail-Adresse an (falls nicht vorausgefüllt).
12. Geben Sie als `SMTP-Kennwort` erneut Ihr E-Mail-Passwort ein.
13. Als `SMTP-Postausgangsserver` tragen Sie erneut den FQDN Ihres mailcow-Servers ein (z. B. mail.example.com).
14. Nutzen Sie als Port idealerweise 587.
15. Der `Sichere Verbindungstyp` sollte SSL/TLS (bei SMTPS/Submission) oder STARTTLS (bei SMTP) sein.
16. Klicken Sie auf `Weiter`, um die Einrichtung abzuschließen.

!!! info "Hinweis"
    Während der Einrichtung fragt Microsoft ggf. nach Datenschutzoptionen. Entscheiden Sie selbst, ob und welche Informationen Sie freigeben möchten.

## Outlook 2007 oder höher unter Windows (Kalender/Kontakte via CalDav Synchronizer)

!!! warning "Achtung"
    Diese Anleitung ist **nicht** mit dem neuen Outlook kompatibel.

1. Laden Sie [Outlook CalDav Synchronizer](https://caldavsynchronizer.org) herunter und installieren Sie ihn.
2. Starten Sie Outlook.
3. Wird Outlook zum ersten Mal gestartet, erscheint ein Einrichtungsassistent. Fahren Sie in diesem Fall mit Schritt 5 fort.
4. Öffnen Sie das Menü *Datei* und klicken Sie auf *Konto hinzufügen*.
5. Geben Sie Ihren Namen, Ihre E-Mail-Adresse und Ihr Passwort ein. Klicken Sie auf *Weiter*.
6. Klicken Sie auf *Fertigstellen*.
7. Öffnen Sie die Registerkarte *CalDav Synchronizer* und klicken Sie auf *Synchronisationsprofile*.
8. Klicken Sie auf die zweite Schaltfläche oben (*Mehrere Profile hinzufügen*), wählen Sie *SOGo* und klicken Sie auf *OK*.
9. Klicken Sie auf *IMAP/POP3-Kontoeinstellungen abrufen*.
10. Klicken Sie auf *Ressourcen erkennen und Outlook-Ordnern zuweisen*.
11. Wählen Sie im Fenster *Ressource auswählen* Ihren Hauptkalender (z. B. *Persönlicher Kalender*), klicken Sie auf `...`, ordnen Sie ihn dem Ordner *Kalender* zu und bestätigen Sie mit *OK*. Wiederholen Sie den Vorgang für *Adressbücher* und *Aufgaben*. Weisen Sie dabei jeweils nur eine Ressource zu.
12. Schließen Sie alle Fenster mit *OK*.

## Outlook 2011 oder höher unter macOS

Die macOS-Version von Outlook unterstützt keine Synchronisation von Kalendern und Kontakten über mailcow und wird daher nicht empfohlen.