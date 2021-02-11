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

- ARGON2I
- ARGON2ID
- CLEAR
- CLEARTEXT
- CRYPT
- DES-CRYPT
- LDAP-MD5
- MD5
- MD5-CRYPT
- PBKDF2
- PLAIN
- PLAIN-MD4
- PLAIN-MD5
- PLAIN-TRUNC
- SHA
- SHA1
- SHA256
- SHA256-CRYPT
- SHA512
- SHA512-CRYPT
- SMD5

That means mailcow is able to verify users with a hash like `{PLAIN-MD5}1a1dc91c907325c69271ddf0c944bc72` from the database.

The value of `MAILCOW_PASS_SCHEME` will _always_ be used to encrypt new passwords.

---

> I changed the password hashes in the "mailbox" SQL table and cannot login.

A "view" needs to be updated. You can trigger this by restarting sogo-mailcow: `docker-compose restart sogo-mailcow`
