## Methode 1 über Mobileconfig

E-Mail, Kontakte und Kalender können auf Apple-Geräten automatisch konfiguriert werden, indem ein Profil installiert wird. Um ein Profil herunterzuladen, müssen Sie sich zuerst in der mailcow UI anmelden.

## Methode 1.1: IMAP, SMTP und Cal/CardDAV

Diese Methode konfiguriert IMAP, CardDAV und CalDAV.

1. Downloaden und öffnen <span class="client_variables_unavailable">die Datei von <i>https://${MAILCOW_HOSTNAME}/mobileconfig.php</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php">mailcow.mobileconfig</a></span>.
2. Geben Sie den Entsperrungscode (iPhone) oder das Computerpasswort (Mac) ein.
3. Geben Sie Ihr E-Mail-Passwort dreimal ein, wenn Sie dazu aufgefordert werden.

## Methode 1.2: IMAP, SMTP (kein DAV)

Diese Methode konfiguriert nur IMAP und SMTP.

1. Downloaden und öffnen Sie <span class="client_variables_unavailable">die Datei von <i>https://${MAILCOW_HOSTNAME}/mobileconfig.php?only_email</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php?only_email">mailcow.mobileconfig</a></span>.
2. Geben Sie den Entsperrungscode (iPhone) oder das Computerpasswort (Mac) ein.
3. Geben Sie Ihr E-Mail-Passwort dreimal ein, wenn Sie dazu aufgefordert werden.

## Methode 2 (Exchange ActiveSync-Emulation)

Unter iOS wird auch Exchange ActiveSync als Alternative zum obigen Verfahren unterstützt. Es hat den Vorteil, dass es Push-E-Mail unterstützt (d. h. Sie werden sofort über eingehende Nachrichten benachrichtigt), hat aber einige Einschränkungen, z. B. unterstützt es nicht mehr als drei E-Mail-Adressen pro Kontakt in Ihrem Adressbuch. Befolgen Sie die folgenden Schritte, wenn Sie stattdessen Exchange verwenden möchten.

1. Öffnen Sie die App *Einstellungen*, tippen Sie auf *Mail*, tippen Sie auf *Konten*, tippen Sie auf *Konto hinzufügen*, wählen Sie *Exchange*.
2. Geben Sie Ihre E-Mail Adresse<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> ein und tippen Sie auf *Weiter*.
3. Geben Sie Ihr Passwort ein und tippen Sie erneut auf *Weiter*.
4. Tippen Sie abschließend auf *Speichern*.