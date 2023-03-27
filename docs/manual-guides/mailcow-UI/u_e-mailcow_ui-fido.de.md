## Wie wird UV in mailcow gehandhabt?

Das UV-Flag (wie in "user verification") erzwingt, dass WebAuthn den Benutzer verifiziert, bevor es den Zugriff auf den Schlüssel erlaubt (denken Sie an eine PIN). Wir erzwingen keine UV, um Logins über iOS und NFC (YubiKey) zu ermöglichen.

## Login und Schlüssel-Verarbeitung

mailcow verwendet **Client-seitige Schlüsselverarbeitung**. Wir bitten den Authentifikator (d.h. YubiKey), die Registrierung in seinem Speicher zu speichern.

Ein Benutzer muss keinen Benutzernamen eingeben. Die verfügbaren Anmeldedaten - falls vorhanden - werden dem Nutzer angezeigt, wenn er den "Schlüssel-Login" über das mailcow UI Login auswählt.

Beim Aufruf des Login-Prozesses werden dem Authentifikator keine Credential-IDs übergeben. Dies wird ihn dazu zwingen, die Anmeldeinformationen in seinem eigenen Speicher zu suchen.

## Wer kann WebAuthn benutzen, um sich bei mailcow anzumelden?

Ab heute sind nur Administratoren und Domain-Administratoren in der Lage, WebAuthn/FIDO2 einzurichten.

---
**Sie wollen WebAuthn/Fido als 2FA verwenden? Schauen Sie sich das hier an: [Zwei-Faktoren-Authentifizierung](u_e-mailcow_ui-tfa.de.md)**