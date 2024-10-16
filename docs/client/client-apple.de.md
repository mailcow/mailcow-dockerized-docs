## Methode 1: Konfigurationsprofil

E-Mail, Kontakte und Kalender können auf Apple-Geräten automatisch konfiguriert werden, indem ein Konfigurationsprofil installiert wird. Um ein solches Profil herunterzuladen, müssen Sie sich mit dem gewünschten E-Mail-Konto in der mailcow UI anmelden.

## Methode 1.1: IMAP und SMTP

Diese Methode konfiguriert IMAP und SMTP für den Zugriff auf ein E-Mail-Konto.

1. Öffnen Sie <span class="client_variables_unavailable"><i>https://${MAILCOW_HOSTNAME}/mobileconfig.php?only_email</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php?only_email">mailcow.mobileconfig</a></span> um ein individuelles Konfigurationsprofil herunterzuladen.
2. Öffnen Sie das Profil auf Ihrem Mac, iPhone oder iPad und folgen Sie der Anleitung von Apple für Ihre Betriebssystemversion, um das Profil zu installieren:
    - [Anleitung für macOS](https://support.apple.com/de-de/guide/mac-help/mh35561/mac)
    - [Anleitung für iOS](https://support.apple.com/de-de/102400)
3. Da das Profil nicht digital signiert ist, müssen Sie den entsprechenden Hinweis bei der Installation bestätigen. Wenn Sie dazu aufgefordert werden, geben Sie das Passwort Ihres E-Mail-Kontos ein.

## Methode 1.2: IMAP, SMTP und Cal/CardDAV

Diese Methode konfiguriert neben dem E-Mail-Konto zusätzlich CardDAV (Adressbuch) und CalDAV (Kalender).

1. Öffnen Sie <span class="client_variables_unavailable"><i>https://${MAILCOW_HOSTNAME}/mobileconfig.php</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php">mailcow.mobileconfig</a></span> um ein individuelles Konfigurationsprofil herunterzuladen.
2. Öffnen Sie das Profil auf Ihrem Mac, iPhone oder iPad und folgen Sie der Anleitung von Apple für Ihre Betriebssystemversion, um das Profil zu installieren:
    - [Anleitung für macOS](https://support.apple.com/de-de/guide/mac-help/mh35561/mac)
    - [Anleitung für iOS](https://support.apple.com/de-de/102400)
3. Da das Profil nicht digital signiert ist, müssen Sie den entsprechenden Hinweis bei der Installation bestätigen. Wenn Sie dazu aufgefordert werden, geben Sie das Passwort Ihres E-Mail-Kontos ein.

## Methode 1.3: IMAP und SMTP mit App-Passwort

Diese Methode konfiguriert IMAP und SMTP für den Zugriff auf ein E-Mail-Konto. Es wird ein neues App-Passwort erzeugt und in das Profil eingefügt, damit bei der Einrichtung kein Passwort eingegeben werden muss. Geben Sie das Profil nicht weiter, da es einen vollständigen Zugriff auf Ihr Postfach ermöglicht.

1. Öffnen Sie <span class="client_variables_unavailable"><i>https://${MAILCOW_HOSTNAME}/mobileconfig.php?only_email&app_password</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php?only_email&app_password">mailcow.mobileconfig</a></span> um ein individuelles Konfigurationsprofil herunterzuladen.
2. Öffnen Sie das Profil auf Ihrem Mac, iPhone oder iPad und folgen Sie der Anleitung von Apple für Ihre Betriebssystemversion, um das Profil zu installieren:
    - [Anleitung für macOS](https://support.apple.com/de-de/guide/mac-help/mh35561/mac)
    - [Anleitung für iOS](https://support.apple.com/de-de/102400)
3. Da das Profil nicht digital signiert ist, müssen Sie den entsprechenden Hinweis bei der Installation bestätigen.

## Methode 1.4: IMAP, SMTP und Cal/CardDAV mit App-Passwort

Diese Methode konfiguriert neben dem E-Mail-Konto zusätzlich CardDAV (Adressbuch) und CalDAV (Kalender). Es wird ein neues App-Passwort erzeugt und in das Profil eingefügt, damit bei der Einrichtung kein Passwort eingegeben werden muss. Geben Sie das Profil nicht weiter, da es einen vollständigen Zugriff auf Ihr Postfach ermöglicht.

1. Öffnen Sie <span class="client_variables_unavailable"><i>https://${MAILCOW_HOSTNAME}/mobileconfig.php?app_password</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php?app_password">mailcow.mobileconfig</a></span> um ein individuelles Konfigurationsprofil herunterzuladen.
2. Öffnen Sie das Profil auf Ihrem Mac, iPhone oder iPad und folgen Sie der Anleitung von Apple für Ihre Betriebssystemversion, um das Profil zu installieren:
    - [Anleitung für macOS](https://support.apple.com/de-de/guide/mac-help/mh35561/mac)
    - [Anleitung für iOS](https://support.apple.com/de-de/102400)
3. Da das Profil nicht digital signiert ist, müssen Sie den entsprechenden Hinweis bei der Installation bestätigen.

## Methode 2: Exchange ActiveSync-Emulation

Unter iOS/iPadOS wird auch Exchange ActiveSync als Alternative zum obigen Verfahren unterstützt. Es hat den Vorteil, dass es Push-E-Mail unterstützt (d. h. Sie werden sofort über eingehende Nachrichten benachrichtigt), hat aber einige Einschränkungen, z. B. unterstützt es nicht mehr als drei E-Mail-Adressen pro Kontakt in Ihrem Adressbuch. Befolgen Sie die folgenden Schritte, wenn Sie stattdessen Exchange verwenden möchten.

1. Folgen Sie der [Anleitung von Apple](https://support.apple.com/de-de/guide/iphone/iph44d1ae58a/ios) für Ihre Version von iOS/iPadOS und wählen Sie *Microsoft Exchange* als E-Mail-Dienst.
2. Geben Sie Ihre E-Mail Adresse<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> ein und tippen Sie auf *Weiter*.
3. Wählen Sie *Manuell konfigurieren* bei der Frage, ob die E-Mail-Adresse an Microsoft gesendet werden soll.
4. Geben Sie Ihr Passwort ein und tippen Sie erneut auf *Weiter*. Wenn die 2-Faktor-Authentifizierung aktiviert ist, müssen Sie ein App-Password anstelle Ihres normalen Passwortes benutzen.
5. Tippen Sie abschließend auf *Speichern*.