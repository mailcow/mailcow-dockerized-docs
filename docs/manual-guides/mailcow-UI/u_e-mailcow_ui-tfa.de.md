Bislang sind drei Methoden für die _Zwei-Faktor-Authentifizierung_ implementiert: WebAuthn (ersetzt seit Februar 2022 U2F), Yubi OTP und TOTP

- Damit WebAuthn funktioniert, benötigen Sie eine verschlüsselte Verbindung zum Server (HTTPS) sowie einen FIDO-Sicherheitsschlüssel.
- Sowohl WebAuthn als auch Yubi OTP funktionieren gut mit dem fantastischen [Yubikey](https://www.yubico.com).
- Während Yubi OTP eine aktive Internetverbindung und eine API ID + Schlüssel benötigt, funktioniert WebAuthn mit jedem Fido Security Key, kann aber nur verwendet werden, wenn der Zugriff auf mailcow über HTTPS erfolgt.
- WebAuthn und Yubi OTP unterstützen mehrere Schlüssel pro Nutzer.
- Als dritte TFA-Methode verwendet mailcow TOTP: zeitbasierte Einmal-Passwörter. Diese Passwörter können mit Apps wie "Google Authenticator" generiert werden, nachdem zunächst ein QR-Code gescannt oder das gegebene Geheimnis manuell eingegeben wurde.

Als Administrator können Sie den TFA-Login eines Domain-Administrators vorübergehend deaktivieren, bis dieser sich erfolgreich eingeloggt hat.

Der für die Anmeldung verwendete Schlüssel wird in grüner Farbe angezeigt, während andere Schlüssel grau bleiben.

Informationen zum Entfernen von 2FA finden Sie [hier](../../troubleshooting/debug-reset_pw.de.md#zwei-faktor-authentifizierung-entfernen).

## Yubi OTP

Die Yubi API ID und der Schlüssel werden mit der Yubico Cloud API abgeglichen. Bei der Einrichtung von TFA werden Sie nach Ihrem persönlichen API-Konto für diesen Schlüssel gefragt.
Die API-ID, der API-Schlüssel und die ersten 12 Zeichen (Ihre YubiKeys ID in modhex) werden in der MySQL-Tabelle als Geheimnis gespeichert.

### Beispiel-Einrichtung

Als erstes muss der YubiKey für die Verwendung als OTP-Generator konfiguriert werden. Laden Sie dazu den `YubiKey Manager` von der Yubico Website herunter: [hier](https://www.yubico.com/support/download/)

Im Folgenden konfigurieren Sie den YubiKey für OTP.
Über den Menüpunkt `Anwendungen` -> `OTP` und einem Klick auf den `Konfigurieren` Button. Wählen Sie im folgenden Menü `Credential Type` -> `Yubico OTP` und klicken Sie auf `Next`.

Setzen Sie ein Häkchen in die Checkbox `Use serial`, generieren Sie eine `Private ID` und einen `Secret key` über die Schaltflächen. 
Damit der YubiKey später validiert werden kann, muss auch das Häkchen in der `Upload` Checkbox gesetzt werden und klicken Sie dann auf `Finish`.

Nun öffnet sich ein neues Browserfenster, in dem Sie unten im Formular ein OTP Ihres YubiKey eingeben müssen (auf das Feld klicken und dann auf Ihren YubiKey tippen). Bestätigen Sie das Captcha und laden Sie die Daten auf den Yubico-Server hoch, indem Sie auf 'Hochladen' klicken. Die Verarbeitung der Daten wird einen Moment dauern.

Nachdem die Generierung erfolgreich war, werden Ihnen eine `Client ID` und ein `Secret key` angezeigt, notieren Sie sich diese Informationen an einem sicheren Ort.

Nun können Sie `Yubico OTP-Authentifizierung` aus dem Dropdown-Menü in der mailcow UI auf der Startseite unter `Zugang` -> `Zwei-Faktor-Authentifizierung` auswählen. 
In dem sich nun öffnenden Dialog können Sie einen Namen für diesen YubiKey eingeben und die zuvor notierte `Client ID` sowie den `Secret key` in die vorgesehenen Felder eintragen.
Geben Sie schließlich Ihr aktuelles Kontopasswort ein und berühren Sie nach Auswahl des Feldes `Touch Yubikey` die Schaltfläche Ihres YubiKey.

Herzlichen Glückwunsch! Sie können sich nun mit Ihrem YubiKey in die mailcow UI einloggen!

---

## WebAuthn (U2F, Ersatz)
!!! warning
    **Seit Februar 2022 hat Google Chrome die Unterstützung für U2F aufgegeben und die Verwendung von WebAuthn standardisiert.<br>**
    *Die WebAuthn API (der Ersatz für U2F) ist seit dem 21. Januar 2022 Teil von mailcow, wenn Sie also den Key über Februar 2022 hinaus nutzen wollen, sollten Sie ein Update mit der `update.sh`* in Betracht ziehen. 
    
Um WebAuthn zu nutzen, muss der Browser diesen Standard unterstützen:

- Edge (>=18)
- Firefox (>=60)
- Chrome (>=67)
- Safari (>=13)
- Opera (>=54)

Die folgenden mobilen Browser unterstützen diesen Authentifizierungstyp:

- Safari auf iOS (>=14.5)
- Android-Browser (>=97)
- Opera Mobil (>=64)
- Chrome für Android (>=97)

Quellen: [caniuse.com](https://caniuse.com/webauthn), [blog.mozilla.org](https://blog.mozilla.org/security/2019/04/04/shipping-fido-u2f-api-support-in-firefox/)

WebAuthn funktioniert auch ohne Internetverbindung.

### Was passiert mit meinem registrierten Fido Security Key nach dem Update von U2F auf WebAuthn?
!!! warning
    Mit dem neuen U2F-Ersatz (WebAuthn) müssen Sie Ihren Fido Security Key neu registrieren, zum Glück ist WebAuthn abwärtskompatibel und unterstützt das U2F-Protokoll.

Im Idealfall sollten Sie beim nächsten Einloggen (mit dem Schlüssel) ein Textfeld erhalten, das besagt, dass Ihr Fido Security Key aufgrund des Updates auf WebAuthn entfernt und als 2-Faktor-Authentifikator gelöscht wurde.

Aber keine Sorge! Sie können Ihren bestehenden Schlüssel einfach neu registrieren und ihn wie gewohnt verwenden. Sie werden wahrscheinlich nicht einmal einen Unterschied bemerken, außer dass Ihr Browser die U2F-Deaktivierungsmeldung nicht mehr anzeigt.

### Deaktivieren inoffizieller unterstützter Fido Security Keys
Mit WebAuthn gibt es die Möglichkeit, nur offizielle Fido Security Keys zu verwenden (von den großen Marken wie: Yubico, Apple, Nitro, Google, Huawei, Microsoft, usw.) zu verwenden.

Dies dient in erster Linie der Sicherheit, da es Administratoren ermöglicht, sicherzustellen, dass nur offizielle Hardware in ihrer Umgebung verwendet werden kann.

Um diese Funktion zu aktivieren, ändern Sie den Wert `WEBAUTHN_ONLY_TRUSTED_VENDORS` in mailcow.conf von `n` auf `y` und starten Sie die betroffenen Container mit `docker compose up -d` neu.

Die mailcow wird nun die Vendor-Zertifikate verwenden, die sich in Ihrem mailcow-Verzeichnis unter `data/web/inc/lib/WebAuthn/rootCertificates` befinden. 

##### Beispiel:
Wenn Sie die offiziellen Hersteller-Geräte nur auf Apple beschränken wollen, brauchen Sie nur das Apple Hersteller-Zertifikat im `data/web/inc/lib/WebAuthn/rootCertificates`.
Nachdem Sie alle anderen Zertifikate gelöscht haben, können Sie WebAuthn 2FA nur noch mit Apple-Geräten aktivieren.

Das ist für jeden Hersteller gleich, also wählen Sie aus, was Ihnen gefällt (wenn Sie es wollen).

#### Eigene Zertifikate für WebAuthn verwenden
Wenn du ein gültiges Zertifikat vom Hersteller deines Schlüssels hast, kannst du es auch zu deiner Mailcow hinzufügen!

Kopieren Sie einfach das Zertifikat in den `data/web/inc/lib/WebAuthn/rootCertificates` Ordner und starten Sie Ihre Mailcow neu.

Nun sollten Sie in der Lage sein, auch dieses Gerät zu registrieren, obwohl die Überprüfung für die Herstellerzertifikate aktiviert ist, da Sie das Zertifikat manuell hinzugefügt haben. 

#### Ist es gefährlich, den Vendor Check deaktiviert zu lassen?
Nein, das ist es nicht!
Diese Herstellerzertifikate werden nur zur Überprüfung der Originalhardware verwendet, nicht zur Absicherung des Registrierungsprozesses.

Wie Sie in diesen Artikeln lesen können, hat die Deaktivierung nichts mit der Software-Sicherheit zu tun:
- [https://developers.yubico.com/U2F/Attestation_and_Metadata/](https://developers.yubico.com/U2F/Attestation_and_Metadata/)
- [https://medium.com/webauthnworks/webauthn-fido2-demystifying-attestation-and-mds-efc3b3cb3651](https://medium.com/webauthnworks/webauthn-fido2-demystifying-attestation-and-mds-efc3b3cb3651)
- [https://medium.com/webauthnworks/sorting-fido-ctap-webauthn-terminology-7d32067c0b01](https://medium.com/webauthnworks/sorting-fido-ctap-webauthn-terminology-7d32067c0b01)

Letztendlich ist es aber natürlich Ihre Entscheidung, ob Sie dieses Häkchen deaktiviert oder aktiviert lassen. 

---

## TOTP

Die bekannteste TFA-Methode, die meist mit einem Smartphone verwendet wird.

Um die TOTP-Methode einzurichten, loggen Sie sich in die Admin UI ein und wählen Sie `Time-based OTP (TOTP)` aus der Liste.

Nun öffnet sich ein Modal, in dem Sie einen Namen für Ihr 2FA-"Gerät" (Beispiel: John Deer's Smartphone) und das Passwort des betroffenen Admin-Kontos (mit dem Sie derzeit eingeloggt sind) eingeben müssen.

Sie haben zwei verschiedene Methoden, um TOTP für Ihr Konto zu registrieren:
1. Scannen Sie den QR-Code mit Ihrer Authenticator App auf einem Smartphone oder Tablet.
2. Verwenden Sie den TOTP-Code (unter dem QR-Code) in Ihrem TOTP-Programm oder Ihrer App (wenn Sie keinen QR-Code scannen können).

Nachdem Sie den QR- oder TOTP-Code in der TOTP-App/dem TOTP-Programm Ihrer Wahl registriert haben, müssen Sie nur noch den nun generierten TOTP-Token (in der App/dem Programm) als Bestätigung in der mailcow UI eingeben, um die TOTP 2FA endgültig zu aktivieren, ansonsten wird sie nicht aktiviert, obwohl der TOTP-Token bereits in Ihrer App/ Ihrem Programm generiert wurde.
