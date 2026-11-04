SOGo is used for accessing your mails via a webbrowser, adding and sharing your contacts or calendars. For a more in-depth documentation on SOGo please visit its [own documentation](https://www.sogo.nu/files/docs/SOGoInstallationGuide.html).

## Theme, logo and favicon

The theme, logo and favicon of SOGo are described in [Customize design](../mailcow-UI/u_e-mailcow_ui-design.md#sogo).

## Connect domains
Domains are usually isolated from eachother.

You can change that by modifying `data/conf/sogo/sogo.conf`:

Search...
```
   // SOGoDomainsVisibility = (
    //  (domain1.tld, domain5.tld),
    //  (domain3.tld, domain2.tld)
    // );
```
...and replace it by - for example:

```
    SOGoDomainsVisibility = (
      (example.org, example.com, example.net)
    );
```

Restart SOGo:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart sogo-mailcow
    ```

## Enable password changing

The password change option in SOGo is disabled by default because it:

+ doesn't take into account the password policy set in the mailcow UI
+ doesn't work when the user is logged in into SOGo using the `Login to Webmail` function in the mailcow UI (Auth Proxy)

If you still want enable this option edit `data/conf/sogo/sogo.conf` and **change** `SOGoPasswordChangeEnabled` to `YES`. Please do not add a new parameter.

Run this command to activate the changes:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart memcached-mailcow sogo-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart memcached-mailcow sogo-mailcow
    ```

## Reset TOTP / Disable TOTP

Run the following command from within the mailcow directory:

=== "docker compose (Plugin)"

    ``` bash
    docker compose exec -u sogo sogo-mailcow sogo-tool user-preferences set defaults user@example.com SOGoTOTPEnabled '{"SOGoTOTPEnabled":0}'
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose exec -u sogo sogo-mailcow sogo-tool user-preferences set defaults user@example.com SOGoTOTPEnabled '{"SOGoTOTPEnabled":0}'
    ```
