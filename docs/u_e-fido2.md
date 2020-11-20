## How is UV handled in mailcow?

The UV flag (as in "user verification") enforces WebAuthn to verify the user before it allows access to the key (think of a PIN). We don't enforce UV to allow logins via iOS and NFC (YubiKey).

## Login and key processing

mailcow uses **client-side key processing**. We ask the authenticator (i.e. YubiKey) to save the registration in its memory.

A user does not need to enter a username. The available credentials - if any - will be shown to the user when selecting the "key login" via mailcow UI login.

When calling the login process, the authenticator is not given any credential IDs. This will force it to lookup credentials in its own memory.

## Who can use WebAuthn to login to mailcow?

As of today, only administrators and domain administrators are able to setup WebAuthn/FIDO2.
