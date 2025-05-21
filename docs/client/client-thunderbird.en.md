!!! success "Recommended for mailcow"
    We recommend using this client in combination with our mailcow software for smooth operation and hassle-free emailing.

## What is Thunderbird?

[Thunderbird](https://www.thunderbird.net) is a free and open-source email client developed by the Mozilla Foundation. It supports multiple email accounts (IMAP, POP3), contacts, calendars, and add-ons to extend its functionality. Thunderbird is known for its high compatibility, user-friendly interface, and extensive customization options, making it particularly well-suited for use with mailcow.

## Setup Instructions on Desktop

!!! notice "Note"
    Please ensure that you have configured the [advanced DNS settings](../getstarted/prerequisite-dns.en.md#the-advanced-dns-configuration) to enable smooth automatic detection of your mail settings.

1. Open Thunderbird.
2. If this is your first time opening Thunderbird, you will be prompted to create a new email address. Click **Skip this and use my existing email address** and continue with step 4.
3. Click on the **File** menu and select **New → Existing Mail Account...**.
4. Enter your name<span class="client_variables_available"> (<code><span class="client_var_name"></span></code>)</span>, your email address<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span>, and your password. Make sure **Remember password** is checked and click **Continue**.
5. Once the configuration is detected automatically, ensure **IMAP** is selected and click **Done**.
6. To use your contacts from the server, click the arrow next to **Address Books** and then click **Connect** for each address book you want to use.
7. To use your calendars from the server, click the arrow next to **Calendars** and then click **Connect** for each calendar you want to use.
8. *(Optional)* If you want to synchronize all subfolders:
    - Open the **Account Settings** menu and select **Server Settings**.
    - In the **Server Settings** tab, click the **Advanced** button.
    - In the **Advanced Account Settings** window, uncheck **Show only subscribed folders**.
    - Click **OK** to save the changes.
9. Click **Finish** to close the account setup window.

---

## Setup on Android (Thunderbird Mobile / K-9 Mail)

As of version 115, Thunderbird for Android is based on the well-established app [K-9 Mail](https://k9mail.app/). The setup is similar:

1. Install **K-9 Mail** or **Thunderbird for Android** from the [Google Play Store](https://play.google.com/store) or [F-Droid](https://f-droid.org/).
2. Open the app.
3. Tap **Add Account** or the "+" icon on the start screen.
4. Enter your email address and password, then tap **Manual Setup**.
5. Choose **IMAP** as the account type.
6. Enter the following information:
    - **IMAP Server:** your `MAILCOW_HOSTNAME` <span class="client_variables_available"> <code><span class="client_var_host"></span></code></span>
    - **Security:** STARTTLS or SSL/TLS
    - **Port:** 993 (SSL) or 143 (STARTTLS)
    - **Username:** your email address <span class="client_variables_available"> <code><span class="client_var_email"></span></code></span>
7. For the SMTP server:
    - **SMTP Server:** your `MAILCOW_HOSTNAME` <span class="client_variables_available"> <code><span class="client_var_host"></span></code></span>
    - **Security:** STARTTLS or SSL/TLS
    - **Port:** 465 (SSL) or 587 (STARTTLS)
    - **Username:** your email address <span class="client_variables_available"> <code><span class="client_var_email"></span></code></span>
8. Tap **Next**, optionally set a display name for the account, and complete the setup.

K-9 Mail does not support native CardDAV or CalDAV synchronization. For contacts and calendars, we recommend using the additional apps **DAVx⁵** or **ICSx⁵**.