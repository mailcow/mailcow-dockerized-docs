## Vollständig unterstützte Hashing-Methoden

Die aktuellste Version von mailcow unterstützt die folgenden Hashing-Methoden vollständig.
Die Standard-Hashing-Methode ist fett geschrieben:

- **BLF-CRYPT**
- SSHA
- SSHA256
- SSHA512

Die obigen Methoden können in `mailcow.conf` als `MAILCOW_PASS_SCHEME` Wert verwendet werden.

## Nur-Lese-Hashing-Methoden

Die folgenden Methoden werden **nur lesend** unterstützt.
Wenn Sie planen, SOGo zu benutzen (wie standardmäßig), benötigen Sie eine SOGo-kompatible Hash-Methode. Bitte beachten Sie den Hinweis am Ende dieser Seite, wie Sie die Ansicht bei Bedarf aktualisieren können.
Wenn SOGo deaktiviert ist, können alle unten aufgeführten Hashing-Methoden von mailcow und Dovecot gelesen werden.

- ARGON2I (SOGo kompatibel)
- ARGON2ID (SOGo kompatibel)
- CLEAR
- CLEARTEXT
- CRYPT (SOGo-kompatibel)
- DES-CRYPT
- LDAP-MD5 (SOGo-kompatibel)
- MD5 (SOGo-kompatibel)
- MD5-CRYPT (SOGo-kompatibel)
- PBKDF2 (SOGo-kompatibel)
- PLAIN (SOGo-kompatibel)
- PLAIN-MD4
- PLAIN-MD5
- PLAIN-TRUNC
- SHA (SOGo-kompatibel)
- SHA1 (SOGo-kompatibel)
- SHA256 (SOGo-kompatibel)
- SHA256-CRYPT (SOGo-kompatibel)
- SHA512 (SOGo-kompatibel)
- SHA512-CRYPT (SOGo-kompatibel)
- SMD5 (SOGo kompatibel)

Das bedeutet, mailcow ist in der Lage, Nutzer mit einem Hash wie `{MD5}1a1dc91c907325c69271ddf0c944bc72` aus der Datenbank zu verifizieren.

Der Wert von `MAILCOW_PASS_SCHEME` wird _immer_ verwendet, um neue Passwörter zu verschlüsseln.

---

> Ich habe die Passwort-Hashes in der SQL-Tabelle "Mailbox" geändert und kann mich nicht anmelden.

Eine "Ansicht" muss aktualisiert werden. Sie können dies durch einen Neustart von sogo-mailcow auslösen: `docker compose restart sogo-mailcow`