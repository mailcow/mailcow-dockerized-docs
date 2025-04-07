!!! warning "Warning"
    **Mailbox users who have enabled two-factor authentication must create app passwords for external applications such as mail clients.**

So far three methods for _Two-Factor Authentication_ are implemented: WebAuthn (replacing U2F since February 2022), Yubi OTP, and TOTP

-   For WebAuthn to work, you need an encrypted connection to the server (HTTPS) as well as a FIDO security key.
-   Both WebAuthn and Yubi OTP work well with the fantastic [Yubikey](https://www.yubico.com).
-   While Yubi OTP needs an active internet connection and an API ID + key, WebAuthn will work with any Fido Security Key out of the box, but can only be used when mailcow is accessed over HTTPS.
-   WebAuthn and Yubi OTP support multiple keys per user.
-   As the third TFA method mailcow uses TOTP: time-based one-time passwords. Those passwords can be generated with apps like "Google Authenticator" after initially scanning a QR code or entering the given secret manually.

As administrator you are able to temporary disable a domain administrators TFA login until they successfully logged in.

The key used to login will be displayed in green, while other keys remain grey.

Information on how to remove 2FA can be found [here](../../troubleshooting/debug-reset_pw.en.md#remove-two-factor-authentication).

## Yubi OTP

The Yubi API ID and Key will be checked against the Yubico Cloud API. When setting up TFA you will be asked for your personal API account for this key.
The API ID, API key and the first 12 characters (your YubiKeys ID in modhex) are stored in the MySQL table as secret.

### Example setup

First of all, the YubiKey must be configured for use as an OTP Generator. To do this, download the `YubiKey Manager` from the Yubico website: [here](https://www.yubico.com/support/download/)

In the following you configure the YubiKey for OTP.
Via the menu item `Applications` -> `OTP` and a click on the `Configure` button. In the following menu select `Credential Type` -> `Yubico OTP` and click on `Next`.

Set a checkmark in the `Use serial` checkbox, generate a `Private ID` and a `Secret key` via the buttons. 
So that the YubiKey can be validated later, the checkmark in the `Upload` checkbox must also be set and then click on `Finish`.

Now a new browser window will open in which you have to enter an OTP of your YubiKey at the bottom of the form (click on the field and then tap on your YubiKey). Confirm the captcha and upload the information to the Yubico server by clicking 'Upload'. The processing of the data will take a moment.

After the generation was successful, you will be shown a `Client ID` and a `Secret key`, make a note of this information in a safe place.

Now you can select `Yubico OTP authentication` from the dropdown menu in the mailcow UI on the start page under `Access` -> `Two-factor authentication`. 
In the dialog that opened now you can enter a name for this YubiKey and insert the `Client ID` you noted before as well as the `Secret key` into the fields provided.
Finally, enter your current account password and, after selecting the `Touch Yubikey` field, touch your YubiKey button.

Congratulations! You can now log in to the mailcow UI using your YubiKey!

---

## WebAuthn (U2F, replacement)
!!! warning
    **Since February 2022 Google Chrome has discarded support for U2F and standardized the use of WebAuthn.<br>**
    *The WebAuthn (U2F removal) is part of mailcow since 21th January 2022, so if you want to use the Key past February 2022 please consider a update with the `update.sh`* 
    
To use WebAuthn, the browser must support this standard.

The following desktop browsers support this authentication type:

-   Edge (>=18)
-   Firefox (>=60)
-   Chrome (>=67)
-   Safari (>=13)
-   Opera (>=54)

The following mobile browsers support this authentication type:

-   Safari on iOS (>=14.5)
-   Android Browser (>=97)
-   Opera Mobile (>=64)
-   Chrome for Android (>=97)

Sources: [caniuse.com](https://caniuse.com/webauthn), [blog.mozilla.org](https://blog.mozilla.org/security/2019/04/04/shipping-fido-u2f-api-support-in-firefox/)

WebAuthn works without an internet connection.

### What will happen to my registered Fido Security Key after the Update from U2F to WebAuthn?
!!! warning
    With this new U2F replacement (WebAuthn) you have to re-register your Fido Security Key, thankfully WebAuthn is backwards compatible and supports the U2F protocol.

Ideally, the next time you log in (with the key), you should get a text box saying that your Fido Security Key has been removed due to the update to WebAuthn and deleted as a 2-factor authenticator.

But don't worry! You can simply re-register your existing key and use it as usual, you probably won't even notice a difference, except that your browser won't show the U2F deactivation message anymore.

### Disable unofficial supported Fido Security Keys
With WebAuthn there is the possibility to use only official Fido Security Keys (from the big brands like: Yubico, Apple, Nitro, Google, Huawei, Microsoft, etc.).

This is primarily for security purposes, as it allows administrators to ensure that only official hardware can be used in their environment.

To enable this feature, change the value `WEBAUTHN_ONLY_TRUSTED_VENDORS` in mailcow.conf from `n` to `y` and restart the affected containers with the following command:

=== "docker compose (Plugin)"

    ``` bash
    docker compose up -d
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose up -d
    ```

The mailcow will now use the Vendor Certificates located in your mailcow directory under `data/web/inc/lib/WebAuthn/rootCertificates`. 

!!! abstract "Example"
    If you want to limit the official Vendor devices to Apple only you only need the Apple Vendor Certificate inside the `data/web/inc/lib/WebAuthn/rootCertificates`.
    After you deleted all other certs you now only can activate WebAuthn 2FA with Apple devices.

    Every vendor (listed there) behaves the same, so choose what you like (if you want to).

### Use own certificates for WebAuthn
If you have a valid certificate from the vendor of your key you can also add it to your mailcow!

Just copy the certificate into the `data/web/inc/lib/WebAuthn/rootCertificates` folder and restart your mailcow.

Now you should be able to register this device as well, even though the verification for the vendor certificates is enabled, since you just added the certificate manually. 

### Is it dangerous to keep the Vendor Check disabled?
No, it isn´t!
These vendor certificates are only used to verify original hardware, not to secure the registration process.

As you can read in these articles, the deactivation is not software security related:

- [https://developers.yubico.com/U2F/Attestation_and_Metadata/](https://developers.yubico.com/U2F/Attestation_and_Metadata/)
- [https://medium.com/webauthnworks/webauthn-fido2-demystifying-attestation-and-mds-efc3b3cb3651](https://medium.com/webauthnworks/webauthn-fido2-demystifying-attestation-and-mds-efc3b3cb3651)
- [https://medium.com/webauthnworks/sorting-fido-ctap-webauthn-terminology-7d32067c0b01](https://medium.com/webauthnworks/sorting-fido-ctap-webauthn-terminology-7d32067c0b01)

In the end, however, it is of course your decision to leave this check disabled or enabled. 

---

## TOTP

The best known TFA method mostly used with a smartphone.

To setup the TOTP method login to the Admin UI and select `Time-based OTP (TOTP)` from the list.

Now a modal will open in which you have to type in a name for your 2FA "device" (example: John Deer´s Smartphone) and the password of the affected Admin account (you are currently logged in with).

You have two seperate methods to register TOTP to your account:
1. Scan the QR-Code with your Authenticator App on a Smartphone or Tablet.
2. Use the TOTP Code (under the QR Code) in your TOTP Program or App (if you can´t scan a QR Code).

After you have registered the QR or TOTP code in the TOTP app/program of your choice you only need to enter the now generated TOTP token (in the app/program) as confirmation in the mailcow UI to finally activate the TOTP 2FA, otherwise it will not be activated even though the TOTP token is already generated in your app/program.