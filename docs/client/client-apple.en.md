!!! warning
    There have been several independent reports of unintended configuration changes causing emails to no longer be sent or received on Apple devices. The root cause appears to be the device automatically enabling the "Automatically manage connection settings" option. This setting incorrectly changes the SMTP port from 587 to 25 and disables password authentication.

    If you suddenly can't send or receive emails on your Apple device, please check these settings first.

## Method 1: Configuration Profile

Email, contacts and calendars can be configured automatically on Apple devices by installing a configuration profile. To download such a profile you must login to the mailcow UI with the desired email account first.

## Method 1.1: IMAP and SMTP

This method configures IMAP and SMTP to access an email account.

1. Open <span class="client_variables_unavailable"> <i>https://${MAILCOW_HOSTNAME}/mobileconfig.php?only_email</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php?only_email">mailcow.mobileconfig</a></span> to download a customized configuration profile.
2. Open the profile on your Mac, iPhone or iPad and follow Apple's instructions for your operating system version to install the profile:
    - [Steps for macOS](https://support.apple.com/en-us/guide/mac-help/mh35561/mac)
    - [Steps for iOS](https://support.apple.com/en-us/102400)
3. Since the profile is not digitally signed, you must confirm the respective notification during installation. Enter the password for your email account when asked.

## Method 1.2: IMAP, SMTP and Cal/CardDAV

This method configures CardDAV (address book) and CalDAV (calendar) in addition to the email account.

1. Open <span class="client_variables_unavailable"> <i>https://${MAILCOW_HOSTNAME}/mobileconfig.php</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php">mailcow.mobileconfig</a></span> to download a customized configuration profile.
2. Open the profile on your Mac, iPhone or iPad and follow Apple's instructions for your operating system version to install the profile:
    - [Steps for macOS](https://support.apple.com/en-us/guide/mac-help/mh35561/mac)
    - [Steps for iOS](https://support.apple.com/en-us/102400)
3. Since the profile is not digitally signed, you must confirm the respective notification during installation. Enter the password for your email account when asked.

## Method 1.3: IMAP and SMTP with App Password

This method configures IMAP and SMTP to access an email account. A new app password is generated and added to the profile so that no password needs to be entered when setting up your device. Please do not share the file as it grants full access to your mailbox.

1. Open <span class="client_variables_unavailable"> <i>https://${MAILCOW_HOSTNAME}/mobileconfig.php?only_email&app_password</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php?only_email&app_password">mailcow.mobileconfig</a></span> to download a customized configuration profile.
2. Open the profile on your Mac, iPhone or iPad and follow Apple's instructions for your operating system version to install the profile:
    - [Steps for macOS](https://support.apple.com/en-us/guide/mac-help/mh35561/mac)
    - [Steps for iOS](https://support.apple.com/en-us/102400)
3. Since the profile is not digitally signed, you must confirm the respective notification during installation. Enter the password for your email account when asked.

## Method 1.4: IMAP, SMTP and Cal/CardDAV with App Password

This method configures CardDAV (address book) and CalDAV (calendar) in addition to the email account. A new app password is generated and added to the profile so that no password needs to be entered when setting up your device. Please do not share the file as it grants full access to your mailbox.

1. Open <span class="client_variables_unavailable"> <i>https://${MAILCOW_HOSTNAME}/mobileconfig.php?app_password</i></span><span class="client_variables_available"><a class="client_var_link" href="mobileconfig.php?app_password">mailcow.mobileconfig</a></span> to download a customized configuration profile.
2. Open the profile on your Mac, iPhone or iPad and follow Apple's instructions for your operating system version to install the profile:
    - [Steps for macOS](https://support.apple.com/en-us/guide/mac-help/mh35561/mac)
    - [Steps for iOS](https://support.apple.com/en-us/102400)
3. Since the profile is not digitally signed, you must confirm the respective notification during installation. Enter the password for your email account when asked.

## Method 2: Exchange ActiveSync emulation

On iOS/iPadOS, Exchange ActiveSync is also supported as an alternative to the procedure above. It has the advantage of supporting push email (i.e. you are immediately notified of incoming messages), but has some limitations, e.g. it does not support more than three email addresses per contact in your address book. Follow the steps below if you decide to use Exchange instead.

1. Follow [Apple's instructions](https://support.apple.com/en-us/guide/iphone/iph44d1ae58a/ios) for your version of iOS/iPadOS and select *Microsoft Exchange* as email service.
2. Enter your email address<span class="client_variables_available"> (<code><span class="client_var_email"></span></code>)</span> and tap *Next*.
3. Select *Manual Configuration* when asked if your mail address should be sent to Microsoft.
4. Enter your password, tap *Next* again. With Two-factor authentication enabled, you have to use an app password instead of your regular password.
5. Finally, tap *Save*.