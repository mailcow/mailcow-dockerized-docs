!!! info "Autodiscover Notice"
    The Autodiscover feature only works with Outlook versions up to and including 2019. Newer versions (2021, Microsoft (Office) 365, and the new Outlook) no longer support Autodiscover for mailcow and require manual configuration.

    **This is not a mailcow bug**, but a result of changes introduced by Microsoft.

## Outlook up to 2019 on Windows (ActiveSync – not recommended)

<div class="client_variables_unavailable" markdown="1">
  This only applies if your server administrator has not disabled EAS for Outlook. If it is disabled, please follow the instructions for Outlook 2007 instead.
</div>

!!! danger "Warning"
    mailcow's ActiveSync support does not work reliably with Outlook on Windows. We strongly discourage using this setup.

    Starting with Outlook 2019 (including Microsoft (Office) 365 and the new Outlook), ActiveSync is no longer functional with mailcow. Microsoft has disabled basic authentication for ActiveSync in these versions and now requires OAuth2 – a method that is incompatible with mailcow.

To manually set up EAS, launch the legacy setup assistant located at `C:\Program Files (x86)\Microsoft Office\root\Office16\OLCFG.EXE`. If the application opens, continue with step 4 from the Outlook 2013 instructions. If it fails to launch, disable the [simplified account creation assistant](https://support.microsoft.com/en-us/help/3189194/how-to-disable-simplified-account-creation-in-outlook) and follow the Outlook 2013 setup guide.

1. Start Outlook.
2. If this is the first launch, the account setup wizard will appear. In this case, proceed to step 4.
3. Open the *File* menu and click *Add Account*.
4. Enter your name, email address, and password. Click *Next*.
5. If prompted, re-enter your password, enable *Remember my credentials*, and click *OK*.
6. Click *Allow*.
7. Click *Finish*.

!!! notice "Autodiscover Notice"
    The Autodiscover feature only works with Outlook versions up to and including 2019. Newer versions (2019, 2021, Office 365, and the new Outlook) do not support mailcow Autodiscover and require manual setup.

    **This is not a mailcow issue**, but the result of Microsoft’s changes.

To use EAS, start the legacy configuration assistant at `C:\Program Files (x86)\Microsoft Office\root\Office16\OLCFG.EXE`. If the application launches, proceed with step 4 from the Outlook 2013 instructions.

If it doesn’t open, you can disable the [simplified account assistant](https://support.microsoft.com/en-us/help/3189194/how-to-disable-simplified-account-creation-in-outlook) and follow the instructions for Outlook 2013.

## The new Outlook (pre-installed on Windows)

!!! danger "Caution regarding the new Outlook"
    Login credentials entered in the new Outlook are transmitted to Microsoft and processed in their data centers. For more information, see: https://www.heise.de/news/Microsoft-krallt-sich-Zugangsdaten-Achtung-vorm-neuen-Outlook-9357691.html

    **We strongly advise against using the new Outlook due to security concerns.**

!!! warning "Warning"
    The new Outlook does **not** support CalDAV or CardDAV calendars – neither natively nor via [Outlook CalDav Synchronizer](https://caldavsynchronizer.org).

If you still want to use the new Outlook, follow these steps:

1. Launch the new Outlook.
2. If no account has been added yet, the setup wizard will open automatically. In that case, skip to step 5.
3. Click the gear icon in the top-right corner to open the settings.
4. Navigate to `Accounts` > `Your Accounts`, then click `Add Account` on the left.
5. Enter your email address and click `Next`.
6. Choose `IMAP` from the list of providers.
7. Enter the password for your email account in the `Password` field.
8. For the `IMAP Incoming Server`, enter the FQDN of your mailcow server (e.g. mail.example.com).
9. Use port 993 (IMAPS) in most cases.
10. The `Secure connection type` should be SSL/TLS (for IMAPS) or STARTTLS (for plain IMAP), depending on the port.
11. Re-enter your email address as the `SMTP Username` (if not prefilled).
12. Enter your email password again as the `SMTP Password`.
13. The `SMTP Outgoing Server` should again be your mailcow server's FQDN (e.g. mail.example.com).
14. Use port 587 for SMTP submission.
15. The `Secure connection type` should be SSL/TLS (for SMTPS/submission) or STARTTLS (for SMTP).
16. Click `Next` to complete the setup.

!!! info "Note"
    During the setup process, Microsoft may ask about privacy preferences. Decide for yourself whether and what to share.

## Outlook 2007 or newer on Windows (Calendar/Contacts via CalDav Synchronizer)

!!! warning "Warning"
    This guide is **not** compatible with the new Outlook.

1. Download and install [Outlook CalDav Synchronizer](https://caldavsynchronizer.org).
2. Start Outlook.
3. If this is the first time launching Outlook, the account setup wizard will appear. In this case, proceed to step 5.
4. Go to the *File* menu and click *Add Account*.
5. Enter your name, email address, and password. Click *Next*.
6. Click *Finish*.
7. Go to the *CalDav Synchronizer* tab and click *Synchronization Profiles*.
8. Click the second button at the top (*Add multiple profiles*), select *SOGo*, and click *OK*.
9. Click *Fetch settings from IMAP/POP3 account*.
10. Click *Discover resources and map to Outlook folders*.
11. In the *Select Resource* window, choose your main calendar (usually *Personal Calendar*), click `...`, assign it to the *Calendar* folder, and click *OK*. Repeat the process for *Address Books* and *Tasks*, assigning only one resource per folder type.
12. Close all windows by clicking *OK*.

## Outlook 2011 or newer on macOS

The macOS version of Outlook does not support synchronization of calendars or contacts with mailcow and is therefore not recommended.