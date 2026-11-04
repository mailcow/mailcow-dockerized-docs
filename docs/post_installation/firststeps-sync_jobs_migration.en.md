Sync jobs are used to copy or move existing emails either from an external IMAP server or between existing mailboxes within mailcow (see [Syncing mailboxes within mailcow](#syncing-mailboxes-within-mailcow)). mailcow uses [imapsync](https://imapsync.lamiral.info/) for this. Besides username and password, the login at the source server can use OAuth2, e.g. for Microsoft 365 and Google.

!!! warning "Notice"
    Depending on your mailbox’s access control list (ACL), you may not have permission to create a sync job. In this case, please contact your domain administrator.

A sync job always uses a **sync source**: the source IMAP server and how mailcow logs in there. Define each server once as a source and select it in every sync job.

## Adding a Sync Source

1. Navigate to “E-Mail :material-arrow-right: Configuration :material-arrow-right: Sync jobs” (if logged in as an admin or domain admin) or “User Settings :material-arrow-right: Sync jobs” (as a regular mailbox user) and click “Add source” in the section “Sync sources”.

2. Optionally pick one of the “Presets”. They fill in the server settings of common providers (Gmail, GMX, WEB.DE, T-Online, iCloud, Yahoo, IONOS, STRATO). Admins and domain admins also get presets for Microsoft 365 and Google. Many providers (e.g. Gmail, iCloud, Yahoo) require an app password or IMAP access to be enabled in the mailbox settings.

3. Enter a “Name” and choose the “Visibility”: who may use the source in their sync jobs. Administrators can share a source with all users, domain administrators with their domains or single mailboxes. Sources of mailbox users are only visible to themselves. Administrators see all sources.

4. Fill in “Host”, “Port” and “Encryption method” of the source server. SSL usually uses port 993, STARTTLS port 143. Enter the host name from the server certificate, not an IP address. Unencrypted connections (PLAIN) are possible, but strongly discouraged.

5. Leave “Verify the server certificate” on, unless the server has a self-signed or expired certificate (see [Certificate verification](#certificate-verification)).

6. Choose the “Authentication”: `PLAIN`, `LOGIN` or `CRAM-MD5` for username and password, `XOAUTH2` for OAuth2 (admins and domain admins only, see [OAuth2](#oauth2)).

7. Click “Add”.

## Certificate verification

“Verify the server certificate” is on for new sources. It applies to SSL and STARTTLS.

* mailcow checks the certificate against the host name of the source. The host must be the name in the certificate, e.g. `imap.example.net`, not an IP address.
* For servers with a self-signed or expired certificate, or a certificate that does not match the host, untick the box. Otherwise the sync job fails, e.g. with “Problem with encrypted connection” or “Can't connect to remote server”. “Check log” shows the details.
* The list of sources shows a shield icon next to the server when the certificate is not verified.
* Turning verification off for a source that sync jobs of other mailboxes use requires access to all of these mailboxes. Administrators can always do it.

## Creating a Sync Job

1. In the same place, click “Create new sync job”.

2. If you are an administrator or domain administrator, select the “Local mailbox (destination)” where the emails should be copied to.

3. Choose the source under “Select source”. Inactive sources cannot be selected.

4. Enter the login of the source mailbox:
    * Sources with username and password: “Remote username (source)” and “Remote password (source)”.
    * OAuth2 sources with user login: click “Sign in with the provider” and sign in with the source account. The remote username is taken from this account.
    * OAuth2 sources with client credentials: the source mailbox as “Remote username (source)”, no password.

5. All other fields can be left at their default values or adjusted as needed. “Custom parameters” takes additional imapsync options, one per row (see [Custom parameters](#custom-parameters)).

6. Make sure to check the “Active” box and click “Add” to finalize the sync job.

!!! notice "Please remember..."
    Once you’re done, log in to the target mailbox and verify that all emails were imported correctly. If everything worked as expected, all your emails will appear in the new inbox. Don’t forget to disable or delete the sync job once it’s no longer needed.

## Status and results

The list of sync jobs shows the status of every job (“Waiting”, “Running”, “Inactive”), the “Last run result” and the log of the last run (“Check log”). Common results:

| Last run result | Meaning |
| --- | --- |
| Success | The run finished without errors. |
| Wrong username or password | The login at the source failed. |
| Can't connect to remote server | The source server is not reachable, the certificate check failed (SSL) or the source points to mailcow itself. |
| Problem with encrypted connection | STARTTLS failed, e.g. because of the certificate check. |
| Target mailbox is over quota | The mailcow mailbox is full. |
| OAuth token not ready | There is no valid OAuth2 token (see [Troubleshooting](#troubleshooting)). |
| Check log | Any other result, the log shows the details. |

## Managing sources

The list of sources shows “Edit” for sources you may change and “Show” for sources that are only shared with you.

* Administrators can edit all sources. Everyone else can edit the sources they created. Domain administrators can also edit sources created by mailboxes of their domains.
* The connection of a source (host, port, encryption, authentication, and the OAuth2 flow, token endpoint and client ID) can only be changed by someone who has access to all mailboxes whose sync jobs use the source. Otherwise mailcow refuses the change with “The server of sync source … cannot be changed, sync jobs of other mailboxes use it”. Administrators can always change it.
* Changing the connection deletes the OAuth2 tokens of the source. Users of a user-login source have to sign in again.
* An inactive source pauses all of its sync jobs.
* A source can only be deleted while no sync job uses it.
* When the account that created a source is deleted, the source is deleted as well if no sync job uses it. Otherwise it is handed over to the administrators.

## OAuth2

Sources with the authentication `XOAUTH2` log in with an OAuth2 token instead of a password. Only administrators and domain administrators can create and edit them. There are two flows:

* **App (client credentials)**: mailcow logs in with an app that has access to all source mailboxes. Users do not have to sign in. Such sources are only visible to the person who created them and to administrators. Mailbox users cannot select them, so the sync jobs are created by the creator of the source or an administrator.
* **User login (authorization code)**: When creating a sync job, every user signs in at the provider once with the source account. Mailbox users can use such sources when they are shared with them.

The token endpoint and the other OAuth2 endpoints must be `https://` URLs. Sources that were not created by an administrator need endpoints with a public address.

For user-login sources, the source shows the “Redirect URI” to register in the app at the provider: `https://<MAILCOW_HOSTNAME>/syncjob-oauth`. The sign-in at the provider only works when mailcow is opened via this host name.

mailcow refreshes the tokens automatically, also during long sync runs.

* App sources: The list of sources shows a token badge, its tooltip shows until when the token is valid. “Refresh token now” on the edit page of the source requests a new token right away.
* User-login sources: The token belongs to the sync job, so the list of sync jobs shows the token badge for every job.

### Microsoft 365

!!! info "Prerequisite"
    IMAP must be enabled for the source mailboxes in Exchange Online (Microsoft 365 admin center: user :material-arrow-right: Mail :material-arrow-right: Manage email apps).

**App (client credentials)**

1. In the Microsoft Entra admin center, register a new app under “App registrations”.
2. Under “API permissions”, add the application permission `IMAP.AccessAsApp` of “Office 365 Exchange Online” (“APIs my organization uses”) and grant admin consent.
3. Under “Certificates & secrets”, create a client secret.
4. Register the app in Exchange Online and give it access to the source mailboxes, using the Exchange Online PowerShell. `<OBJECT_ID>` is the object ID of the app under “Enterprise applications”, not the one under “App registrations”:
    ```powershell
    New-ServicePrincipal -AppId <APPLICATION_ID> -ObjectId <OBJECT_ID>
    Add-MailboxPermission -Identity "user@contoso.com" -User <OBJECT_ID> -AccessRights FullAccess
    ```
    Microsoft describes these steps in detail in [Authenticate an IMAP, POP or SMTP connection using OAuth](https://learn.microsoft.com/en-us/exchange/client-developer/legacy-protocols/how-to-authenticate-an-imap-pop-smtp-application-by-using-oauth).
5. In mailcow, add a source with the preset “Microsoft 365 (Client credentials)” and enter the “Microsoft 365 tenant” (tenant ID or a domain of the tenant), the client ID and the client secret.

**User login (authorization code)**

1. In the Microsoft Entra admin center, register a new app under “App registrations”. Add the platform “Web” with the redirect URI of the source (`https://<MAILCOW_HOSTNAME>/syncjob-oauth`).
2. Under “API permissions”, add the delegated permissions `IMAP.AccessAsUser.All`, `offline_access`, `openid`, `email` and `profile` of “Microsoft Graph”. Grant admin consent, otherwise every user has to agree at the sign-in.
3. Under “Certificates & secrets”, create a client secret.
4. In mailcow, add a source with the preset “Microsoft 365 (User login)” and enter the tenant, the client ID and the client secret.

### Google

1. In the Google Cloud Console, configure the OAuth consent screen of a project. For Google Workspace, choose the user type “Internal”.
2. Under “Credentials”, create an “OAuth client ID” of the type “Web application” and add the redirect URI of the source (`https://<MAILCOW_HOSTNAME>/syncjob-oauth`) as authorized redirect URI.
3. In mailcow, add a source with the preset “Google (User login)” and enter the client ID and the client secret.

Users of a private Gmail account can use an app password with the preset “Gmail” instead.

### Troubleshooting

* **“OAuth token not ready” or “Token failed” on a sync job (user login)**: Open the sync job, click “Sign in with the provider”, sign in again and save. The browser must allow pop-ups for mailcow. When creating a sync job, administrators and domain administrators select the local mailbox before signing in.
* **“Token failed” on an app source**: The tooltip of the badge and “Last refresh error” on the edit page of the source show the error. Check tenant, client ID, client secret and the permissions of the app, then click “Refresh token now”.
* **The sign-in fails**: The sync job form shows the reason next to “Sign in with the provider”, e.g. “The provider did not issue a token (check client ID, secret and redirect URI)”.
* The sign-in needs a regular login with access to sync jobs. It does not work while a two-factor setup or password change is pending, and not in a session of a read-only API key.

## Syncing mailboxes within mailcow

A source must not point to mailcow itself. Sources with `localhost`, `dovecot` or another address of the internal Docker network are refused when the sync job runs. The job ends with “Can't connect to remote server”, the log shows “… is an address of mailcow itself”.

To copy emails between two mailboxes of the same mailcow, create a source with the public host name of mailcow (`MAILCOW_HOSTNAME`) as host.

## Settings for administrators

* **Parallel runs**: In “System :material-arrow-right: Configuration :material-arrow-right: Options :material-arrow-right: Sync jobs”, “Max. parallel sync processes” (1–32, default 1) defines how many sync jobs run at the same time. “Bandwidth limit per process (KB/s)” limits every sync process (0 = unlimited). It also caps the bandwidth limit of a single job. The total bandwidth is about this value × the number of parallel processes.
* **Order**: Due sync jobs run by their “Priority” (edit page of a sync job, only for administrators, higher runs first), then jobs that never ran, then the least recently run ones.
* **Schedule next**: In the list of sync jobs, “Actions :material-arrow-right: Schedule next” (only for administrators) moves the selected jobs to the front of the queue and makes them due right away. For this, their priority is set above all other jobs and stays so until it is changed on the edit page.

## Custom parameters

“Custom parameters” takes additional imapsync options, one option per row with its value. A value may contain spaces and is passed to imapsync as one argument. Only allowed options are accepted. The list is defined in `$IMAPSYNC_OPTIONS` in `data/web/inc/vars.inc.php` and can be changed in `data/web/inc/vars.local.inc.php`:

```php
<?php
// Allow an option that needs a value
$IMAPSYNC_OPTIONS['someoption'] = true;
// Allow an option without a value
$IMAPSYNC_OPTIONS['otheroption'] = false;
// Allow an option whose value must match a regular expression
$IMAPSYNC_OPTIONS['maxsize'] = '[0-9]+';
// Remove an option from the list
unset($IMAPSYNC_OPTIONS['debug']);
```

* Option names are written in lowercase and without leading dashes.
* `true`: the option needs a value. `false`: the option takes no value. A string: a regular expression (without delimiters) that the whole value must match.
* Some options can never be allowed, e.g. options that run commands or use local files (`pipemess`, `regextrans2`, `logfile`, …) and `showpasswords`. mailcow removes them from the list.
* If the list contains no valid entry, the default list applies.
* Changes only apply after a restart of PHP-FPM:

=== "docker compose (Plugin)"

    ``` bash
    docker compose restart php-fpm-mailcow
    ```

=== "docker-compose (Standalone)"

    ``` bash
    docker-compose restart php-fpm-mailcow
    ```
