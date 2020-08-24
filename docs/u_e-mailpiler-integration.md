This is a simple integration of mailcow aliases and the mailbox name into mailpiler when using IMAP authentication.

**Disclaimer**: This is not a official integration by the mailcow project nor its contributors. No warranty or support. [GitHub repo can be found here](https://github.com/patschi/mailpiler-mailcow-integration).

## The problem to solve

mailpiler offers the authentication based on IMAP, for example:

```php
$config['ENABLE_IMAP_AUTH'] = 1;
$config['IMAP_HOST'] = 'mail.example.com';
$config['IMAP_PORT'] =  993;
$config['IMAP_SSL'] = true;
```

So when you log in using `patrik@example.com`, you will only see delivered emails sent from or to this specific email address. When additional aliases are defined in mailcow, like `team@example.com`, you won't see emails sent from or to this email even the fact you're a recipient of mails sent to this alias.

With hooking into the authentication process of mailpiler this fires API requests to the mailcow API (requiring read-only API access) to read out the aliases your email address participates. Beside that, it will also read the "Name" of the mailbox specified to display it on the top-right of mailpiler after login.

## The solution

Paths might depend on your particular setup.

### Requirements

- A working Mailcow instance
- A working mailpiler instance
- An mailcow API key (read-only works just fine): `Configuration & Details - Access - Read-Only Access`. Don't forget to allow API access from your mailpiler IP.

**Important note**: As mailpiler authenticates against mailcow, our IMAP server, failed logins of users or bots might trigger a block for your mailpiler instance. Therefore you might want to consider whitelisting the IP address of the mailpiler instance within mailcow: `Configuration & Details - Configuration - Fail2ban parameters - Whitelisted networks/hosts`.

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

3. Then you need to re-login for changes to take effect. If it doesn't work, something's wrong with the API query itself. Consider debugging by sending manual API requests to the API.
