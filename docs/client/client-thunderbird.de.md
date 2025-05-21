!!! success "Für mailcow empfohlen"
    Wir empfehlen die Nutzung dieses Clients in Kombination mit unserer mailcow Software für einen reibungslosen Ablauf und stressfreies E-Mailing.

## Was ist Thunderbird?

[Thunderbird](https://www.thunderbird.net) ist ein kostenloser, quelloffener E-Mail-Client, der von der Mozilla Foundation entwickelt wird. Er unterstützt mehrere E-Mail-Konten (IMAP, POP3), Kontakte, Kalender sowie Add-ons zur Erweiterung der Funktionalität. Thunderbird ist bekannt für seine hohe Kompatibilität, benutzerfreundliche Oberfläche und umfassende Anpassungsmöglichkeiten, was ihn besonders für die Nutzung mit mailcow empfiehlt.

## Anleitung zur Einrichtung am Desktop

!!! notice "Hinweis"
    Bitte beachten Sie, dass Sie für eine reibungslose, automatische Erkennung der Konfiguration die [erweiterten DNS Konfigurationen](../getstarted/prerequisite-dns.de.md#die-erweiterte-dns-konfiguration) eingerichtet haben.

1. Öffnen Sie Thunderbird.
2. Wenn Sie Thunderbird zum ersten Mal öffnen, werden Sie gefragt, ob Sie eine neue E-Mail-Adresse einrichten möchten. Klicken Sie auf **Überspringen und eine bereits vorhandene E-Mail-Adresse verwenden** und gehen Sie zum Schritt 4.
3. Klicken Sie auf das Menü **Datei** und wählen Sie **Neu → Bestehendes Mail-Konto...**.
4. Geben Sie Ihren Namen<span class="client_variables_available"> (<code><span class="client_var_name"></span></code>)</span>, Ihre E-Mail-Adresse<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> und Ihr Passwort ein. Stellen Sie sicher, dass die Option **Passwort merken** aktiviert ist und klicken Sie auf **Weiter**.
5. Sobald die Konfiguration automatisch erkannt wurde, stellen Sie sicher, dass **IMAP** ausgewählt ist, und klicken Sie auf **Fertig**.
6. Um Ihre Kontakte vom Server zu verwenden, klicken Sie auf den Pfeil neben **Adressbücher** und dann auf die Schaltfläche **Verbinden** für jedes Adressbuch, das Sie verwenden möchten.
7. Um Ihre Kalender vom Server zu verwenden, klicken Sie auf den Pfeil neben **Kalender** und dann auf die Schaltfläche **Verbinden** für jeden Kalender, den Sie verwenden möchten.
8. *(Optional)* Wenn Sie alle Unterordner synchronisieren möchten:
    - Gehen Sie zum Menü **Kontoeinstellungen** und wählen Sie **Server-Einstellungen**.
    - Klicken Sie im Tab **Server-Einstellungen** auf die Schaltfläche **Erweitert**.
    - Im Fenster **Erweiterte Kontoeinstellungen** deaktivieren Sie das Kontrollkästchen **Nur abonnierte Ordner anzeigen**.
    - Klicken Sie auf **OK**, um die Änderungen zu speichern.
9. Klicken Sie auf **Beenden**, um das Fenster "Konto-Einrichtung" zu schließen.

## Einrichtung auf Android (Thunderbird Mobile / K-9 Mail)

Seit Version 115 basiert Thunderbird für Android auf der bewährten App [K-9 Mail](https://k9mail.app/). Die Einrichtung erfolgt ähnlich:

1. Installieren Sie **K-9 Mail** oder **Thunderbird für Android** aus dem [Google Play Store](https://play.google.com/store) oder [F-Droid](https://f-droid.org/).
2. Öffnen Sie die App.
3. Tippen Sie auf **Konto hinzufügen** oder im Startbildschirm auf das "+"-Symbol.
4. Geben Sie Ihre E-Mail-Adresse und Ihr Passwort ein und tippen Sie auf **Manuelle Einrichtung**.
5. Wählen Sie **IMAP** als Kontotyp.
6. Tragen Sie folgende Informationen ein:
    - **IMAP-Server:** Ihren `MAILCOW_HOSTNAME` <span class="client_variables_available"> <code><span class="client_var_host"></span></code></span>
    - **Sicherheit:** STARTTLS oder SSL/TLS
    - **Port:** 993 (SSL) oder 143 (STARTTLS)
    - **Benutzername:** Ihre E-Mail Adresse <span class="client_variables_available"> <code><span class="client_var_email"></span></code></span>
7. Für den SMTP-Server:
    - **SMTP-Server:** Ihren `MAILCOW_HOSTNAME` <span class="client_variables_available"> <code><span class="client_var_host"></span></code></span>
    - **Sicherheit:** STARTTLS oder SSL/TLS
    - **Port:** 465 (SSL) oder 587 (STARTTLS)
    - **Benutzername:** Ihre E-Mail Adresse <span class="client_variables_available"> <code><span class="client_var_email"></span></code></span>
8. Tippen Sie auf **Weiter**, geben Sie ggf. einen Kontonamen ein und schließen Sie die Einrichtung ab.

K-9 Mail unterstützt keine native CardDAV- oder CalDAV-Synchronisierung. Für Kontakte und Kalender empfehlen wir zusätzlich die Apps **DAVx⁵** oder **ICSx⁵**.