## Method 1 (Exchange ActiveSync emulation)

1. Open the *Email* app.
2. If this is your first email account, tap *Add Account*; if not, tap *More* and *Settings* and then *Add account*.
3. Select *Microsoft Exchange ActiveSync*.
4. Enter your email address<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> and password.
5. Tap *Sign in*.

## Method 2 IMAP, SMTP and Cal/CardDAV

You can use any email app that supports IMAP and SMTP to read, organize and send emails. Some apps support automatic setup when you enter your email address. For all others, you can find the necessary information [here](client-manual). The username is always your full email address.

For the syncronisation of calendars (CalDAV) and contacts (CardDAV) apps like <a href="https://www.davx5.com/">DAVx⁵</a> are available. DAVx⁵ is available free of charge in the alternative appstore <a href="https://f-droid.org/">F-Droid</a>, or can be purchased in <a href="https://play.google.com/store/apps/details?id=at.bitfire.davdroid">Google Play</a>. You can set it up as follows:
1. Tap the plus button to add a new account.
2. Choose the option "Login with URL and user name".
3. Enter <code><span class="client_variables_available">https://<span class="client_var_host"></span><span class="client_var_port"></span></span><span class="client_variables_unavailable">https://your-mailcow-hostname</span></code> as
Base URL, your email address<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> as User name and your password.
4. Tap "login" and "Create Account" to complete the setup.
5. As a last step you need to select the calendars and address books you want to syncronize in the account you have now created. Afterwards you can tap the sync button in the lower right corner to start the first syncronization.
