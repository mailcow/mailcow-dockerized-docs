This is an experimental feature that allows admins and domain admins to directly 
log into SOGo as a mailbox user, without knowing the users password.

For this, an additional link to SOGo is displayed in the mailbox list.

Multiple concurrent admin-logins to different mailboxes are also possible when using this feature.

## Enabling the feature

The feature is disabled by default. It can be enabled in the `mailcow.conf` by setting:
```
ALLOW_ADMIN_EMAIL_LOGIN=y
```
and restarting the affected containers with
```
docker-compose up -d
```

## Drawbacks when enabled

- Each SOGo page-load and each Active-Sync request will cause an additional execution of an internal PHP script.
This might impact load-times of SOGo / EAS.
In most cases, this should not be noticeable but should be kept in mind if you face any performance issues.
- SOGo will not display a logout link for admin-logins, to login normally one has to logout from the mailcow UI so the PHP session is destroyed.

## Technical details

SOGoTrustProxyAuthentication option is set to YES which makes SOGo trust the x-webobjects-remote-user header.

Dovecot will receive a random master-password which is valid for all mailboxes when used by the SOGo container.

Clicking on the SOGo button in the mailbox list will open sogo-auth.php which checks permissions, sets session variables and redirects to the SOGo mailbox.

Each SOGo, CardDAV, CalDAV and EAS http request will cause an additional, nginx internal auth_request call to sogo-auth.php with the following behavior:

- If a basic_auth header is present, the script will validate the credentials in place of SOGo and provide the following headers:
`x-webobjects-remote-user`, `Authorization` and `x-webobjects-auth-type`.

- If no basic_auth header is present, the script will check for an active mailcow admin session for the requested email user and provide the same headers but with the dovecot master password used in the `Authorization` header.

- If both fails the headers will be set empty, which makes SOGo use its standard authentication methods.

All of these options / behaviors are disabled if the `ALLOW_ADMIN_EMAIL_LOGIN` is not enabled in the config.
