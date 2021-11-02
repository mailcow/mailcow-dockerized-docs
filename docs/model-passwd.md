## Fully supported hashing methods

The most current mailcow fully supports the following hashing methods.
The default hashing method is written in bold:

- **BLF-CRYPT**
- SSHA
- SSHA256
- SSHA512

The methods above can be used in `mailcow.conf` as `MAILCOW_PASS_SCHEME` value.

## Read-only hashing methods

The following methods are supported **read only**.
If you plan to use SOGo (as per default), you need a SOGo compatible hashing method. Please see the note at the bottom of this page how to update the view if necessary.
With SOGo disabled, all hashing methods below will be able to be read by mailcow and Dovecot.

- ARGON2I (SOGo compatible)
- ARGON2ID (SOGo compatible)
- CLEAR
- CLEARTEXT
- CRYPT (SOGo compatible)
- DES-CRYPT
- LDAP-MD5 (SOGo compatible)
- MD5 (SOGo compatible)
- MD5-CRYPT (SOGo compatible)
- PBKDF2 (SOGo compatible)
- PLAIN (SOGo compatible)
- PLAIN-MD4
- PLAIN-MD5
- PLAIN-TRUNC
- SHA (SOGo compatible)
- SHA1 (SOGo compatible)
- SHA256 (SOGo compatible)
- SHA256-CRYPT (SOGo compatible)
- SHA512 (SOGo compatible)
- SHA512-CRYPT (SOGo compatible)
- SMD5 (SOGo compatible)

That means mailcow is able to verify users with a hash like `{MD5}1a1dc91c907325c69271ddf0c944bc72` from the database.

The value of `MAILCOW_PASS_SCHEME` will _always_ be used to encrypt new passwords.

---

> I changed the password hashes in the "mailbox" SQL table and cannot login.

A "view" needs to be updated. You can trigger this by restarting sogo-mailcow: `docker-compose restart sogo-mailcow`
