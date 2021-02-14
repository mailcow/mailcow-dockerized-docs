This is a simple integration of mailcow aliases and the mailbox name into mailpiler when using IMAP authentication.

**Disclaimer**: This is not officially maintained nor supported by the mailcow project nor its contributors. No warranty or support is being provided, however you're free to open issues on GitHub for filing a bug or provide further ideas. [GitHub repo can be found here](https://github.com/patschi/mailpiler-mailcow-integration).

!!! info
    Support for domain wildcards were implemented in Piler 1.3.10 which was released on 03.01.2021. Prior versions basically do work, but after logging in you won't see emails sent from or to the domain alias. (e.g. when @example.com is an alias for admin@example.com)

## The problem to solve

mailpiler offers the authentication based on IMAP, for example:

```php
$config['ENABLE_IMAP_AUTH'] = 1;
$config['IMAP_HOST'] = 'mail.example.com';
$config['IMAP_PORT'] =  993;
$config['IMAP_SSL'] = true;
```

- So when you log in using `patrik@example.com`, you will only see delivered emails sent from or to this specific email address.
- When additional aliases are defined in mailcow, like `team@example.com`, you won't see emails sent to or from this email address even the fact you're a recipient of mails sent to this alias address.

By hooking into the authentication process of mailpiler, we are able to get required data via the mailcow API during login. This fires API requests to the mailcow API (requiring read-only API access) to read out the aliases your email address participates and also the "Name" of the mailbox specified to display it on the top-right of mailpiler after login.

Permitted email addresses can be seen in the mailpiler settings top-right after logging in.

!!! info
    This is only pulled once during the authentication process. The authorized aliases and the realname are valid for the whole duration of the user session as mailpiler sets them in the session data. If user is removed from specific alias, this will only take effect after next login.

## The solution

Note: File paths might vary depending on your setup.

### Requirements

- A working mailcow instance
- A working mailpiler instance ([You can find an installation guide here](https://patrik.kernstock.net/2020/08/mailpiler-installation-guide/), [check supported versions here](https://github.com/patschi/mailpiler-mailcow-integration#piler))
- An mailcow API key (read-only works just fine): `Configuration & Details - Access - Read-Only Access`. Don't forget to allow API access from your mailpiler IP.

!!! warning
    As mailpiler authenticates against mailcow, our IMAP server, failed logins of users or bots might trigger a block for your mailpiler instance. Therefore you might want to consider whitelisting the IP address of the mailpiler instance within mailcow: `Configuration & Details - Configuration - Fail2ban parameters - Whitelisted networks/hosts`.

### Setup

1. Set the custom query function of mailpiler and append this to `/usr/local/etc/piler/config-site.php`:

    ```php
    $config['MAILCOW_API_KEY'] = 'YOUR_READONLY_API_KEY';
    $config['MAILCOW_SET_REALNAME'] = true; // when not specified, then default is false
    $config['CUSTOM_EMAIL_QUERY_FUNCTION'] = 'query_mailcow_for_email_access';
    include('auth-mailcow.php');
    ```

    You can also change the mailcow hostname, if required:
    ```php
    $config['MAILCOW_HOST'] = 'mail.domain.tld'; // defaults to $config['IMAP_HOST']
    ```

2. Download the PHP file with the functions from the [GitHub repo](https://github.com/patschi/mailpiler-mailcow-integration):

    ```sh
    curl -o /usr/local/etc/piler/auth-mailcow.php https://raw.githubusercontent.com/patschi/mailpiler-mailcow-integration/master/auth-mailcow.php
    ```

3. Done!

   Make sure to re-login with your IMAP credentials for changes to take effect.

   If it doesn't work, most likely something's wrong with the API query itself. Consider debugging by sending manual API requests to the API. (Tip: Open `https://mail.domain.tld/api` on your instance)
